import '/api/shph_api_client.dart';

class ShphSessionsApi {
  ShphSessionsApi._();

  static final ShphSessionsApi instance = ShphSessionsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> listSessions() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/auth/sessions/',
    );
    return response.data ?? {};
  }

  Future<void> revokeSession(String sessionId) async {
    await _client.delete('/api/auth/sessions/$sessionId/');
  }

  Future<void> revokeAllSessions() async {
    await _client.delete('/api/auth/sessions/revoke-all/');
  }
}
