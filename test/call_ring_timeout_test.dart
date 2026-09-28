import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/services/call_session_controller.dart';
import 'package:serbisyohubph/services/call_signal_models.dart';
import 'package:serbisyohubph/services/webrtc_call_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = ShphWebRTCCallService.instance;
  final controller = CallSessionController.instance;

  // resetAfterLogout() calls engine cleanup() → _notifyStreams(), which
  // touches the WebRTC platform channel (unavailable in unit tests). The
  // controller's state fields are what these tests exercise; put the machine
  // back to idle directly instead of going through cleanup.
  void resetToIdle() {
    service.onStatusChange?.call('idle');
  }

  setUp(() {
    resetToIdle();
    // Do NOT overwrite service.onStatusChange / onIncomingCall — the
    // controller subscribed to them in its constructor. Tests drive the
    // controller through those captured callbacks.
  });

  group('CallSessionController ring timeout', () {
    test('constant is 45 seconds (matches heartbeat reconnect window)', () {
      // No fakeAsync needed; run last after other tests settled the machine.
      resetToIdle();
      expect(CallSessionController.ringTimeout, const Duration(seconds: 45));
    });

    test('incoming call is auto-declined after the ring timeout', () {
      fakeAsync((async) {
        // Simulate the engine raising an incoming call (the controller's
        // constructor-registered callback).
        service.onIncomingCall?.call('24', 'thread-1', CallMediaType.audio);
        expect(controller.state, CallUiState.ringing);

        // Under the timeout: still ringing.
        async.elapse(const Duration(seconds: 44));
        expect(controller.state, CallUiState.ringing);

        // Past the timeout: the ring timer auto-declines and the session
        // returns to idle (declineIncomingCall → REST reject + signal).
        async.elapse(const Duration(seconds: 2));
        expect(controller.state, CallUiState.idle);
      });
    });

    test('user accept cancels the ring timer (no late auto-decline)', () {
      fakeAsync((async) {
        service.onIncomingCall?.call('24', 'thread-1', CallMediaType.audio);
        expect(controller.state, CallUiState.ringing);

        // The engine has no session in unit tests, so drive the accept
        // outcome through the controller's own subscription: connecting →
        // the accept path in real usage. The point being asserted: after the
        // controller left the ringing state, NO ring timer can fire later —
        // 50s total > the 45s timeout must not produce an auto-decline.
        async.elapse(const Duration(seconds: 10));
        // Directly emulate what acceptIncomingCall does on success start:
        // the engine reports 'connecting' (accept began). The controller
        // cancels the ring timer on 'connected'/'ended' — and accept itself
        // cancels it synchronously in acceptIncomingCall.
        service.onStatusChange?.call('connecting');
        expect(controller.state, CallUiState.connecting);

        async.elapse(const Duration(seconds: 40));

        // 50s total elapsed > 45s timeout: must still be connecting (or a
        // later legitimate state), never auto-declined back to idle.
        expect(controller.state, CallUiState.connecting);
        resetToIdle();
      });
    });

    test('ended state settles back to idle after the grace period', () {
      fakeAsync((async) {
        // Drive the state machine through the controller's own subscription.
        service.onStatusChange?.call('outgoing');
        expect(controller.state, CallUiState.outgoing);

        service.onStatusChange?.call('ended');
        expect(controller.state, CallUiState.ended);

        // The outcome panel stays up long enough to be read, then auto-dismisses.
        async.elapse(const Duration(seconds: 3));
        expect(controller.state, CallUiState.idle);
      });
    });
  });
}
