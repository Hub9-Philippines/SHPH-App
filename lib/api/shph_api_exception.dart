import 'package:dio/dio.dart';

class ShphApiException implements Exception {
  ShphApiException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  factory ShphApiException.fromDio(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    var message = error.message ?? 'Request failed';
    if (data is Map && data['detail'] != null) {
      message = data['detail'].toString();
    } else if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    return ShphApiException(
      message: message,
      statusCode: statusCode,
      cause: error,
    );
  }

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => 'ShphApiException($statusCode): $message';
}
