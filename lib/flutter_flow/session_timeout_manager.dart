import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_logger.dart';

/// Manages session timeout based on user inactivity
/// Automatically signs out user after configurable period of inactivity
class SessionTimeoutManager {

  factory SessionTimeoutManager() => _instance;

  SessionTimeoutManager._internal();
  static final SessionTimeoutManager _instance = SessionTimeoutManager._internal();

  Timer? _inactivityTimer;
  Timer? _warningTimer;
  bool _isInitialized = false;
  bool _isTimedOut = false;

  /// Timeout duration after inactivity (30 minutes by default)
  static const Duration _sessionTimeout = Duration(minutes: 30);

  /// Warning duration before timeout (5 minutes before timeout)
  static const Duration _warningDuration = Duration(minutes: 5);

  /// Callback when warning is triggered (before timeout)
  VoidCallback? _onWarning;

  /// Callback when session times out
  VoidCallback? _onTimeout;

  /// Initialize session timeout management with callbacks
  void initialize({
    required VoidCallback onWarning,
    required VoidCallback onTimeout,
  }) {
    if (_isInitialized) {
      AuthLogger.debug('SessionTimeoutManager already initialized', tag: 'SessionTimeout');
      return;
    }

    _onWarning = onWarning;
    _onTimeout = onTimeout;
    _isInitialized = true;

    AuthLogger.debug(
      'Initialized SessionTimeoutManager with ${_sessionTimeout.inMinutes}min timeout',
      tag: 'SessionTimeout',
    );

    // Start monitoring for inactivity
    _resetInactivityTimer();
  }

  /// Record user activity and reset the inactivity timer
  /// Call this whenever user interacts with the app (taps, scrolls, text input, etc.)
  void recordUserActivity({String? activityType}) {
    if (!_isInitialized) {
      return;
    }

    if (_isTimedOut) {
      AuthLogger.debug('Session already timed out, ignoring activity', tag: 'SessionTimeout');
      return;
    }

    final activityInfo = activityType != null ? ' ($activityType)' : '';
    AuthLogger.debug('User activity recorded$activityInfo', tag: 'SessionTimeout');

    _resetInactivityTimer();
  }

  /// Reset the inactivity timer (restarts the countdown)
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();

    // Set warning timer (fires 5 minutes before timeout)
    _warningTimer = Timer(_sessionTimeout - _warningDuration, _triggerWarning);

    // Set main timeout timer
    _inactivityTimer = Timer(_sessionTimeout, _triggerTimeout);

    AuthLogger.debug(
      'Inactivity timer reset (timeout in ${_sessionTimeout.inMinutes} minutes)',
      tag: 'SessionTimeout',
    );
  }

  /// Trigger warning callback when approaching timeout
  void _triggerWarning() {
    AuthLogger.debug(
      'Session warning triggered (timeout in ${_warningDuration.inMinutes} minutes)',
      tag: 'SessionTimeout',
    );

    _onWarning?.call();
  }

  /// Trigger timeout callback when inactivity limit exceeded
  void _triggerTimeout() {
    AuthLogger.debug('Session timeout triggered due to inactivity', tag: 'SessionTimeout');

    _isTimedOut = true;
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();

    _onTimeout?.call();
  }

  /// Dismiss warning and reset timeout (user acknowledges they're still using the app)
  void dismissWarning() {
    if (!_isInitialized || _isTimedOut) {
      return;
    }

    AuthLogger.debug('Timeout warning dismissed by user', tag: 'SessionTimeout');
    _resetInactivityTimer();
  }

  /// Get remaining time before session timeout
  Duration getRemainingSessionTime() {
    if (!_isInitialized || _isTimedOut) {
      return Duration.zero;
    }

    // This is a simplified calculation - in production, track actual creation time
    return _sessionTimeout;
  }

  /// Check if session is currently timed out
  bool isSessionTimedOut() => _isTimedOut;

  /// Reset session timeout state (e.g., when user logs back in)
  void resetTimeoutState() {
    AuthLogger.debug('Resetting session timeout state', tag: 'SessionTimeout');

    _isTimedOut = false;
    _resetInactivityTimer();
  }

  /// Stop session timeout management
  void dispose() {
    AuthLogger.debug('Disposing SessionTimeoutManager', tag: 'SessionTimeout');

    _inactivityTimer?.cancel();
    _warningTimer?.cancel();
    _isInitialized = false;
    _isTimedOut = false;
  }
}

/// Widget that captures user gestures and records activity
/// Wrap your main app widget with this to track all user interactions
class SessionTimeoutGestureDetector extends StatelessWidget {

  const SessionTimeoutGestureDetector({
    required this.child, required this.timeoutManager, Key? key,
    this.excludeFromSemantics,
  }) : super(key: key);
  final Widget child;
  final SessionTimeoutManager timeoutManager;
  final bool? excludeFromSemantics;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTapDown: (_) => timeoutManager.recordUserActivity(activityType: 'tap'),
      onPanDown: (_) => timeoutManager.recordUserActivity(activityType: 'pan'),
      onLongPressDown: (_) => timeoutManager.recordUserActivity(activityType: 'longPress'),
      onVerticalDragDown: (_) => timeoutManager.recordUserActivity(activityType: 'verticalDrag'),
      onHorizontalDragDown: (_) => timeoutManager.recordUserActivity(activityType: 'horizontalDrag'),
      excludeFromSemantics: excludeFromSemantics ?? false,
      behavior: HitTestBehavior.translucent,
      child: child,
    );
}

/// Dialog shown to user when session warning is triggered
class SessionTimeoutWarningDialog extends StatelessWidget {

  const SessionTimeoutWarningDialog({
    required this.timeoutManager, Key? key,
    this.onStayLoggedIn,
    this.onLogout,
  }) : super(key: key);
  final SessionTimeoutManager timeoutManager;
  final VoidCallback? onStayLoggedIn;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: const Text('Session Expiring Soon'),
      content: Text(
        'You have been inactive for a while. Your session will expire in ${_warningDuration.inMinutes} minutes for security reasons.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            timeoutManager.dismissWarning();
            onStayLoggedIn?.call();
            Navigator.of(context).pop();
          },
          child: const Text('Stay Logged In'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onLogout?.call();
          },
          child: const Text('Logout'),
        ),
      ],
    );
}

const Duration _warningDuration = SessionTimeoutManager._warningDuration;
