import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/pages/registration/registration_validation.dart';

void main() {
  test('validates production registration fields', () {
    expect(RegistrationValidation.requiredName('Juan'), isNull);
    expect(RegistrationValidation.requiredName(''), isNotNull);
    expect(RegistrationValidation.email('juan@example.com'), isNull);
    expect(RegistrationValidation.email('bad'), isNotNull);
    expect(RegistrationValidation.phone('+639123456789'), isNull);
    expect(RegistrationValidation.phone('09123456789'), isNotNull);
    expect(RegistrationValidation.password('Strong123'), isNull);
    expect(RegistrationValidation.password('weak'), isNotNull);
  });
}
