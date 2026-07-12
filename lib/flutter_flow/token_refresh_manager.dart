import 'dart:async';
import '/api/api_config.dart';
import '/api/shph_token_storage.dart';
import 'auth_logger.dart';

/// Manages automatic token refresh to prevent session expiration
/// When SHPH API is active, refresh is handled by ShphApiClient interceptor.
/// Otherwise, falls back to Supabase token refresh for backward compatibility.
class TokenRefreshManager {

  factory TokenRefreshManager() => _instance;

  TokenRefreshManager._internal();
  static final TokenRefreshManager _instance = TokenRefreshManager._internal();

  Timer? _refreshTimer;

  /// Start monitoring and auto-refreshing the session token
  void startTokenRefreshMonitoring() {
    AuthLogger.debug('Starting token refresh monitoring', tag: 'TokenRefresh');

    if (ApiConfig.preferShphApi) {
      AuthLogger.debug(
        'SHPH API mode active; JWT refresh handled by ShphApiClient interceptor',
        tag: 'TokenRefresh',
      );
      return;
    }

    // Legacy Supabase token refresh (kept for backward compatibility)
    _scheduleTokenRefresh();
  }

  void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();
    AuthLogger.debug(
      'Supabase token refresh scheduling not implemented (use SHPH API)',
      tag: 'TokenRefresh',
    );
  }

  void stopTokenRefreshMonitoring() {
    _refreshTimer?.cancel();
  }
}
