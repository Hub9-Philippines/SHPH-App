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

  Future<Map<String, dynamic>> getOrCreateThreadForBooking(
      String bookingId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/threads/booking/$bookingId/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getOrCreateDirectThread({
    required String providerId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/threads/direct/',
      data: {'provider_id': int.tryParse(providerId) ?? providerId},
    );
    return response.data ?? {};
  }

  // --- Video/voice calls (/api/chat/calls/*) ---

  Future<Map<String, dynamic>> initiateCall({
    required String threadId,
    required int calleeId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/calls/initiate/',
      data: {'thread_id': threadId, 'callee_id': calleeId},
    );
    return response.data ?? {};
  }

  Future<void> acceptCall(String callId) async {
    await _client.post('/api/chat/calls/$callId/accept/');
  }

  Future<void> rejectCall(String callId, {String? reason}) async {
    await _client.post(
      '/api/chat/calls/$callId/reject/',
      data: {if (reason != null) 'reason': reason},
    );
  }

  Future<void> endCall(String callId, {String? reason, int? duration}) async {
    await _client.post(
      '/api/chat/calls/$callId/end/',
      data: {
        if (reason != null) 'reason': reason,
        if (duration != null) 'duration': duration,
      },
    );
  }

  Future<Map<String, dynamic>> listCalls() async {
    final response =
        await _client.get<Map<String, dynamic>>('/api/chat/calls/');
    return response.data ?? {};
  }
}
