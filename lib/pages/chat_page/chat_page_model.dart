import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

import '/auth/base_auth_user_provider.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/call_signal_models.dart';
import '/services/chat_service.dart';
import '/services/call_session_controller.dart';
import '/services/logging_service.dart';
import 'chat_page_widget.dart' show ChatPageWidget;

/// One renderable row in the conversation. Raw API maps are normalized here
/// so the widget only deals with typed-ish fields.
class ChatMessageView {
  ChatMessageView({
    required this.id,
    required this.isMine,
    required this.createdAt,
    this.text = '',
    this.imageUrl,
    this.isSystem = false,
  });

  final String id;
  final bool isMine;
  final DateTime createdAt;
  final String text;
  final String? imageUrl;
  final bool isSystem;

  /// Stable day key for date separators (local time, yyyy-MM-dd).
  String get dayKey =>
      '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-'
      '${createdAt.day.toString().padLeft(2, '0')}';

  static ChatMessageView fromApi(Map<String, dynamic> msg) {
    final fileUrl = (msg['file_attachment'] as String?) ?? '';
    final fileType = (msg['file_type'] as String?) ?? '';
    final isDeleted = msg['is_deleted'] == true;
    final content = isDeleted ? '' : ((msg['content'] as String?) ?? '');
    final hasImage = !isDeleted &&
        fileUrl.isNotEmpty &&
        (fileType.startsWith('image') ||
            fileType == 'photo' ||
            content.isEmpty);
    return ChatMessageView(
      id: (msg['id'] as String?) ?? '',
      isMine: _isMine(msg),
      createdAt: _parseDate(msg['created_at']),
      text: content,
      imageUrl: hasImage ? fileUrl : null,
      isSystem: msg['is_system_message'] == true,
    );
  }

  static bool _isMine(Map<String, dynamic> msg) {
    final sender = msg['sender'];
    final senderId = sender is Map
        ? (sender['id'] ?? sender['user_id'])?.toString() ?? ''
        : (msg['sender_id'] ?? '').toString();
    final me = currentUser?.uid ?? '';
    if (senderId.isEmpty) return false;
    return senderId == me;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}

class ChatPageModel extends FlutterFlowModel<ChatPageWidget> {
  // Messages list - populated from the SHPH API
  List<ChatMessageView> messages = [];
  StreamSubscription<dynamic>? _pollingSubscription;
  bool isLoading = true;

  // Thread details for the header/menu (booking id, other participant).
  Map<String, dynamic>? threadDetails;
  bool get isDirectThread {
    final type = threadDetails?['thread_type']?.toString();
    return threadDetails?['other_participant'] != null || type == 'direct';
  }

  /// The other participant's user object, normalized across two API shapes:
  /// - `other_participant` when the serializer resolves it (user object or a
  ///   wrapper carrying `user`),
  /// - else computed from `participants[]` by excluding the current user
  ///   (deployed serializer shape: `participants: [{user: {...}, role}, ...]`).
  Map<String, dynamic>? get _otherUser {
    final other = threadDetails?['other_participant'];
    if (other is Map) {
      final user = other['user'] is Map ? other['user'] : other;
      final id = (user['id'] ?? user['user_id']);
      if (id != null) {
        return Map<String, dynamic>.from(user as Map);
      }
    }
    final participants = threadDetails?['participants'];
    if (participants is List) {
      final me = currentUser?.uid ?? '';
      for (final p in participants) {
        if (p is! Map) continue;
        final user = p['user'] is Map
            ? Map<String, dynamic>.from(p['user'] as Map)
            : Map<String, dynamic>.from(p);
        final id = (user['id'] ?? user['user_id'])?.toString() ?? '';
        if (id.isNotEmpty && id != me) {
          return user;
        }
      }
    }
    return null;
  }

  String? get otherParticipantName {
    final user = _otherUser;
    if (user != null) {
      final name =
          (user['display_name'] ?? user['first_name'] ?? user['username'])
              ?.toString();
      if (name != null && name.isNotEmpty) return name;
    }
    return null;
  }

  String? get otherParticipantId {
    final user = _otherUser;
    if (user == null) return null;
    return (user['id'] ?? user['user_id'])?.toString();
  }

  String? get otherParticipantPhoto {
    return _otherUser?['photo_url']?.toString();
  }

  String? get bookingId {
    final fromDetail = threadDetails?['booking_id']?.toString();
    if (fromDetail != null && fromDetail.isNotEmpty) return fromDetail;
    final booking = threadDetails?['booking'];
    if (booking is Map) return booking['id']?.toString();
    return null;
  }

  // In-thread search (client-side filter of the loaded conversation).
  String searchQuery = '';
  bool isSearching = false;

  // Callback for widget rebuild
  VoidCallback? onStateChanged;

  String? roomId;

  @override
  void initState(BuildContext context) {}

  // Initialize chat polling for messages
  Future<void> initializeChatSubscription(String roomId) async {
    this.roomId = roomId;

    // Header/menu context (booking link, participant identity).
    unawaited(_loadThreadDetails(roomId));

    // Fetch initial messages
    unawaited(_fetchMessages(roomId));

    // Poll for new messages (realtime not available via REST)
    _pollingSubscription ??=
        Stream.periodic(const Duration(seconds: 5), (_) => null).listen((_) {
      _fetchMessages(roomId);
    });
  }

  Future<void> _loadThreadDetails(String roomId) async {
    threadDetails = await ChatService.instance.getThreadDetails(roomId);
    onStateChanged?.call();
  }

  Future<void> _fetchMessages(String roomId) async {
    try {
      isLoading = messages.isEmpty;
      onStateChanged?.call();
      final response = await ChatService.instance.getMessages(roomId);

      final parsed = response.map(ChatMessageView.fromApi).toList();
      parsed.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      messages = parsed;
    } catch (e) {
      if (messages.isEmpty) {
        messages = [];
      }
      LoggingService.error('Error fetching messages: $e', tag: 'ChatPage');
    } finally {
      isLoading = false;
      onStateChanged?.call();
    }
  }

  // Visible list honoring the in-thread search filter.
  List<ChatMessageView> get visibleMessages {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return messages;
    return messages
        .where((m) => !m.isSystem && m.text.toLowerCase().contains(q))
        .toList();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    onStateChanged?.call();
  }

  void setSearchActive(bool active) {
    isSearching = active;
    if (!active) {
      searchQuery = '';
    }
    onStateChanged?.call();
  }

  /// Grouped rows for date separators. Each group is one day's messages.
  List<MapEntry<String, List<ChatMessageView>>> get groupedMessages {
    final groups = <String, List<ChatMessageView>>{};
    for (final m in visibleMessages) {
      groups.putIfAbsent(m.dayKey, () => []).add(m);
    }
    return groups.entries.toList();
  }

  /// Web parity: quick-reply chips while the thread is still fresh.
  bool get showQuickReplies => !isLoading && messages.length < 4;

  Future<void> markThreadRead(String roomId) async {
    try {
      await ChatService.instance.markRead(roomId);
    } catch (_) {}
  }

  // Send message with optimistic UI. Returns false when the API rejected
  // it so the widget can surface honest failure feedback.
  Future<bool> sendMessage(String content, String roomId) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    messages.add(ChatMessageView(
      id: 'temp_$tempId',
      isMine: true,
      createdAt: DateTime.now(),
      text: trimmed,
    ));
    onStateChanged?.call();

    final success = await ChatService.instance.sendMessage(roomId, trimmed);

    final index = messages.indexWhere((m) => m.id == 'temp_$tempId');
    if (index != -1 && !success) {
      // Drop the optimistic bubble; the widget shows the failure snack.
      messages.removeAt(index);
    }
    onStateChanged?.call();
    if (success) {
      unawaited(_fetchMessages(roomId));
    }
    return success;
  }

  /// Picks an image with the system picker and sends it as an attachment
  /// message. Returns false on failure so the widget can surface a snack.
  Future<bool> sendImage(String filePath, String roomId) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    messages.add(ChatMessageView(
      id: 'temp_$tempId',
      isMine: true,
      createdAt: DateTime.now(),
      imageUrl: filePath,
    ));
    onStateChanged?.call();

    final success = await ChatService.instance.sendImageMessage(
      roomId,
      filePath,
      fileName: filePath.split('/').last.split('\\').last,
    );

    final index = messages.indexWhere((m) => m.id == 'temp_$tempId');
    if (index != -1 && !success) {
      messages.removeAt(index);
    }
    onStateChanged?.call();
    if (success) {
      unawaited(_fetchMessages(roomId));
    }
    return success;
  }

  /// Blocks the other participant via the backend block endpoint.
  Future<bool> blockOtherParticipant() async {
    final id = int.tryParse(otherParticipantId ?? '');
    if (id == null) return false;
    final ok = await ChatService.instance.setUserBlocked(id, block: true);
    if (ok) {
      LoggingService.info(
        'User $id blocked from chat room',
        tag: 'ChatPage',
      );
    }
    return ok;
  }

  // ── Call plumbing (web parity: audio/video buttons in the room header) ──
  bool get isCallActive => CallSessionController.instance.isCallActive;

  Future<void> startCall({
    required String threadId,
    required bool video,
    webrtc.MediaStream? preAcquiredStream,
  }) async {
    final calleeId = otherParticipantId;
    if (calleeId == null || calleeId.isEmpty) {
      throw StateError('No participant to call');
    }
    await CallSessionController.instance.call(
      threadId: threadId,
      calleeId: calleeId,
      participant: CallParticipant(
        id: calleeId,
        name: otherParticipantName ?? 'Provider',
        photo: otherParticipantPhoto,
      ),
      mediaType: video ? CallMediaType.video : CallMediaType.audio,
      preAcquiredStream: preAcquiredStream,
    );
  }

  String formatDayLabel(String dayKey) {
    final parts = dayKey.split('-');
    if (parts.length != 3) return dayKey;
    final date = DateTime.tryParse(
      '${parts[0]}-${parts[1]}-${parts[2]}',
    );
    if (date == null) return dayKey;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatTime(DateTime dateTime) {
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  void dispose() {
    // Cancel polling subscription
    _pollingSubscription?.cancel();
    _pollingSubscription = null;
  }
}
