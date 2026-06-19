import 'package:flutter/material.dart';

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
    _initializeMockData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatRooms();
    });
  }

  void _initializeMockData() {
    final now = DateTime.now();

    chatRooms = [
      ChatRoom(
        id: '00000000-0000-0000-0000-000000000001',
        providerName: 'Maria Santos',
        providerPhoto:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
        lastMessage: 'Thank you for the booking! See you tomorrow.',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        unreadCount: 2,
      ),
      ChatRoom(
        id: '00000000-0000-0000-0000-000000000002',
        providerName: 'Anna Cruz',
        providerPhoto:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
        lastMessage: 'The paint colors look great!',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
      ChatRoom(
        id: '00000000-0000-0000-0000-000000000003',
        providerName: 'Jose Reyes',
        providerPhoto:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
        lastMessage: 'Is the leak fixed?',
        lastMessageTime: now.subtract(const Duration(days: 3)),
        unreadCount: 1,
      ),
    ];

    callHistory = [
      CallHistory(
        id: '1',
        providerName: 'Maria Santos',
        providerPhoto:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
        callType: 'voice',
        callStatus: 'missed',
        durationSeconds: 0,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      CallHistory(
        id: '2',
        providerName: 'Anna Cruz',
        providerPhoto:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
        callType: 'video',
        callStatus: 'incoming',
        durationSeconds: 180,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      CallHistory(
        id: '3',
        providerName: 'Jose Reyes',
        providerPhoto:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
        callType: 'voice',
        callStatus: 'outgoing',
        durationSeconds: 45,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
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
    } catch (e) {
      chatRooms = const [];
    } finally {
      isLoading = false;
      onStateChanged?.call();
    }
  }

  @override
  void dispose() {
    pageViewController?.dispose();
  }
}
