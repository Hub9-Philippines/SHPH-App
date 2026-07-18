import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

typedef CrashReportSink = FutureOr<void> Function(CrashReport report);

@immutable
class CrashReport {
  const CrashReport({
    required this.error,
    required this.stackTrace,
    required this.fatal,
    required this.source,
  });

  final Object error;
  final StackTrace stackTrace;
  final bool fatal;
  final String source;
}

/// Dependency-free crash boundary adapted from
/// `feature/sync-from-shph-main`'s `CrashReportingService`.
///
/// The source implementation initializes Sentry and Firebase Crashlytics.
/// This safe port installs the same Flutter/platform error boundaries without
/// adding unconfigured telemetry SDKs, transmitting data, or attaching user
/// identifiers. A vetted reporter can be supplied later through the
/// initialization method's `sink` parameter.
class CrashReportingService {
  CrashReportingService._();

  static CrashReportSink? _sink;
  static FlutterExceptionHandler? _previousFlutterHandler;
  static ErrorCallback? _previousPlatformHandler;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;
  static bool get hasExternalSink => _sink != null;

  static Future<void> initialize({CrashReportSink? sink}) async {
    if (_initialized) {
      if (sink != null) {
        _sink = sink;
      }
      return;
    }

    _sink = sink;
    _previousFlutterHandler = FlutterError.onError;
    _previousPlatformHandler = PlatformDispatcher.instance.onError;

    FlutterError.onError = (details) {
      unawaited(
        recordError(
          details.exception,
          details.stack ?? StackTrace.current,
          fatal: true,
          source: 'flutter',
        ),
      );
      final previous = _previousFlutterHandler;
      if (previous != null) {
        previous(details);
      } else {
        FlutterError.presentError(details);
      }
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      unawaited(
        recordError(
          error,
          stackTrace,
          fatal: true,
          source: 'platform',
        ),
      );
      return _previousPlatformHandler?.call(error, stackTrace) ?? true;
    };

    _initialized = true;
  }

  static Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String source = 'application',
  }) async {
    final report = CrashReport(
      error: error,
      stackTrace: stackTrace,
      fatal: fatal,
      source: source,
    );
    final reporter = _sink;
    if (reporter != null) {
      await reporter(report);
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[CrashReporting][$source][${fatal ? 'fatal' : 'non-fatal'}] $error\n'
        '$stackTrace',
      );
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    if (_initialized) {
      FlutterError.onError = _previousFlutterHandler;
      PlatformDispatcher.instance.onError = _previousPlatformHandler;
    }
    _sink = null;
    _previousFlutterHandler = null;
    _previousPlatformHandler = null;
    _initialized = false;
  }
}
