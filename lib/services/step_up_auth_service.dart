import '/services/biometric_service.dart';
import '/services/logging_service.dart';

typedef StepUpVerifier = Future<bool> Function(String reason);

/// Requires a verified device authentication result for sensitive actions.
///
/// Password fallback is intentionally excluded until the API exposes a
/// dedicated re-authentication endpoint. Collecting a password without
/// server-side verification is not a security boundary.
///
/// Adapted from `feature/sync-from-shph-main`'s
/// `lib/services/step_up_auth_service.dart` and its authentication-prompt
/// guardrail. This version returns only a verified boolean.
class StepUpAuthService {
  StepUpAuthService({StepUpVerifier? verifier})
      : _verifier = verifier ?? _verifyWithDeviceAuth;

  static final StepUpAuthService instance = StepUpAuthService();

  final StepUpVerifier _verifier;

  Future<bool> requireVerification({
    String reason = 'Confirm your identity to continue',
  }) async {
    try {
      return await _verifier(reason);
    } catch (error, stackTrace) {
      LoggingService.warning(
        'Step-up verification failed',
        tag: 'StepUpAuthService',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<bool> _verifyWithDeviceAuth(String reason) async {
    final biometrics = BiometricService.instance;
    if (!await biometrics.isAvailable()) {
      return false;
    }
    return biometrics.authenticate(reason: reason);
  }
}
