import 'package:dio/dio.dart';
import '/api/shph_api_client.dart';

/// Users endpoints from SHPH API.yaml (`/api/users/*`).
class ShphUsersApi {
  ShphUsersApi._();

  static final ShphUsersApi instance = ShphUsersApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getMe() async {
    final response = await _client.get<Map<String, dynamic>>('/api/users/me/');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/users/me/update/',
      data: data,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> uploadPhoto(
    List<int> fileBytes,
    String fileName, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/me/photo/',
      data: formData,
      onSendProgress: onSendProgress == null
          ? null
          : (sent, total) => onSendProgress(sent, total),
    );
    return response.data ?? {};
  }

  Future<void> deleteMe() async {
    await _client.delete('/api/users/me/delete/');
  }
}
