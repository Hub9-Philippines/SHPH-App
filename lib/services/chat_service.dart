import '/api/resources/chat_api.dart';
import '/auth/base_auth_user_provider.dart';
import '/services/logging_service.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final _chatApi = ShphChatApi.instance;

  /// Returns a list of chat room maps. Structure depends on backend.
  Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      final dynamic resp = await _chatApi.listThreads();
      final results = resp['results'];
      if (results is List) {
        return List<Map<String, dynamic>>.from(results);
      }
      // If API returns a flat list
      if (resp is List) {
        return List<Map<String, dynamic>>.from(resp);
      }
      return const [];
    } catch (e) {
      LoggingService.error('getChatRooms failed: $e', tag: 'ChatService');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String threadId) async {
    try {
      final dynamic resp = await _chatApi.listMessages(threadId);
      final results = resp['results'];
      if (results is List) {
        return List<Map<String, dynamic>>.from(results);
      }
      if (resp is List) {
        return List<Map<String, dynamic>>.from(resp);
      }
      return const [];
    } catch (e) {
      LoggingService.error('getMessages failed: $e', tag: 'ChatService');
      return [];
    }
  }

  Future<bool> sendMessage(String threadId, String content) async {
    try {
      await _chatApi.sendMessage(threadId, content);
      return true;
    } catch (e) {
      LoggingService.error('sendMessage failed: $e', tag: 'ChatService');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getRoom(String threadId) async {
    try {
      return await _chatApi.getThreadDetails(threadId);
    } catch (e) {
      LoggingService.error('getRoom failed: $e', tag: 'ChatService');
      return null;
    }
  }

  Future<void> markRead(String threadId) async {
    try {
      await _chatApi.markRead(threadId);
    } catch (e) {
      LoggingService.error('markRead failed: $e', tag: 'ChatService');
    }
  }

  Future<Map<String, dynamic>?> getOrCreateThreadForBooking(
      String bookingId) async {
    try {
      return await _chatApi.getOrCreateThreadForBooking(bookingId);
    } catch (e) {
      LoggingService.error('getOrCreateThreadForBooking failed: $e',
          tag: 'ChatService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getOrCreateDirectThread({
    required String providerId,
    String? providerName,
    String? providerPhoto,
  }) async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty || providerId.isEmpty) {
      return null;
    }

    try {
      return await _chatApi.getOrCreateThreadForBooking('');
    } catch (e) {
      LoggingService.error('getOrCreateDirectThread failed: $e',
          tag: 'ChatService');
      return null;
    }
  }
}
