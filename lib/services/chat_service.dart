import 'dart:async';

import '/api/resources/chat_api.dart';
import '/services/logging_service.dart';
import '/services/websocket_service.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final _chatApi = ShphChatApi.instance;
  final _ws = ShphWebSocketService.instance;

  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _threadUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  /// Emits incoming chat message events (`chat.message`).
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// Emits thread metadata updates (`chat.thread_updated`).
  Stream<Map<String, dynamic>> get threadUpdateStream =>
      _threadUpdateController.stream;

  /// Emits typing indicator events (`chat.typing`).
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  /// True when the WebSocket is connected and ready for real-time traffic.
  bool get isWebSocketConnected => _ws.isConnected;

  /// Initialize the global WebSocket connection for chat. Safe to call multiple
  /// times; will no-op if already connected or connecting.
  Future<void> initializeWebSocket() async {
    await _ws.connect();
    _messageSubscription ??= _ws.messages.listen(_routeMessage);
  }

  void _routeMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    switch (type) {
      case 'chat.message':
      case 'chat.message_edited':
      case 'chat.message_deleted':
        _messageController.add(message);
        break;
      case 'chat.thread_updated':
        _threadUpdateController.add(message);
        break;
      case 'chat.typing':
        _typingController.add(message);
        break;
      default:
        break;
    }
  }

  /// Close the global WebSocket connection and stop listening to events.
  void closeWebSocket() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _ws.disconnect();
  }

  void dispose() {
    closeWebSocket();
    _messageController.close();
    _threadUpdateController.close();
    _typingController.close();
  }

  /// Returns a list of chat thread maps from the SHPH API.
  Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      final dynamic resp = await _chatApi.listThreads();
      final results = resp['results'];
      if (results is List) {
        return List<Map<String, dynamic>>.from(results);
      }
      if (resp is List) {
        return List<Map<String, dynamic>>.from(resp);
      }
    } catch (e) {
      LoggingService.error('getChatRooms failed: $e', tag: 'ChatService');
    }
    return [];
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
    } catch (e) {
      LoggingService.error('getMessages failed: $e', tag: 'ChatService');
    }
    return [];
  }

  Future<bool> sendMessage(String threadId, String content) async {
    // Prefer WebSocket for real-time delivery when connected.
    if (_ws.isConnected) {
      try {
        _ws.sendChatMessage(threadId, content);
        return true;
      } catch (e) {
        LoggingService.error('WebSocket sendMessage failed, falling back: $e',
            tag: 'ChatService');
      }
    }

    // Fallback to REST API
    try {
      await _chatApi.sendMessage(threadId, content);
      return true;
    } catch (e) {
      LoggingService.error('sendMessage failed: $e', tag: 'ChatService');
      return false;
    }
  }

  /// Fetch thread details from the SHPH API.
  Future<Map<String, dynamic>?> getRoom(String threadId) async {
    try {
      return await _chatApi.getThreadDetails(threadId);
    } catch (e) {
      LoggingService.error('getRoom failed: $e', tag: 'ChatService');
      return null;
    }
  }

  Future<void> markRead(String threadId) async {
    if (_ws.isConnected) {
      try {
        _ws.markRead(threadId);
        return;
      } catch (e) {
        LoggingService.error('WebSocket markRead failed, falling back: $e',
            tag: 'ChatService');
      }
    }

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
  }) async {
    if (providerId.isEmpty) {
      return null;
    }

    try {
      return await _chatApi.getOrCreateDirectThread(providerId: providerId);
    } catch (e) {
      LoggingService.error('getOrCreateDirectThread failed: $e',
          tag: 'ChatService');
      return null;
    }
  }
}
