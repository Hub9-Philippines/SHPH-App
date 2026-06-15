import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_logger.dart';

/// Manages automatic token refresh to prevent session expiration
/// Monitors token expiry and refreshes before expiration occurs
class TokenRefreshManager {

  factory TokenRefreshManager() => _instance;

  TokenRefreshManager._internal();
  static final TokenRefreshManager _instance = TokenRefreshManager._internal();

  Timer? _refreshTimer;
  bool _isRefreshing = false;
  
  /// Duration before actual expiry to trigger refresh (e.g., 5 minutes before expiry)
  static const Duration _refreshBuffer = Duration(minutes: 5);
  
  /// Minimum interval between refresh attempts (prevents rapid refresh loops)
  static const Duration _minRefreshInterval = Duration(seconds: 10);
  DateTime? _lastRefreshAttempt;

  /// Start monitoring and auto-refreshing the session token
  void startTokenRefreshMonitoring() {
    AuthLogger.debug('Starting token refresh monitoring', tag: 'TokenRefresh');
    
    // Check token expiry immediately
    _scheduleTokenRefresh();
    
    // Also listen for auth state changes (login/logout)
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      AuthLogger.debug('Auth state changed: ${event.event}', tag: 'TokenRefresh');
      _refreshTimer?.cancel();
      _scheduleTokenRefresh();
    });
  }

  /// Schedule the next token refresh based on current token expiry
  void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();

    final session = Supabase.instance.client.auth.currentSession;
    
    if (session == null) {
      AuthLogger.debug('No active session for token refresh', tag: 'TokenRefresh');
      return;
    }

    final expiresAt = session.expiresAt;
    if (expiresAt == null) {
      AuthLogger.debug('Session has no expiry time', tag: 'TokenRefresh');
      return;
    }

    final now = DateTime.now();
    final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    final timeUntilExpiry = expiresAtDateTime.difference(now);

    // Calculate when to refresh (before expiry minus buffer time)
    final refreshTime = timeUntilExpiry - _refreshBuffer;

    AuthLogger.debug(
      'Token expires in ${timeUntilExpiry.inMinutes} minutes. '
      'Scheduling refresh in ${refreshTime.inMinutes} minutes.',
      tag: 'TokenRefresh',
    );

    if (refreshTime.isNegative || refreshTime.inSeconds < 30) {
      // Token expires soon or already expired, refresh immediately
      _performTokenRefresh();
    } else {
      // Schedule refresh for calculated time
      _refreshTimer = Timer(refreshTime, _performTokenRefresh);
    }
  }

  /// Perform the actual token refresh
  Future<void> _performTokenRefresh() async {
    // Prevent overlapping refresh attempts
    if (_isRefreshing) {
      AuthLogger.debug('Token refresh already in progress, skipping', tag: 'TokenRefresh');
      return;
    }

    // Enforce minimum interval between refresh attempts
    if (_lastRefreshAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(_lastRefreshAttempt!);
      if (timeSinceLastAttempt < _minRefreshInterval) {
        AuthLogger.debug(
          'Refresh attempted too soon (${timeSinceLastAttempt.inSeconds}s ago), waiting',
          tag: 'TokenRefresh',
        );
        _scheduleTokenRefresh();
        return;
      }
    }

    _isRefreshing = true;
    _lastRefreshAttempt = DateTime.now();

    try {
      AuthLogger.debug('Attempting to refresh session token', tag: 'TokenRefresh');
      
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session == null) {
        AuthLogger.debug('No session available for refresh', tag: 'TokenRefresh');
        _isRefreshing = false;
        return;
      }

      // Refresh the session - Supabase handles this automatically
      // but we explicitly call it for security monitoring
      final refreshToken = session.refreshToken;
      if (refreshToken == null) {
        AuthLogger.error(
          'No refresh token available for session refresh',
          tag: 'TokenRefresh',
        );
        _isRefreshing = false;
        _scheduleTokenRefresh();
        return;
      }

      // Attempt to refresh session
      await Supabase.instance.client.auth.refreshSession();
      
      AuthLogger.debug('Session token refreshed successfully', tag: 'TokenRefresh');
      
      // Reschedule the next refresh
      _scheduleTokenRefresh();
    } on AuthException catch (e) {
      AuthLogger.error(
        'Failed to refresh token - ${e.message}',
        tag: 'TokenRefresh',
        error: e,
      );
      
      // If refresh failed, reschedule for retry (shorter interval)
      _refreshTimer = Timer(const Duration(minutes: 1), _performTokenRefresh);
    } catch (e) {
      AuthLogger.error(
        'Unexpected error during token refresh',
        tag: 'TokenRefresh',
        error: e,
      );
      
      // Reschedule for retry
      _refreshTimer = Timer(const Duration(minutes: 1), _performTokenRefresh);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Stop monitoring token expiry
  void stopTokenRefreshMonitoring() {
    AuthLogger.debug('Stopping token refresh monitoring', tag: 'TokenRefresh');
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Get time until token expiry (for UI display, e.g., warning messages)
  Duration? getTimeUntilTokenExpiry() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null || session.expiresAt == null) {
      return null;
    }

    final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
    final timeUntilExpiry = expiresAtDateTime.difference(DateTime.now());

    return timeUntilExpiry.isNegative ? Duration.zero : timeUntilExpiry;
  }

  /// Check if token is expired
  bool isTokenExpired() {
    final timeUntilExpiry = getTimeUntilTokenExpiry();
    return timeUntilExpiry == null || timeUntilExpiry.inSeconds <= 0;
  }
}
