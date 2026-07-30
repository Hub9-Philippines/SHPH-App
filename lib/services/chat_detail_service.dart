import '/api/resources/chat_api.dart';
import '/services/logging_service.dart';

class ChatDetailService {
  ChatDetailService._();
  static final ChatDetailService instance = ChatDetailService._();

  final _chatApi = ShphChatApi.instance;

  Future<Map<String, dynamic>?> getThreadDetails(String threadId) async {
    try {
      return await _chatApi.getThreadDetails(threadId);
    } catch (e) {
      LoggingService.error('Error fetching thread details: $e',
          tag: 'ChatDetailService');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String threadId) async {
    try {
      final resp = await _chatApi.listMessages(threadId);
      final results = resp['results'];
      if (results is List) {
        return results.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggingService.error('Error fetching messages: $e',
          tag: 'ChatDetailService');
      return [];
    }
  }

  Future<bool> sendMessage(String threadId, String content) async {
    try {
      await _chatApi.sendMessage(threadId, content);
      return true;
    } catch (e) {
      LoggingService.error('Error sending message: $e',
          tag: 'ChatDetailService');
      return false;
    }
  }

  Future<void> markRead(String threadId) async {
    try {
      await _chatApi.markRead(threadId);
    } catch (e) {
      LoggingService.error('Error marking read: $e', tag: 'ChatDetailService');
    }
  }
}
