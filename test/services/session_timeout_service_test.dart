import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/session_timeout_service.dart';

void main() {
  test('emits warning and timeout in order', () async {
    final service = SessionTimeoutService(
      inactiveTimeout: const Duration(milliseconds: 60),
      warningBefore: const Duration(milliseconds: 30),
    );
    addTearDown(service.dispose);

    final events = <SessionTimeoutEvent>[];
    final subscription = service.events.listen(events.add);
    addTearDown(subscription.cancel);

    service.start();
    await Future<void>.delayed(const Duration(milliseconds: 90));

    expect(
      events,
      [SessionTimeoutEvent.warning, SessionTimeoutEvent.timedOut],
    );
    expect(service.isRunning, isFalse);
  });

  test('activity resets the inactivity deadline', () async {
    final service = SessionTimeoutService(
      inactiveTimeout: const Duration(milliseconds: 80),
      warningBefore: const Duration(milliseconds: 20),
    );
    addTearDown(service.dispose);

    final events = <SessionTimeoutEvent>[];
    final subscription = service.events.listen(events.add);
    addTearDown(subscription.cancel);

    service.start();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    service.recordActivity();
    await Future<void>.delayed(const Duration(milliseconds: 45));

    expect(events, isEmpty);
    service.stop();
  });

  test('stop cancels pending events', () async {
    final service = SessionTimeoutService(
      inactiveTimeout: const Duration(milliseconds: 40),
      warningBefore: const Duration(milliseconds: 20),
    );
    addTearDown(service.dispose);

    final events = <SessionTimeoutEvent>[];
    final subscription = service.events.listen(events.add);
    addTearDown(subscription.cancel);

    service
      ..start()
      ..stop();
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(events, isEmpty);
  });
}
