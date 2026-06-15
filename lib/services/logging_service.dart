import 'package:flutter/foundation.dart';

/// Log levels for categorizing log messages
enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  critical,
}

/// Centralized logging service for the application
/// Replaces scattered debugPrint() calls with structured logging
class LoggingService {

  factory LoggingService() => _instance;

  LoggingService._internal();
  static final LoggingService _instance = LoggingService._internal();

  static const String _defaultTag = 'APP';
  static LogLevel _minLogLevel = kDebugMode ? LogLevel.verbose : LogLevel.info;

  /// Set the minimum log level (useful for environment-based configuration)
  static void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  /// Log verbose message (lowest priority)
  static void verbose(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.verbose, tag, message, error, stackTrace);
  }

  /// Log debug message
  static void debug(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.debug, tag, message, error, stackTrace);
  }

  /// Log info message
  static void info(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.info, tag, message, error, stackTrace);
  }

  /// Log warning message
  static void warning(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.warning, tag, message, error, stackTrace);
  }

  /// Log error message
  static void error(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, tag, message, error, stackTrace);
  }

  /// Log critical message (highest priority)
  static void critical(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.critical, tag, message, error, stackTrace);
  }

  /// Internal method that handles actual logging
  static void _log(
    LogLevel level,
    String tag,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // Only log if level meets minimum threshold
    if (level.index < _minLogLevel.index) {
      return;
    }

    // Format the log message
    final timestamp = _getTimestamp();
    final levelStr = _getLevelString(level);
    final errorMsg = error != null ? '\nError: $error' : '';
    final stackMsg = stackTrace != null ? '\nStack: $stackTrace' : '';

    final formattedMessage =
        '[$timestamp] [$levelStr] [$tag] $message$errorMsg$stackMsg';

    // Output to console/debugger
    if (kDebugMode) {
      // ignore: avoid_print
      print(formattedMessage);
    }

    // TODO: Integrate with crash reporting service (Sentry, Firebase Crashlytics)
    // if (level.index >= LogLevel.error.index) {
    //   CrashReportingService.recordError(error, stackTrace);
    // }
  }

  /// Get current timestamp in readable format
  static String _getTimestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
  }

  /// Get readable log level string with emoji
  static String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return '📝 VERBOSE';
      case LogLevel.debug:
        return '🐛 DEBUG';
      case LogLevel.info:
        return 'ℹ️  INFO';
      case LogLevel.warning:
        return '⚠️  WARN';
      case LogLevel.error:
        return '❌ ERROR';
      case LogLevel.critical:
        return '🚨 CRIT';
    }
  }
}

/// Extension for easier logging without importing the service
extension LoggingExtension on Object {
  void log(String message, {String tag = 'APP'}) {
    LoggingService.debug('$runtimeType: $message', tag: tag);
  }
}
