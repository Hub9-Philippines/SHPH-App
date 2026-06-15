import 'package:flutter/foundation.dart';

/// Secure logging utility for auth operations
/// Only logs in debug mode to prevent sensitive data exposure in production
class AuthLogger {
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[Auth]';
      debugPrint('$prefix $message');
    }
  }

  static void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[Auth]';
      debugPrint('$prefix ERROR: $message');
      if (error != null) {
        debugPrint('$prefix Exception: $error');
      }
      if (stackTrace != null) {
        debugPrint('$prefix StackTrace: $stackTrace');
      }
    }
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[Auth]';
      debugPrint('$prefix WARNING: $message');
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[Auth]';
      debugPrint('$prefix INFO: $message');
    }
  }
}
