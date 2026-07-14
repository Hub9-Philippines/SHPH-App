import '/api/resources/chat_api.dart';
import '/services/logging_service.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();
  final _api = ShphChatApi.instance;

  List<Map<String, dynamic>> _rows(Map<String, dynamic> data) =>
      ((data['results'] ?? data['data']) as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

  Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      return _rows(await _api.listThreads());
    } catch (e) {
      LoggingService.error('Thread fetch failed: $e', tag: 'ChatService');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String threadId) async {
    try {
      return _rows(await _api.listMessages(threadId));
    } catch (e) {
      LoggingService.error('Message fetch failed: $e', tag: 'ChatService');
      return [];
    }
  }

  Future<bool> sendMessage(String threadId, String content) async {
    try {
      await _api.sendMessage(threadId, content);
      return true;
    } catch (e) {
      LoggingService.error('Message send failed: $e', tag: 'ChatService');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getRoom(String threadId) async {
    try {
      return await _api.getThreadDetails(threadId);
    } catch (e) {
      LoggingService.error('Thread detail failed: $e', tag: 'ChatService');
      return null;
    }
  }

  Future<void> markRead(String threadId) => _api.markRead(threadId);

  Future<Map<String, dynamic>?> getOrCreateThreadForBooking(
      String bookingId) async {
    try {
      return await _api.getOrCreateThreadForBooking(bookingId);
    } catch (e) {
      LoggingService.error('Booking thread failed: $e', tag: 'ChatService');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getOrCreateDirectThread({
    required String providerId,
    String? initialMessage,
  }) async {
    try {
      final thread = await _api.createDirectThread(
        participantId: providerId,
      );
      if (initialMessage != null && initialMessage.trim().isNotEmpty) {
        final id = thread['id']?.toString();
        if (id != null) await _api.sendMessage(id, initialMessage.trim());
      }
      return thread;
    } catch (e) {
      LoggingService.error('Direct thread failed: $e', tag: 'ChatService');
      return null;
    }
  }
}
