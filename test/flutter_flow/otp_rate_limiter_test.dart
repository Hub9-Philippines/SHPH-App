import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/flutter_flow/otp_rate_limiter.dart';

void main() {
  final limiter = OtpRateLimiter();

  setUp(limiter.reset);
  tearDown(limiter.reset);

  test('rate limits equivalent formatted phone numbers', () {
    limiter.recordOtpRequest('+63 917-123-4567');

    final error = limiter.validateOtpRequest('+639171234567');

    expect(error, contains('Please wait'));
  });

  test('enforces the five request daily limit', () {
    for (var index = 0; index < 5; index++) {
      limiter.recordOtpRequest('+639171234567');
    }

    expect(
      limiter.validateOtpRequest('+639171234567'),
      contains('Too many verification attempts'),
    );
  });

  test('debug logs do not contain the phone number', () {
    final messages = <String>[];
    final previousDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message ?? '');
    addTearDown(() => debugPrint = previousDebugPrint);

    limiter
      ..recordOtpRequest('+639171234567')
      ..validateOtpRequest('+639171234567')
      ..clearPhoneNumber('+639171234567');

    expect(messages.join('\n'), isNot(contains('639171234567')));
  });
}
