import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/crash_reporting_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(CrashReportingService.resetForTesting);

  test('is inert until initialized', () {
    expect(CrashReportingService.isInitialized, isFalse);
    expect(CrashReportingService.hasExternalSink, isFalse);
  });

  test('forwards explicit reports to an injected sink', () async {
    final reports = <CrashReport>[];
    await CrashReportingService.initialize(sink: reports.add);
    final stackTrace = StackTrace.current;

    await CrashReportingService.recordError(
      StateError('test failure'),
      stackTrace,
      source: 'test',
    );

    expect(reports, hasLength(1));
    expect(reports.single.error, isA<StateError>());
    expect(reports.single.stackTrace, same(stackTrace));
    expect(reports.single.source, 'test');
    expect(reports.single.fatal, isFalse);
  });

  test('initialization is idempotent and accepts a later sink', () async {
    final reports = <CrashReport>[];
    await CrashReportingService.initialize();
    await CrashReportingService.initialize(sink: reports.add);

    await CrashReportingService.recordError(
      Exception('captured'),
      StackTrace.current,
    );

    expect(CrashReportingService.isInitialized, isTrue);
    expect(CrashReportingService.hasExternalSink, isTrue);
    expect(reports, hasLength(1));
  });

  test('does not attach user identity or arbitrary context', () async {
    final reports = <CrashReport>[];
    await CrashReportingService.initialize(sink: reports.add);

    await CrashReportingService.recordError(
      Exception('safe payload'),
      StackTrace.current,
      fatal: true,
      source: 'platform',
    );

    final report = reports.single;
    expect(report.fatal, isTrue);
    expect(report.source, 'platform');
    expect(report.toString(), isNot(contains('userId')));
  });
}
