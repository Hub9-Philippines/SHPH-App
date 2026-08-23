import '/api/shph_api_client.dart';

class ShphRoomsApi {
  ShphRoomsApi._();

  static final ShphRoomsApi instance = ShphRoomsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> list() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/list/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/',
      data: payload,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> detail(String id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/$id/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> join(String id, String token) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/rooms/$id/join/',
      data: {'join_token': token},
    );
    return response.data ?? {};
  }

  Future<void> leave(String id) async {
    await _client.post('/api/services/rooms/$id/leave/');
  }

  Future<void> lock(String id) async {
    await _client.post('/api/services/rooms/$id/lock/');
  }

  Future<void> cancel(String id) async {
    await _client.post('/api/services/rooms/$id/cancel/');
  }

  Future<Map<String, dynamic>> byToken(String token) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/rooms/by-token/$token/',
    );
    return response.data ?? {};
  }
}
