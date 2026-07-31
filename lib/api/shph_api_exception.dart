import 'package:dio/dio.dart';

class ShphApiException implements Exception {
  ShphApiException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Object? cause;

  factory ShphApiException.fromDio(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = error.message ?? 'Request failed';
    final extracted = _extractDrfMessage(data);
    if (extracted != null && extracted.isNotEmpty) {
      message = extracted;
    }

    return ShphApiException(
      message: message,
      statusCode: statusCode,
      cause: error,
    );
  }

  /// Mirrors the web app's `extractDrfMessage`: unwraps the SHPH API's
  /// `{ error: true, detail: <original> }` envelope (and plain DRF bodies),
  /// returning the first usable string detail / field error.
  static String? _extractDrfMessage(Object? data) {
    if (data is String) {
      final text = data.trim();
      if (text.isEmpty) return null;
      if (text.startsWith('<') ||
          RegExp(r'</?(html|body|head|pre)\b', caseSensitive: false)
              .hasMatch(text)) {
        return null;
      }
      return text;
    }
    if (data is! Map) return null;

    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) return detail;

    final nonField = data['non_field_errors'];
    if (nonField is List && nonField.isNotEmpty) {
      for (final item in nonField) {
        if (item is String && item.trim().isNotEmpty) return item;
      }
    }

    final collected = <String>[];
    for (final value in data.values) {
      if (value is String && value.trim().isNotEmpty) {
        collected.add(value);
      } else if (value is List) {
        for (final item in value) {
          if (item is String && item.trim().isNotEmpty) {
            collected.add(item);
          }
        }
      }
    }
    if (collected.isNotEmpty) return collected.join(' ');

    if (detail is Map) return _extractDrfMessage(detail);

    return null;
  }

  @override
  String toString() =>
      'ShphApiException($statusCode): $message';
}
