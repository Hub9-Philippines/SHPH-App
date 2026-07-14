import 'dart:async';

import 'package:flutter/material.dart';

import '/api/shph_api.dart';
import '/components/back_button/back_button_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/chat_service.dart';
import '/services/logging_service.dart';
import 'chat_page_widget.dart' show ChatPageWidget;

class ChatPageModel extends FlutterFlowModel<ChatPageWidget> {
  ///  State fields for stateful widgets in this page.

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late BackButtonModel backButtonModel;

  // Messages loaded from the SHPH REST API.
  List<Map<String, dynamic>> messages = [];
  Timer? _pollTimer;
  bool isLoading = true;
  bool peerIsTyping = false;

  bool _isClient = true;
  String? _currentUserId;

  Timer? _typingTimer;

  // Callback for widget rebuild
  VoidCallback? onStateChanged;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  // The API has no websocket contract, so refresh while the thread is open.
  Future<void> initializeChatSubscription(String roomId) async {
    // Fetch room details to determine if current user is client or provider
    await _resolveUserRole(roomId);

    // Fetch initial messages
    unawaited(_fetchMessages(roomId));

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _fetchMessages(roomId, showLoading: false),
    );
  }

  Future<void> _resolveUserRole(String roomId) async {
    final room = await ChatService.instance.getRoom(roomId);
    if (room != null) {
      final me = await ShphUsersApi.instance.getMe();
      _currentUserId = me['id']?.toString();
      _isClient = _currentUserId != null &&
          room['client_id']?.toString() == _currentUserId;
    }
  }

  Future<void> _fetchMessages(String roomId, {bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading = true;
        onStateChanged?.call();
      }
      final response = await ChatService.instance.getMessages(roomId);

      messages = response
          .map((msg) => {
                'text': msg['message_text'] ?? msg['content'] ?? msg['text'],
                'isMe': _isSenderMe(msg['sender_id']?.toString() ?? ''),
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
      if (showLoading) isLoading = false;
      onStateChanged?.call();
    }
  }

  bool _isSenderMe(String senderId) => senderId == _currentUserId;

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

  void sendTypingIndicator(String roomId) {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () async {
      try {
        await ShphChatApi.instance.sendTypingIndicator(roomId);
      } catch (_) {}
    });
  }

  // Send through the SHPH API with optimistic UI.
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
    _typingTimer?.cancel();
    _pollTimer?.cancel();
    backButtonModel.dispose();
  }
}
