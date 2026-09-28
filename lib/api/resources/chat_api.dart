import 'package:dio/dio.dart' show FormData;

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

  /// Lists the authenticated user's direct threads
  /// (`GET /api/chat/threads/?thread_type=direct`). Used to reuse an existing
  /// thread with a provider instead of creating duplicates.
  Future<Map<String, dynamic>> listDirectThreads({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/chat/threads/',
      queryParameters: {
        'thread_type': 'direct',
        if (page != null) 'page': page,
      },
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
    return sendMessageExtended(threadId, content: content);
  }

  /// Full send payload — used by the call service to post system messages
  /// (`is_system_message: true`) like the web client does on call end.
  Future<Map<String, dynamic>> sendMessageExtended(
    String threadId, {
    required String content,
    bool isSystemMessage = false,
    String? fileAttachment,
    String? fileType,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/threads/$threadId/send/',
      data: {
        'content': content,
        if (isSystemMessage) 'is_system_message': true,
        if (fileAttachment != null && fileAttachment.isNotEmpty) ...{
          'file_attachment': fileAttachment,
          if (fileType != null && fileType.isNotEmpty) 'file_type': fileType,
        },
      },
    );
    return response.data ?? {};
  }

  /// Uploads a chat attachment (`multipart/form-data`, key `file`) and
  /// returns `{url, file_type}` per the `ChatFileUpload` schema.
  Future<Map<String, dynamic>> uploadFile(
    String threadId,
    FormData file,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/threads/$threadId/upload/',
      data: file,
    );
    return response.data ?? {};
  }

  /// Blocks or unblocks a user (`{"user_id": int, "action": "block"|"unblock"}`).
  Future<void> blockUser(int userId, {required bool block}) async {
    await _client.post(
      '/api/chat/block/',
      data: {
        'user_id': userId,
        'action': block ? 'block' : 'unblock',
      },
    );
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

  /// Accepts an incoming call (call status must be INITIATED).
  Future<Map<String, dynamic>> acceptCall(String callId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/calls/$callId/accept/',
    );
    return response.data ?? {};
  }

  /// Rejects an incoming call with an optional reason.
  Future<Map<String, dynamic>> rejectCall(String callId, {String? reason}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/calls/$callId/reject/',
      data: {if (reason != null) 'reason': reason},
    );
    return response.data ?? {};
  }

  /// Ends an active call; records duration and an optional end reason.
  Future<Map<String, dynamic>> endCall(String callId, {String? reason}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/chat/calls/$callId/end/',
      data: {if (reason != null) 'reason': reason},
    );
    return response.data ?? {};
  }

  /// Mints a short-lived SFU join token (needed only for group/SFU calls).
  Future<Map<String, dynamic>> getSfuToken(String callId) async {
    final response = await _client
        .get<Map<String, dynamic>>('/api/chat/calls/$callId/sfu-token/');
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
