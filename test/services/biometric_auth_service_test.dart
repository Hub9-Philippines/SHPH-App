import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/biometric_auth_service.dart';

void main() {
  group('BiometricAuthResult', () {
    test('contains expected values', () {
      const values = BiometricAuthResult.values;
      expect(values, contains(BiometricAuthResult.success));
      expect(values, contains(BiometricAuthResult.cancelled));
      expect(values, contains(BiometricAuthResult.notAvailable));
      expect(values, contains(BiometricAuthResult.notEnrolled));
      expect(values, contains(BiometricAuthResult.failed));
    });
  });

  group('BiometricAuthService', () {
    test('singleton instance is available', () {
      expect(BiometricAuthService.instance, isNotNull);
    });
  });
}
