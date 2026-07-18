import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/step_up_auth_service.dart';

void main() {
  test('returns the verifier result and forwards the reason', () async {
    String? receivedReason;
    final service = StepUpAuthService(
      verifier: (reason) async {
        receivedReason = reason;
        return true;
      },
    );

    expect(
      await service.requireVerification(reason: 'Authorize payout'),
      isTrue,
    );
    expect(receivedReason, 'Authorize payout');
  });

  test('fails closed when the verifier throws', () async {
    final service = StepUpAuthService(
      verifier: (_) async => throw StateError('platform unavailable'),
    );

    expect(await service.requireVerification(), isFalse);
  });
}
