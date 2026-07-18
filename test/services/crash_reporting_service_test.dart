import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/crash_reporting_service.dart';

void main() {
  group('CrashReportingService', () {
    test('isEnabled is false when no DSN or Firebase config is provided', () {
      expect(CrashReportingService.isEnabled, isFalse);
    });

    test('navigatorObserver is null when Sentry is not initialised', () {
      expect(CrashReportingService.navigatorObserver, isNull);
    });

    test('recordError is a no-op when reporters are disabled', () {
      expect(
        () => CrashReportingService.recordError(
          Exception('test error'),
          StackTrace.current,
          tag: 'Test',
        ),
        returnsNormally,
      );
    });

    test('recordMessage is a no-op when reporters are disabled', () {
      expect(
        () => CrashReportingService.recordMessage(
          'test message',
          tag: 'Test',
        ),
        returnsNormally,
      );
    });

    test('addBreadcrumb is a no-op when reporters are disabled', () {
      expect(
        () => CrashReportingService.addBreadcrumb(
          'navigated',
          category: 'navigation',
        ),
        returnsNormally,
      );
    });

    test('setUserId is a no-op when reporters are disabled', () {
      expect(
        () => CrashReportingService.setUserId('123'),
        returnsNormally,
      );
    });
  });
}
