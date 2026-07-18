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
      List<int> fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/me/photo/',
      data: formData,
    );
    return response.data ?? {};
  }

  Future<void> deleteMe() async {
    await _client.delete('/api/users/me/delete/');
  }

  /// GET `/api/users/notification-preferences/` — fetch notification prefs.
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/users/notification-preferences/',
    );
    return response.data ?? {};
  }

  /// PATCH `/api/users/notification-preferences/` — update notification prefs.
  Future<Map<String, dynamic>> updateNotificationPreferences(
    Map<String, dynamic> data,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/users/notification-preferences/',
      data: data,
    );
    return response.data ?? {};
  }

  /// POST `/api/users/enable-client/` — enable the client role for the user.
  Future<Map<String, dynamic>> enableClient() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/enable-client/',
    );
    return response.data ?? {};
  }

  /// POST `/api/users/apply-provider/` — apply to become a provider.
  Future<Map<String, dynamic>> applyProvider() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/apply-provider/',
    );
    return response.data ?? {};
  }
}
