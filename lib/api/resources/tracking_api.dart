import '/api/shph_api_client.dart';

class ShphTrackingApi {
  ShphTrackingApi._();

  static final ShphTrackingApi instance = ShphTrackingApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getEta(String token) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/eta/$token/',
    );
    return response.data ?? {};
  }
}
