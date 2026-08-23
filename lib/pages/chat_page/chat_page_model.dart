import 'dart:async';

import 'package:flutter/material.dart';

import '/auth/base_auth_user_provider.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/chat_service.dart';
import '/services/logging_service.dart';
import 'chat_page_widget.dart' show ChatPageWidget;

class ChatPageModel extends FlutterFlowModel<ChatPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Messages list - populated from the SHPH API
  List<Map<String, dynamic>> messages = [];
  StreamSubscription<dynamic>? _pollingSubscription;
  bool isLoading = true;

  bool _isClient = true;

  // Callback for widget rebuild
  VoidCallback? onStateChanged;

  @override
  void initState(BuildContext context) {}

  // Initialize chat polling for messages
  Future<void> initializeChatSubscription(String roomId) async {
    // Fetch room details to determine if current user is client or provider
    await _resolveUserRole(roomId);

    // Fetch initial messages
    unawaited(_fetchMessages(roomId));

    // Poll for new messages (realtime not available via REST)
    _pollingSubscription ??=
        Stream.periodic(const Duration(seconds: 5), (_) => null).listen((_) {
      _fetchMessages(roomId);
    });
  }

  Future<void> _resolveUserRole(String roomId) async {
    final room = await ChatService.instance.getRoom(roomId);
    if (room != null) {
      final currentUserId = currentUser?.uid;
      _isClient =
          currentUserId != null && room['client_id'] == currentUserId;
    }
  }

  Future<void> _fetchMessages(String roomId) async {
    try {
      isLoading = true;
      onStateChanged?.call();
      final response = await ChatService.instance.getMessages(roomId);

      messages = response
          .map((msg) => {
                'text': msg['message_text'] ?? msg['content'] ?? msg['text'],
                'isMe': _isSenderMe(msg['sender_id'] as String? ?? ''),
                'time': _formatTime(_parseDateTime(
                  msg['created_at'] ?? msg['createdAt'] ?? msg['timestamp'],
                )),
                'status': 'delivered',
              })
          .toList();
    } catch (e) {
      messages = [];
      LoggingService.error('Error fetching messages: $e', tag: 'ChatPage');
    } finally {
      isLoading = false;
      onStateChanged?.call();
    }
  }

  bool _isSenderMe(String senderId) =>
      _isClient ? senderId == 'client' : senderId == 'provider';

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
      return DateTime.tryParse(value) ?? DateTime.now();
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
    // Optimistic UI: Add message immediately to local list
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
    // Cancel polling subscription
    _pollingSubscription?.cancel();
    _pollingSubscription = null;
  }
}
