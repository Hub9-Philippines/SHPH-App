import 'package:flutter/material.dart';

import '/app_state.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/chat_service.dart';
import 'messages_widget.dart' show MessagesWidget;

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.providerName,
    required this.providerPhoto,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  final String id;
  final String providerName;
  final String providerPhoto;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
}

class CallHistory {
  const CallHistory({
    required this.id,
    required this.providerName,
    required this.providerPhoto,
    required this.callType,
    required this.callStatus,
    required this.durationSeconds,
    this.createdAt,
  });

  final String id;
  final String providerName;
  final String providerPhoto;
  final String callType;
  final String callStatus;
  final int durationSeconds;
  final DateTime? createdAt;
}

class MessagesModel extends FlutterFlowModel<MessagesWidget> {
  int selectedTabIndex = 0;
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  bool isLoading = true;
  VoidCallback? onStateChanged;

  List<ChatRoom> chatRooms = const [];
  List<CallHistory> callHistory = const [];

  @override
  void initState(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatRooms();
    });
  }

  Future<void> _loadChatRooms() async {
    try {
      final rooms = await ChatService.instance.getChatRooms();
      if (rooms.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 1500));
        isLoading = false;
        onStateChanged?.call();
        return;
      }

      chatRooms = rooms.map((r) {
        final id = r['id']?.toString() ?? r['thread_id']?.toString() ?? '';
        final providerName = r['provider_name'] ??
            r['customer']?['display_name'] ??
            r['title'] ??
            '';
        final providerPhoto =
            r['provider_photo'] ?? r['customer']?['photo_url'] ?? '';
        final lastMessage = r['last_message'] is Map
            ? (r['last_message']['content'] ??
                r['last_message']['message_text'] ??
                r['last_message']['text'])
            : r['last_message']?.toString();

        DateTime? lastMessageTime;
        final lt = r['last_message_time'] ??
            r['last_message']?['created_at'] ??
            r['updated_at'];
        if (lt != null) {
          lastMessageTime = lt is String
              ? DateTime.tryParse(lt)
              : (lt is DateTime ? lt : null);
        }

        final unreadCount =
            (r['unread_count'] ?? r['unread'] ?? 0) as int? ?? 0;

        return ChatRoom(
          id: id,
          providerName: providerName.toString(),
          providerPhoto: providerPhoto.toString(),
          lastMessage: lastMessage?.toString(),
          lastMessageTime: lastMessageTime,
          unreadCount: unreadCount,
        );
      }).toList();

      _syncUnreadCount();
    } catch (e) {
      chatRooms = const [];
      _syncUnreadCount();
    } finally {
      isLoading = false;
      onStateChanged?.call();
    }
  }

  Future<void> reload() {
    _syncUnreadCount();
    return _loadChatRooms();
  }

  void _syncUnreadCount() {
    final total = chatRooms
        .where((room) => room.unreadCount > 0)
        .fold<int>(0, (sum, room) => sum + room.unreadCount);
    FFAppState().unreadConversations = total;
  }

  @override
  void dispose() {
    pageViewController?.dispose();
  }
}
