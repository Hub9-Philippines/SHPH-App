import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/auth/test_phone_accounts.dart';

void main() {
  test('maps mobile signup roles to the deployed API contract', () {
    expect(TestPhoneAccounts.apiRole('client'), 'client');
    expect(TestPhoneAccounts.apiRole('pro'), 'provider');
    expect(TestPhoneAccounts.apiRole('provider'), 'provider');
  });

  test('provides a distinct E.164 test phone for each role', () {
    expect(TestPhoneAccounts.phoneForRole('client'), '+639123456789');
    expect(TestPhoneAccounts.phoneForRole('pro'), '+639222222222');
    expect(TestPhoneAccounts.client, isNot(TestPhoneAccounts.provider));
  });
}
