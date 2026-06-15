import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
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
    required this.createdAt,
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
  ///  Local state fields for this page.

  int selectedTabIndex = 0;
  bool isLoading = true;

  // Callback for widget rebuild
  VoidCallback? onStateChanged;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  // Mock data for chat rooms
  List<ChatRoom> chatRooms = const [
    ChatRoom(
      id: '00000000-0000-0000-0000-000000000001',
      providerName: 'Maria Santos',
      providerPhoto:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      lastMessage: 'Thank you for the booking! See you tomorrow.',
      lastMessageTime: null,
      unreadCount: 2,
    ),
    ChatRoom(
      id: '00000000-0000-0000-0000-000000000002',
      providerName: 'Anna Cruz',
      providerPhoto:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
      lastMessage: 'The paint colors look great!',
      lastMessageTime: null,
      unreadCount: 0,
    ),
    ChatRoom(
      id: '00000000-0000-0000-0000-000000000003',
      providerName: 'Jose Reyes',
      providerPhoto:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      lastMessage: 'Is the leak fixed?',
      lastMessageTime: null,
      unreadCount: 1,
    ),
  ];

  // Mock data for call history
  List<CallHistory> callHistory = const [
    CallHistory(
      id: '1',
      providerName: 'Maria Santos',
      providerPhoto:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      callType: 'voice',
      callStatus: 'missed',
      durationSeconds: 0,
      createdAt: null,
    ),
    CallHistory(
      id: '2',
      providerName: 'Anna Cruz',
      providerPhoto:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
      callType: 'video',
      callStatus: 'incoming',
      durationSeconds: 180,
      createdAt: null,
    ),
    CallHistory(
      id: '3',
      providerName: 'Jose Reyes',
      providerPhoto:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      callType: 'voice',
      callStatus: 'outgoing',
      durationSeconds: 45,
      createdAt: null,
    ),
  ];

  @override
  void initState(BuildContext context) {
    // Simulate loading data
    Future.delayed(const Duration(milliseconds: 1500), () {
      isLoading = false;
      onStateChanged?.call();
    });

    // Initialize with current date/time for mock data
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

  @override
  void dispose() {}
}
