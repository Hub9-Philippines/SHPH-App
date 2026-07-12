import 'package:dio/dio.dart';
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

  /// POST /api/chat/threads/direct/ - create or get direct thread
  Future<Map<String, dynamic>> createDirectThread({
    required String participantId,
    String? bookingId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/threads/direct/',
      data: {
        'participant_id': participantId,
        if (bookingId != null) 'booking_id': bookingId,
      },
    );
    return response.data ?? {};
  }

  /// POST /api/chat/threads/{threadId}/typing/ - send typing indicator
  Future<void> sendTypingIndicator(String threadId) async {
    await _client.post('/api/chat/threads/$threadId/typing/');
  }

  /// POST /api/chat/threads/{threadId}/upload/ - upload file to thread
  Future<Map<String, dynamic>> uploadFile(
    String threadId, {
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/threads/$threadId/upload/',
      data: formData,
    );
    return response.data ?? {};
  }

  /// PATCH /api/chat/threads/{threadId}/messages/{messageId}/edit/ - edit message
  Future<Map<String, dynamic>> editMessage(
    String threadId,
    String messageId, {
    required String content,
  }) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/chat/threads/$threadId/messages/$messageId/edit/',
      data: {'content': content},
    );
    return response.data ?? {};
  }

  /// DELETE /api/chat/threads/{threadId}/messages/{messageId}/delete/ - delete message
  Future<void> deleteMessage(String threadId, String messageId) async {
    await _client.delete(
      '/api/chat/threads/$threadId/messages/$messageId/delete/',
    );
  }

  /// POST /api/chat/calls/initiate/ - initiate a call
  Future<Map<String, dynamic>> initiateCall({
    required String threadId,
    required String callType,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/calls/initiate/',
      data: {'thread_id': threadId, 'call_type': callType},
    );
    return response.data ?? {};
  }

  /// POST /api/chat/calls/{callId}/accept/ - accept an incoming call
  Future<void> acceptCall(String callId) async {
    await _client.post('/api/chat/calls/$callId/accept/');
  }

  /// POST /api/chat/calls/{callId}/reject/ - reject an incoming call
  Future<void> rejectCall(String callId) async {
    await _client.post('/api/chat/calls/$callId/reject/');
  }

  /// POST /api/chat/calls/{callId}/end/ - end a call
  Future<void> endCall(String callId) async {
    await _client.post('/api/chat/calls/$callId/end/');
  }

  /// GET /api/chat/calls/ - list calls
  Future<List<Map<String, dynamic>>> listCalls({int? page}) async {
    final response = await _client.get<List<dynamic>>(
      '/api/chat/calls/',
      queryParameters: {if (page != null) 'page': page},
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }
}
