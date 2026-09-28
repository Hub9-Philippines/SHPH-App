import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/services/call_session_controller.dart';
import 'package:serbisyohubph/services/call_signal_models.dart';
import 'package:serbisyohubph/services/webrtc_call_service.dart';

/// The in-call surface is a global overlay with a minimize control (web
/// parity with `VideoCallOverlay.vue`), so the collapse state lives on the
/// session controller rather than in any pushed route.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = ShphWebRTCCallService.instance;
  final controller = CallSessionController.instance;

  // resetAfterLogout() reaches into the WebRTC platform channel; put the
  // machine back to idle through the engine's status callback instead.
  void resetToIdle() => service.onStatusChange?.call('idle');

  setUp(resetToIdle);
  tearDown(resetToIdle);

  group('CallSessionController minimize/expand', () {
    test('starts expanded so a new call never appears pre-collapsed', () {
      expect(controller.isMinimized, isFalse);
    });

    test('minimize and expand flip the flag and notify listeners', () {
      var notifications = 0;
      void onChange() => notifications++;
      controller.addListener(onChange);
      addTearDown(() => controller.removeListener(onChange));

      controller.minimize();
      expect(controller.isMinimized, isTrue);
      expect(notifications, 1);

      controller.expand();
      expect(controller.isMinimized, isFalse);
      expect(notifications, 2);
    });

    test('toggleMinimized flips in both directions', () {
      controller.toggleMinimized();
      expect(controller.isMinimized, isTrue);

      controller.toggleMinimized();
      expect(controller.isMinimized, isFalse);
    });

    test('expanding twice is idempotent (no spurious notifications)', () {
      var notifications = 0;
      void onChange() => notifications++;
      controller.addListener(onChange);
      addTearDown(() => controller.removeListener(onChange));

      controller.expand();
      expect(notifications, 0);
    });

    test('an incoming call un-minimizes so the overlay is visible', () {
      controller.minimize();
      expect(controller.isMinimized, isTrue);

      service.onIncomingCall?.call('24', 'thread-1', CallMediaType.audio);

      expect(controller.state, CallUiState.ringing);
      expect(controller.isMinimized, isFalse);
    });

    test('ending a minimized call resets the flag for the next call', () {
      controller.minimize();

      service.onStatusChange?.call('outgoing');
      service.onStatusChange?.call('active');
      controller.minimize();
      expect(controller.isMinimized, isTrue);

      service.onStatusChange?.call('ended');
      expect(controller.isMinimized, isFalse);
    });
  });

  group('CallSessionController call outcome panel', () {
    test('a declined/ended call is readable, then auto-dismisses', () {
      fakeAsync((async) {
        service.onStatusChange?.call('ended');
        expect(controller.state, CallUiState.ended);

        // Still up just before the grace period, so the reason is readable.
        async.elapse(const Duration(milliseconds: 2900));
        expect(controller.state, CallUiState.ended);

        async.elapse(const Duration(milliseconds: 200));
        expect(controller.state, CallUiState.idle);
      });
    });

    test('dismissing early returns to idle without waiting for the timer', () {
      fakeAsync((async) {
        service.onStatusChange?.call('ended');
        expect(controller.state, CallUiState.ended);

        controller.dismissCallOutcome();
        expect(controller.state, CallUiState.idle);

        // The pending grace timer must not clobber later state.
        async.elapse(const Duration(seconds: 5));
        expect(controller.state, CallUiState.idle);
      });
    });

    test('a failure auto-dismisses instead of parking in a terminal state', () {
      fakeAsync((async) {
        // Failures only register while a call is live.
        service.onStatusChange?.call('connecting');
        expect(controller.state, CallUiState.connecting);

        service.onCallFailed?.call('connectionFailed');
        expect(controller.state, CallUiState.failed);
        expect(controller.lastEndReason, 'connectionFailed');

        async.elapse(const Duration(seconds: 3));
        expect(controller.state, CallUiState.idle);
      });
    });

    test('dismissing is a no-op while a call is still live', () {
      service.onStatusChange?.call('connecting');
      expect(controller.state, CallUiState.connecting);

      controller.dismissCallOutcome();
      expect(controller.state, CallUiState.connecting);
    });
  });
}
