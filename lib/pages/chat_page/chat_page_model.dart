import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/services/chat_service.dart';
import '/components/back_button/back_button_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'chat_page_widget.dart' show ChatPageWidget;

class ChatPageModel extends FlutterFlowModel<ChatPageWidget> {
  ///  State fields for stateful widgets in this page.

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late BackButtonModel backButtonModel;

  // Messages list - populated from Supabase
  List<Map<String, dynamic>> messages = [];
  RealtimeChannel? _messagesChannel;

  // Callback for widget rebuild
  VoidCallback? onStateChanged;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  // Initialize Supabase real-time subscription for chat messages
  void initializeChatSubscription(String roomId) {
    // Fetch initial messages
    _fetchMessages(roomId);

    // Set up real-time subscription
    _messagesChannel = Supabase.instance.client
        .channel('chat_messages:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_room_id',
            value: roomId,
          ),
          callback: _handleMessageChange,
        )
        .subscribe();
  }

  Future<void> _fetchMessages(String roomId) async {
    try {
      final response = await ChatService.instance.getMessages(roomId);
      if (response.isNotEmpty) {
        messages = response
            .map((msg) => {
                  'text': msg['message_text'] ?? msg['content'] ?? msg['text'],
                  'isMe': msg['sender_id'] ==
                          Supabase.instance.client.auth.currentUser?.id ||
                      msg['sender_id'] == 'client',
                  'time': _formatTime(_parseDateTime(msg['created_at'] ??
                      msg['createdAt'] ??
                      msg['timestamp'])),
                })
            .toList();
        onStateChanged?.call();
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  void _handleMessageChange(PostgresChangePayload payload) {
    final eventType = payload.eventType;
    final record = payload.newRecord;

    if (eventType == PostgresChangeEvent.insert ||
        eventType == PostgresChangeEvent.update) {
      final newMessage = {
        'text': record['message_text'] as String,
        'isMe': record['sender_id'] == 'client',
        'time': _formatTime(_parseDateTime(record['created_at'])),
        'status': 'delivered',
      };

      // Check if this is a duplicate of an optimistic message
      final existingIndex = messages.indexWhere((msg) =>
          msg['text'] == newMessage['text'] &&
          msg['isMe'] == newMessage['isMe'] &&
          (msg['status'] == 'sending' || msg['status'] == 'sent'));

      if (existingIndex != -1) {
        messages[existingIndex] = newMessage;
        onStateChanged?.call();
      } else if (!messages.any((msg) =>
          msg['text'] == newMessage['text'] &&
          msg['time'] == newMessage['time'])) {
        messages.add(newMessage);
        onStateChanged?.call();
      }
    }
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

  // Send message to Supabase with optimistic UI
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

    try {
      await ChatService.instance.sendMessage(roomId, content);

      // Update message status to 'sent'
      final index = messages.indexWhere((msg) => msg['tempId'] == tempId);
      if (index != -1) {
        messages[index]['status'] = 'sent';
        onStateChanged?.call();
      }
    } catch (e) {
      print('Error sending message: $e');
      // Update message status to 'failed'
      final index = messages.indexWhere((msg) => msg['tempId'] == tempId);
      if (index != -1) {
        messages[index]['status'] = 'failed';
        onStateChanged?.call();
      }
    }
  }

  @override
  void dispose() {
    backButtonModel.dispose();
    // Cancel real-time subscription
    if (_messagesChannel != null) {
      Supabase.instance.client.removeChannel(_messagesChannel!);
    }
  }
}
