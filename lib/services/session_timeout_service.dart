import 'dart:async';

import 'package:flutter/material.dart';

import '/auth/shph_auth/auth_util.dart';
import '/services/logging_service.dart';

class SessionTimeoutService {
  SessionTimeoutService._();
  static final SessionTimeoutService instance = SessionTimeoutService._();

  static const _inactiveTimeout = Duration(minutes: 30);
  static const _warningBefore = Duration(minutes: 2);

  Timer? _timeoutTimer;
  Timer? _warningTimer;
  VoidCallback? onTimeout;
  VoidCallback? onWarning;

  void start() {
    if (!loggedIn) return;
    _resetTimers();
  }

  void stop() {
    _timeoutTimer?.cancel();
    _warningTimer?.cancel();
    _timeoutTimer = null;
    _warningTimer = null;
  }

  void reset() {
    _resetTimers();
  }

  void _resetTimers() {
    _timeoutTimer?.cancel();
    _warningTimer?.cancel();

    if (!loggedIn) return;

    _warningTimer = Timer(_inactiveTimeout - _warningBefore, () {
      LoggingService.info(
          'Session about to expire — 2 min warning', tag: 'SessionTimeout');
      onWarning?.call();
    });

    _timeoutTimer = Timer(_inactiveTimeout, () {
      LoggingService.info('Session timed out — logging out',
          tag: 'SessionTimeout');
      onTimeout?.call();
    });
  }
}

/// Mixin that tracks user activity (tap, scroll, key press) and resets
/// the session timeout timer. Attach to any StatefulWidget that represents
/// an authenticated screen.
mixin SessionTimeoutTracker<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    SessionTimeoutService.instance.start();
  }

  void onUserActivity() {
    SessionTimeoutService.instance.reset();
  }

  @override
  void dispose() {
    SessionTimeoutService.instance.stop();
    super.dispose();
  }
}
