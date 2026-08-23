import '/api/shph_api_client.dart';

class ShphProjectsApi {
  ShphProjectsApi._();

  static final ShphProjectsApi instance = ShphProjectsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> list() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/list/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/',
      data: payload,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> detail(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/$id/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> quote(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/$id/quote/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> match(String id, int roleLineId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/projects/$id/match/',
      data: {'role_line': roleLineId},
    );
    return response.data ?? {};
  }

  Future<void> cancel(String id) async {
    await _client.post('/api/projects/$id/cancel/');
  }
}
