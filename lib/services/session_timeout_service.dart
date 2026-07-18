import 'dart:async';

enum SessionTimeoutEvent { warning, timedOut }

/// Emits inactivity events without directly mutating authentication state.
///
/// The application decides how to warn or sign out the current user when an
/// event occurs. This keeps timers testable and prevents navigation from a
/// service that has no valid widget context.
class SessionTimeoutService {
  SessionTimeoutService({
    this.inactiveTimeout = const Duration(minutes: 30),
    this.warningBefore = const Duration(minutes: 2),
  }) : assert(
          warningBefore < inactiveTimeout,
          'warningBefore must be shorter than inactiveTimeout',
        );

  static final SessionTimeoutService instance = SessionTimeoutService();

  final Duration inactiveTimeout;
  final Duration warningBefore;
  final StreamController<SessionTimeoutEvent> _events =
      StreamController<SessionTimeoutEvent>.broadcast();

  Timer? _warningTimer;
  Timer? _timeoutTimer;
  bool _running = false;

  Stream<SessionTimeoutEvent> get events => _events.stream;
  bool get isRunning => _running;

  void start() {
    _running = true;
    _schedule();
  }

  void recordActivity() {
    if (_running) {
      _schedule();
    }
  }

  void stop() {
    _running = false;
    _warningTimer?.cancel();
    _timeoutTimer?.cancel();
    _warningTimer = null;
    _timeoutTimer = null;
  }

  Future<void> dispose() async {
    stop();
    await _events.close();
  }

  void _schedule() {
    _warningTimer?.cancel();
    _timeoutTimer?.cancel();
    _warningTimer = Timer(
      inactiveTimeout - warningBefore,
      () => _events.add(SessionTimeoutEvent.warning),
    );
    _timeoutTimer = Timer(inactiveTimeout, () {
      _running = false;
      _events.add(SessionTimeoutEvent.timedOut);
    });
  }
}
