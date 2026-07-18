import 'dart:async';

import 'package:flutter/material.dart';

import '/api/shph_token_storage.dart';
import '/components/back_button/back_button_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/chat_service.dart';
import '/services/logging_service.dart';
import 'chat_page_widget.dart' show ChatPageWidget;

class ChatPageModel extends FlutterFlowModel<ChatPageWidget> {
  ///  State fields for stateful widgets in this page.

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late BackButtonModel backButtonModel;

  // Messages list - populated from API/WebSocket
  List<Map<String, dynamic>> messages = [];
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;
  bool isLoading = true;

  int? _currentUserId;
  bool _isClient = true;

  // Callback for widget rebuild
  VoidCallback? onStateChanged;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  // Initialize real-time subscription for chat messages via SHPH WebSocket.
  Future<void> initializeChatSubscription(String roomId) async {
    await _resolveUserRole(roomId);

    // Ensure the global WebSocket connection is active
    await ChatService.instance.initializeWebSocket();

    // Fetch initial messages
    unawaited(_fetchMessages(roomId));

    // Listen to SHPH WebSocket chat events
    _wsSubscription = ChatService.instance.messageStream.listen(
      (event) => _handleWebSocketMessage(event, roomId),
    );
  }

  Future<void> _resolveUserRole(String roomId) async {
    _currentUserId = await ShphTokenStorage.getCurrentUserId();
    if (_currentUserId == null) {
      return;
    }

    final room = await ChatService.instance.getRoom(roomId);
    if (room != null) {
      final clientId = room['client_id'];
      if (clientId is int) {
        _isClient = clientId == _currentUserId;
      } else if (clientId != null) {
        _isClient = int.tryParse(clientId.toString()) == _currentUserId;
      }
    }
  }

  Future<void> _fetchMessages(String roomId) async {
    try {
      isLoading = true;
      onStateChanged?.call();
      final response = await ChatService.instance.getMessages(roomId);

      messages = response.map(_normalizeMessage).toList();
    } catch (e) {
      messages = [];
      LoggingService.error('Error fetching messages: $e', tag: 'ChatPage');
    } finally {
      isLoading = false;
      onStateChanged?.call();
    }
  }

  Map<String, dynamic> _normalizeMessage(Map<String, dynamic> msg) {
    final senderId = _extractSenderId(msg);
    return {
      'text': msg['message_text'] ?? msg['content'] ?? msg['text'] ?? '',
      'isMe': _isSenderMe(senderId),
      'time': _formatTime(_parseDateTime(
        msg['created_at'] ?? msg['createdAt'] ?? msg['timestamp'],
      )),
      'status': 'delivered',
    };
  }

  dynamic _extractSenderId(Map<String, dynamic> msg) =>
      msg['sender_id'] ?? msg['sender']?['id'] ?? '';

  bool _isSenderMe(dynamic senderId) {
    if (_currentUserId != null && senderId is int) {
      return senderId == _currentUserId;
    }
    if (_currentUserId != null && senderId is String) {
      return int.tryParse(senderId) == _currentUserId;
    }
    return _isClient ? senderId == 'client' : senderId == 'provider';
  }

  void _handleWebSocketMessage(Map<String, dynamic> event, String roomId) {
    final eventThreadId = event['thread_id']?.toString();
    if (eventThreadId != null && eventThreadId != roomId) {
      return;
    }

    final type = event['type'] as String?;
    if (type == 'chat.message') {
      final message = event['message'];
      if (message is! Map<String, dynamic>) {
        return;
      }
      final newMessage = _normalizeMessage(message);
      _upsertMessage(newMessage);
    } else if (type == 'chat.message_edited') {
      final message = event['message'];
      if (message is! Map<String, dynamic>) {
        return;
      }
      final updated = _normalizeMessage(message);
      final index = messages.indexWhere((m) => m['text'] == updated['text']);
      if (index != -1) {
        messages[index] = updated;
        onStateChanged?.call();
      }
    } else if (type == 'chat.message_deleted') {
      final messageId = event['message_id']?.toString();
      if (messageId == null) {
        return;
      }
      messages.removeWhere((m) => m['id']?.toString() == messageId);
      onStateChanged?.call();
    }
  }

  void _upsertMessage(Map<String, dynamic> newMessage) {
    final existingIndex = messages.indexWhere((msg) =>
        msg['text'] == newMessage['text'] &&
        msg['isMe'] == newMessage['isMe'] &&
        (msg['status'] == 'sending' || msg['status'] == 'sent'));

    if (existingIndex != -1) {
      messages[existingIndex] = newMessage;
      onStateChanged?.call();
    } else if (!messages.any((msg) =>
        msg['text'] == newMessage['text'] &&
        msg['time'] == newMessage['time'] &&
        msg['isMe'] == newMessage['isMe'])) {
      messages.add(newMessage);
      onStateChanged?.call();
    }
  }

  Future<void> markThreadRead(String roomId) async {
    try {
      await ChatService.instance.markRead(roomId);
    } catch (_) {}
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Send message with optimistic UI
  Future<void> sendMessage(String content, String roomId) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final optimisticMessage = {
      'text': content,
      'isMe': true,
      'time': 'Just now',
      'tempId': tempId,
      'status': 'sending',
    };

    messages.add(optimisticMessage);
    onStateChanged?.call();

    final success = await ChatService.instance.sendMessage(roomId, content);

    final index = messages.indexWhere((msg) => msg['tempId'] == tempId);
    if (index != -1) {
      messages[index]['status'] = success ? 'sent' : 'failed';
      onStateChanged?.call();
    }
  }

  @override
  void dispose() {
    backButtonModel.dispose();
    _wsSubscription?.cancel();
    _wsSubscription = null;
  }
}
