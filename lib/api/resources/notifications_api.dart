import '/api/shph_api_client.dart';

class ShphNotificationsApi {
  ShphNotificationsApi._();

  static final ShphNotificationsApi instance = ShphNotificationsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> listNotifications({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/notifications/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> registerDevice({
    required String token,
    required String platform,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/users/notifications/register/',
      data: {'token': token, 'platform': platform},
    );
    return response.data ?? {};
  }

  Future<void> unregisterDevice({required String token}) async {
    await _client.post(
      '/api/users/notifications/unregister/',
      data: {'token': token},
    );
  }

  Future<void> markAllRead() async {
    await _client.post('/api/notifications/mark-all-read/');
  }

  Future<void> markRead(String id) async {
    await _client.patch('/api/notifications/$id/', data: const {
      'is_read': true,
    });
  }

  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/notifications/preferences/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> updatePreferences(
      Map<String, dynamic> prefs) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/notifications/preferences/',
      data: prefs,
    );
    return response.data ?? {};
  }
}
