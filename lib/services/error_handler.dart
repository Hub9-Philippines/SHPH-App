import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '/api/shph_api_exception.dart';
import 'logging_service.dart';

/// Centralized error handling for the application
/// Replaces scattered ScaffoldMessenger.showSnackBar() calls
class ErrorHandler {

  factory ErrorHandler() => _instance;

  ErrorHandler._internal();
  static final ErrorHandler _instance = ErrorHandler._internal();

  /// Message shown when a request never reaches the server.
  static const String connectionErrorMessage =
      'Cannot reach the server. Check your internet connection and try again.';

  /// Global scaffold messenger key for showing snackbars
  static GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// Show error snackbar with standard styling
  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
    String? actionLabel,
  }) {
    LoggingService.warning(message, tag: 'ErrorHandler');

    scaffoldMessengerKey?.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          duration: duration,
          action: onRetry != null
              ? SnackBarAction(
                  label: actionLabel ?? 'Retry',
                  textColor: Colors.white,
                  onPressed: onRetry,
                )
              : null,
        ),
      );
  }

  /// Show success snackbar
  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    LoggingService.info(message, tag: 'ErrorHandler');

    scaffoldMessengerKey?.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          duration: duration,
        ),
      );
  }

  /// Show info snackbar
  static void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    LoggingService.debug(message, tag: 'ErrorHandler');

    scaffoldMessengerKey?.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue.shade700,
          duration: duration,
        ),
      );
  }

  /// Show warning snackbar
  static void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    LoggingService.warning(message, tag: 'ErrorHandler');

    scaffoldMessengerKey?.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange.shade700,
          duration: duration,
        ),
      );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String actionLabel = 'OK',
    VoidCallback? onConfirm,
  }) {
    LoggingService.error(message, tag: 'ErrorHandler');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ).then((value) => value ?? false);

  /// Handle and display exception
  static void handleException(
    Object exception, {
    StackTrace? stackTrace,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final message = customMessage ?? _getErrorMessage(exception);

    LoggingService.error(
      message,
      tag: 'ErrorHandler',
      error: exception,
      stackTrace: stackTrace,
    );

    showError(message, onRetry: onRetry);
  }

  /// Parse exception to user-friendly message
  static String _getErrorMessage(Object exception) {
    if (exception is FormatException) {
      return 'Invalid format: ${exception.message}';
    } else if (exception is ArgumentError) {
      return 'Invalid argument: ${exception.message}';
    } else {
      return exception.toString();
    }
  }

  /// Map an exception to a user-facing message.
  ///
  /// Connection-level failures (no HTTP response ever received) map to
  /// [connectionErrorMessage]; `ShphApiException` surfaces its (already
  /// DRF-unwrapped) message; anything else falls back to a generic message.
  static String describeError(Object exception) {
    if (exception is ShphApiException) {
      if (exception.statusCode == null) {
        return connectionErrorMessage;
      }
      final message = exception.message.trim();
      return message.isEmpty
          ? 'Something went wrong. Please try again.'
          : message;
    }
    if (exception is DioException) {
      final isConnectionFailure = exception.type == DioExceptionType
              .connectionError ||
          exception.type == DioExceptionType.connectionTimeout ||
          exception.type == DioExceptionType.receiveTimeout ||
          exception.type == DioExceptionType.sendTimeout ||
          (exception.response == null &&
              exception.type == DioExceptionType.unknown);
      if (isConnectionFailure) {
        return connectionErrorMessage;
      }
      return 'Something went wrong. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
