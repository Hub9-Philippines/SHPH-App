class TestPhoneAccounts {
  TestPhoneAccounts._();

  static const bool enabled = bool.fromEnvironment(
    'ENABLE_TEST_PHONE_NUMBERS',
    defaultValue: false,
  );

  static const String client = '+639123456789';
  static const String provider = '+639222222222';

  static String apiRole(String role) => switch (role.trim().toLowerCase()) {
        'pro' || 'provider' => 'provider',
        _ => 'client',
      };

  static String phoneForRole(String role) =>
      apiRole(role) == 'provider' ? provider : client;
}
