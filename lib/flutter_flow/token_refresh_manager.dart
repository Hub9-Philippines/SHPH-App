import 'dart:async';
import '/api/shph_token_storage.dart';
import 'auth_logger.dart';

/// Manages automatic token refresh to prevent session expiration.
/// SHPH API JWT refresh is handled by the ShphApiClient interceptor;
/// this manager only logs the state and prevents stale timers.
class TokenRefreshManager {
  factory TokenRefreshManager() => _instance;

  TokenRefreshManager._internal();
  static final TokenRefreshManager _instance = TokenRefreshManager._internal();

  Timer? _refreshTimer;

  /// Start monitoring and auto-refreshing the session token
  void startTokenRefreshMonitoring() {
    AuthLogger.debug(
      'Starting token refresh monitoring',
      tag: 'TokenRefresh',
    );
    AuthLogger.debug(
      'SHPH API mode enabled; JWT refresh handled by ShphApiClient interceptor',
      tag: 'TokenRefresh',
    );
    _refreshTimer?.cancel();
    _refreshTimer = Timer(
      const Duration(minutes: 1),
      _checkToken,
    );
  }

  Future<void> _checkToken() async {
    final hasToken = await ShphTokenStorage.hasAccessToken();
    if (!hasToken) {
      AuthLogger.debug('No SHPH token stored', tag: 'TokenRefresh');
    }
    _refreshTimer?.cancel();
    _refreshTimer = Timer(
      const Duration(minutes: 1),
      _checkToken,
    );
  }

  /// Stop monitoring token expiry
  void stopTokenRefreshMonitoring() {
    AuthLogger.debug('Stopping token refresh monitoring', tag: 'TokenRefresh');
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Get time until token expiry (for UI display, e.g., warning messages)
  Duration? getTimeUntilTokenExpiry() => null;

  /// Check if token is expired
  bool isTokenExpired() => false;
}
