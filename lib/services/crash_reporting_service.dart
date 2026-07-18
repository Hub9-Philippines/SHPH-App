import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'log_level.dart';

/// Centralized crash reporting wrapper for Sentry and Firebase Crashlytics.
///
/// Both reporters are optional: if the DSN / Firebase project is not configured,
/// the service stays inert so builds and tests keep working without secrets.
class CrashReportingService {
  CrashReportingService._();

  static final CrashReportingService _instance = CrashReportingService._();
  static CrashReportingService get instance => _instance;

  /// Sentry DSN from build-time environment (`--dart-define=SENTRY_DSN=...`).
  /// Empty by default so Sentry is skipped unless explicitly configured.
  static const String _sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static bool _sentryReady = false;
  static bool _crashlyticsReady = false;
  static bool _initAttempted = false;

  /// Whether any reporter is active.
  static bool get isEnabled => _sentryReady || _crashlyticsReady;

  /// Initialize Sentry and Firebase Crashlytics.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops.
  static Future<void> initialize() async {
    if (_initAttempted) {
      return;
    }
    _initAttempted = true;

    await _initializeSentry();
    await _initializeCrashlytics();

    if (!isEnabled) {
      _debug(
        'Crash reporting disabled: no SENTRY_DSN or Firebase config found.',
      );
    }
  }

  static Future<void> _initializeSentry() async {
    if (_sentryDsn.isEmpty) {
      return;
    }
    if (_sentryReady) {
      return;
    }

    try {
      await SentryFlutter.init(
        (options) {
          options
            ..dsn = _sentryDsn
            ..environment = const String.fromEnvironment(
              'SENTRY_ENVIRONMENT',
              defaultValue: 'development',
            )
            ..release = const String.fromEnvironment('SENTRY_RELEASE')
            ..debug = kDebugMode
            ..sendDefaultPii = false;
        },
      );
      _sentryReady = true;
      _debug('Sentry initialized');
    } catch (e, stackTrace) {
      _debug('Failed to initialize Sentry', error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> _initializeCrashlytics() async {
    if (_crashlyticsReady) {
      return;
    }

    try {
      // Firebase will throw if the native project is not configured. Catch and
      // disable gracefully so builds without google-services.json still run.
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
          appId: String.fromEnvironment('FIREBASE_APP_ID'),
          messagingSenderId:
              String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
          projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
          storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
        ),
      );
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      _crashlyticsReady = true;
      _debug('Firebase Crashlytics initialized');
    } catch (e, stackTrace) {
      _debug(
        'Firebase Crashlytics not initialized (config missing or invalid)',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Record a non-fatal error (or fatal if [fatal] is true) to all enabled
  /// reporters.
  static void recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? tag,
    bool fatal = false,
    Map<String, dynamic>? context,
  }) {
    if (_sentryReady) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope
            ..setTag('tag', tag ?? 'CrashReporting')
            ..level = fatal ? SentryLevel.fatal : SentryLevel.error;
          if (context != null) {
            scope.setContexts('context', context);
          }
        },
      );
    }

    if (_crashlyticsReady) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: fatal,
        information: [
          if (tag != null) 'tag: $tag',
          if (context != null)
            ...context.entries.map((e) => '${e.key}: ${e.value}'),
        ],
      );
    }
  }

  /// Record a breadcrumb/message to all enabled reporters.
  static void recordMessage(
    String message, {
    LogLevel level = LogLevel.info,
    String tag = 'CrashReporting',
    Map<String, dynamic>? context,
  }) {
    if (_sentryReady) {
      Sentry.captureMessage(
        message,
        level: _toSentryLevel(level),
        withScope: (scope) {
          scope.setTag('tag', tag);
          if (context != null) {
            scope.setContexts('context', context);
          }
        },
      );
    }

    if (_crashlyticsReady) {
      FirebaseCrashlytics.instance.log('[$tag] $message');
      if (context != null) {
        for (final entry in context.entries) {
          FirebaseCrashlytics.instance
              .setCustomKey(entry.key, entry.value.toString());
        }
      }
    }
  }

  /// Add a breadcrumb (navigation, user action, etc.) without creating an issue.
  static void addBreadcrumb(
    String message, {
    String category = 'app',
    Map<String, dynamic>? data,
  }) {
    if (_sentryReady) {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          data: data,
        ),
      );
    }

    if (_crashlyticsReady) {
      FirebaseCrashlytics.instance.log('$category: $message');
    }
  }

  /// Identify the current user. Pass `null` to clear.
  static void setUserId(String? userId) {
    if (userId == null) {
      if (_sentryReady) {
        Sentry.configureScope((scope) => scope.setUser(null));
      }
      if (_crashlyticsReady) {
        FirebaseCrashlytics.instance.setUserIdentifier('');
      }
      return;
    }

    if (_sentryReady) {
      Sentry.configureScope((scope) => scope.setUser(SentryUser(id: userId)));
    }
    if (_crashlyticsReady) {
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
  }

  static SentryLevel _toSentryLevel(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
      case LogLevel.debug:
        return SentryLevel.debug;
      case LogLevel.info:
        return SentryLevel.info;
      case LogLevel.warning:
        return SentryLevel.warning;
      case LogLevel.error:
        return SentryLevel.error;
      case LogLevel.critical:
        return SentryLevel.fatal;
    }
  }

  /// Returns a Sentry navigation observer if Sentry is enabled, otherwise null.
  /// Add this to the router observers or navigator observers list.
  static SentryNavigatorObserver? get navigatorObserver =>
      _sentryReady ? SentryNavigatorObserver() : null;

  static void _debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[CrashReporting] $message ${error ?? ''} ${stackTrace ?? ''}');
    }
  }
}
