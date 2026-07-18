import 'dart:async';
import 'dart:convert';

import '/api/shph_token_storage.dart';
import '../api/shph_api.dart' show ShphApiClient;
import '../api/shph_api_client.dart' show ShphApiClient;
import 'auth_logger.dart';

/// Lightweight monitor for SHPH JWT token expiry.
///
/// The actual token refresh is performed by the [ShphApiClient] interceptor
/// when a 401 response is received. This manager only logs the remaining
/// lifetime and clears stored tokens when the token is no longer valid.
class TokenRefreshManager {
  factory TokenRefreshManager() => _instance;

  TokenRefreshManager._internal();
  static final TokenRefreshManager _instance = TokenRefreshManager._internal();

  Timer? _timer;

  /// How often to check the stored token.
  static const Duration _checkInterval = Duration(minutes: 5);

  /// Start monitoring the stored SHPH JWT token.
  void startTokenRefreshMonitoring() {
    AuthLogger.debug('Starting SHPH token refresh monitoring',
        tag: 'TokenRefresh');
    _timer?.cancel();
    _timer = Timer.periodic(_checkInterval, (_) => _checkToken());
    _checkToken();
  }

  /// Stop monitoring.
  void stopTokenRefreshMonitoring() {
    AuthLogger.debug('Stopping SHPH token refresh monitoring',
        tag: 'TokenRefresh');
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkToken() async {
    final token = await ShphTokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return;
    }

    final expiry = _extractExpiry(token);
    if (expiry == null) {
      return;
    }

    final remaining = expiry.difference(DateTime.now());
    AuthLogger.debug(
      'SHPH token expires in ${remaining.inMinutes} minutes',
      tag: 'TokenRefresh',
    );

    if (remaining.inSeconds <= 0) {
      AuthLogger.warning(
        'SHPH token appears expired; clearing stored tokens',
        tag: 'TokenRefresh',
      );
      await ShphTokenStorage.clear();
    }
  }

  DateTime? _extractExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      final normalized = base64Url.normalize(parts[1]);
      final decoded = base64Url.decode(normalized);
      final payload = jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get time until token expiry (for UI display, e.g., warning messages).
  Future<Duration?> getTimeUntilTokenExpiry() async {
    final token = await ShphTokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    final expiry = _extractExpiry(token);
    if (expiry == null) {
      return null;
    }
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if token is expired.
  Future<bool> isTokenExpired() async {
    final remaining = await getTimeUntilTokenExpiry();
    return remaining == null || remaining.inSeconds <= 0;
  }
}
