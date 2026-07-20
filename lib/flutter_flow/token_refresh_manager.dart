import 'dart:async';
import 'dart:convert';

import '/api/shph_token_storage.dart';
import 'auth_logger.dart';

enum TokenExpiryEvent { expiringSoon, expired }

/// Monitors SHPH JWT expiry while refresh remains owned by the API client.
///
/// Adapted from `feature/sync-from-shph-main`'s token monitor. Unlike the
/// source implementation, this guardrail does not clear an expired access
/// token because doing so would also discard a potentially valid refresh
/// token before the API client's 401 interceptor can rotate it.
class TokenRefreshManager {
  factory TokenRefreshManager() => _instance;

  TokenRefreshManager._internal();

  static final TokenRefreshManager _instance = TokenRefreshManager._internal();
  static const Duration _checkInterval = Duration(minutes: 5);
  static const Duration _expiryWarning = Duration(minutes: 5);

  final StreamController<TokenExpiryEvent> _events =
      StreamController<TokenExpiryEvent>.broadcast();
  Timer? _timer;
  TokenExpiryEvent? _lastEvent;

  Stream<TokenExpiryEvent> get events => _events.stream;
  bool get isMonitoring => _timer?.isActive ?? false;

  void startTokenRefreshMonitoring() {
    AuthLogger.debug(
      'Starting SHPH token expiry monitoring',
      tag: 'TokenRefresh',
    );
    _timer?.cancel();
    _timer = Timer.periodic(
      _checkInterval,
      (_) => unawaited(checkTokenNow()),
    );
    unawaited(checkTokenNow());
  }

  void stopTokenRefreshMonitoring() {
    _timer?.cancel();
    _timer = null;
    _lastEvent = null;
  }

  Future<Duration?> checkTokenNow() async {
    final remaining = await getTimeUntilTokenExpiry();
    if (remaining == null) {
      _lastEvent = null;
      return null;
    }

    final event = remaining == Duration.zero
        ? TokenExpiryEvent.expired
        : remaining <= _expiryWarning
            ? TokenExpiryEvent.expiringSoon
            : null;
    if (event != null && event != _lastEvent) {
      _events.add(event);
      _lastEvent = event;
      AuthLogger.warning(
        event == TokenExpiryEvent.expired
            ? 'SHPH access token has expired; awaiting secure refresh'
            : 'SHPH access token will expire soon',
        tag: 'TokenRefresh',
      );
    } else if (event == null) {
      _lastEvent = null;
    }
    return remaining;
  }

  Future<Duration?> getTimeUntilTokenExpiry() async {
    final token = await ShphTokenStorage.getAccessToken();
    final expiry = token == null ? null : extractExpiry(token);
    if (expiry == null) {
      return null;
    }
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<bool> isTokenExpired() async {
    final remaining = await getTimeUntilTokenExpiry();
    return remaining != null && remaining == Duration.zero;
  }

  static DateTime? extractExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      final decoded =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payload = jsonDecode(decoded);
      if (payload is! Map<String, dynamic>) {
        return null;
      }
      final expiry = payload['exp'];
      if (expiry is int) {
        return DateTime.fromMillisecondsSinceEpoch(expiry * 1000, isUtc: true);
      }
      if (expiry is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          expiry.toInt() * 1000,
          isUtc: true,
        );
      }
      return null;
    } on FormatException {
      return null;
    } on Object {
      return null;
    }
  }
}
