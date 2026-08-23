import '/api/shph_api_client.dart';

class ShphNotificationsPrefsApi {
  ShphNotificationsPrefsApi._();

  static final ShphNotificationsPrefsApi instance =
      ShphNotificationsPrefsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/notifications/preferences/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> updatePreferences(
      Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/notifications/preferences/update/',
      data: payload,
    );
    return response.data ?? {};
  }
}
