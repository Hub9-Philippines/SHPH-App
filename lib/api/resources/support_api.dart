import 'package:dio/dio.dart';
import '/api/shph_api_client.dart';

class ShphSupportApi {
  ShphSupportApi._();

  static final ShphSupportApi instance = ShphSupportApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> createTicket({
    required String category,
    required String message,
    List<int>? attachmentBytes,
    String? attachmentFileName,
  }) async {
    final data = <String, dynamic>{
      'category': category,
      'message': message,
    };
    if (attachmentBytes != null && attachmentFileName != null) {
      final formData = FormData.fromMap({
        ...data,
        'attachments': MultipartFile.fromBytes(
          attachmentBytes,
          filename: attachmentFileName,
        ),
      });
      final response = await _client.post<Map<String, dynamic>>(
        '/api/support/tickets/',
        data: formData,
      );
      return response.data ?? {};
    }
    final response = await _client.post<Map<String, dynamic>>(
      '/api/support/tickets/',
      data: data,
    );
    return response.data ?? {};
  }
}
