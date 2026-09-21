import '/api/shph_api_client.dart';

/// Chat endpoints from SHPH API.yaml (`/api/chat/*`).
class ShphChatApi {
  ShphChatApi._();

  static final ShphChatApi instance = ShphChatApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> listThreads({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/chat/threads/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getThreadDetails(String id) async {
    final response =
        await _client.get<Map<String, dynamic>>('/api/chat/threads/$id/');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> listMessages(String threadId,
      {int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/chat/threads/$threadId/messages/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> sendMessage(
      String threadId, String content) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/threads/$threadId/send/',
      data: {'content': content},
    );
    return response.data ?? {};
  }

  Future<void> markRead(String threadId) async {
    await _client.post('/api/chat/threads/$threadId/read/');
  }

  Future<Map<String, dynamic>> initiateCall(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/calls/initiate/',
      data: payload,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getOrCreateThreadForBooking(
      String bookingId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/threads/booking/$bookingId/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getOrCreateDirectThread(
      int providerId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/threads/direct/',
      data: {'provider_id': providerId},
    );
    return response.data ?? {};
  }
}
