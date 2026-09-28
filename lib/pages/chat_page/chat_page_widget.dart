import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '/components/call_accept_permission_sheet.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart' show BookingDetailsWidget;
import '/l10n/app_localizations.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'chat_page_model.dart';

export 'chat_page_model.dart';

class ChatPageWidget extends StatefulWidget {
  const ChatPageWidget({
    super.key,
    this.roomId,
    this.providerName,
    this.providerPhoto,
  });

  final String? roomId;
  final String? providerName;
  final String? providerPhoto;

  static String routeName = 'ChatPage';
  static String routePath = '/chat/:roomId';

  @override
  State<ChatPageWidget> createState() => _ChatPageWidgetState();
}

class _ChatPageWidgetState extends State<ChatPageWidget> {
  late ChatPageModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSendingImage = false;
  bool _showStickerPicker = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ChatPageModel.new);
    _model.onStateChanged = () {
      if (mounted) {
        safeSetState(() {});
        _scrollToBottom(animated: true);
      }
    };

    if (widget.roomId != null) {
      _model
        ..initializeChatSubscription(widget.roomId!)
        ..markThreadRead(widget.roomId!);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _headerName =>
      _model.otherParticipantName ?? widget.providerName ?? _l10n.ckConversation;

  String get _headerPhoto =>
      _model.otherParticipantPhoto ?? widget.providerPhoto ?? '';

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || widget.roomId == null) {
      return;
    }

    _messageController.clear();
    safeSetState(() => _showStickerPicker = false);
    final ok = await _model.sendMessage(message, widget.roomId!);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.ckFailed)),
      );
    }
    _scrollToBottom(animated: true);
  }

  Future<void> _pickAndSendImage() async {
    if (widget.roomId == null || _isSendingImage) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 72,
        maxWidth: 1600,
      );
      if (picked == null) return;
      safeSetState(() => _isSendingImage = true);
      final ok = await _model.sendImage(picked.path, widget.roomId!);
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.ckFailed)),
        );
      }
    } catch (e) {
      LoggingService.error('Image pick failed: $e', tag: 'ChatPage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.ckFailed)),
        );
      }
    } finally {
      if (mounted) {
        safeSetState(() => _isSendingImage = false);
      }
    }
  }

  Future<void> _startCall({required bool video}) async {
    if (widget.roomId == null || _model.isCallActive) return;
    // Permission gate acquires mic (and camera for video) BEFORE the call
    // starts — first-ever calls work, and video-without-camera is refused
    // here rather than entering a tile-less call.
    await CallAcceptPermissionSheet.show(
      context,
      callType: video ? CallType.video : CallType.audio,
      onMediaAcquired: (stream) {
        _initiateCall(video: video, preAcquiredStream: stream);
      },
    );
  }

  Future<void> _initiateCall({
    required bool video,
    webrtc.MediaStream? preAcquiredStream,
  }) async {
    try {
      await _model.startCall(
        threadId: widget.roomId!,
        video: video,
        preAcquiredStream: preAcquiredStream,
      );
    } catch (e) {
      preAcquiredStream?.getTracks().forEach((t) => t.stop());
      LoggingService.error(
        'Chat room call failed: $e',
        tag: 'ChatPage',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.csCallFailed)),
        );
      }
    }
  }

  void _openBooking() {
    final bookingId = _model.bookingId;
    if (bookingId == null || bookingId.isEmpty) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => BookingDetailsWidget(bookingId: bookingId),
      ),
    );
  }

  Future<void> _confirmBlock() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        title: Text(
          _l10n.ckBlockUser,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.of(context).primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          _l10n.ckBlockConfirm,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.of(context).secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(_l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.of(context).error,
            ),
            child: Text(_l10n.ckBlockUser),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final blocked = await _model.blockOtherParticipant();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(blocked ? _l10n.ckBlockDone : _l10n.ckBlockFailed),
      ),
    );
  }

  void _openOverflowMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search_rounded),
              title: Text(_l10n.ckSearchMessages),
              onTap: () {
                Navigator.of(sheetContext).pop();
                safeSetState(() => _model.setSearchActive(true));
              },
            ),
            if ((_model.bookingId ?? '').isNotEmpty)
              ListTile(
                leading: const Icon(Icons.receipt_long_rounded),
                title: Text(_l10n.ckViewBooking),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openBooking();
                },
              ),
            if (_model.isDirectThread)
              ListTile(
                leading: Icon(
                  Icons.block_rounded,
                  color: AppTheme.of(context).error,
                ),
                title: Text(
                  _l10n.ckBlockUser,
                  style: TextStyle(color: AppTheme.of(context).error),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _confirmBlock();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom({required bool animated}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).secondaryBackground,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                if (_model.isSearching) _buildSearchBar(context),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppThemeData.shadowLg,
                    ),
                    child: _buildConversationBody(context),
                  ),
                ),
                _buildQuickReplies(context),
                _buildComposer(context),
              ],
            ),
          ),
        ),
      );

  // ── Header: back, avatar, name, search / audio / video / overflow ──
  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
            _buildAvatar(context, size: 42),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _headerName,
                    style: AppTheme.of(context).titleMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: AppTheme.of(context).primaryText,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _model.messages.isEmpty
                        ? _l10n.ckStartConversation
                        : _l10n.ckConnected,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: AppTheme.of(context).secondaryText,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _HeaderIconButton(
              icon: Icons.search_rounded,
              tooltip: _l10n.ckSearchMessages,
              onTap: () => safeSetState(() => _model.setSearchActive(true)),
            ),
            if (_model.isDirectThread) ...[
              _HeaderIconButton(
                icon: Icons.call_rounded,
                tooltip: _l10n.ckStartAudioCall,
                onTap: () => _startCall(video: false),
              ),
              _HeaderIconButton(
                icon: Icons.videocam_rounded,
                tooltip: _l10n.ckStartVideoCall,
                onTap: () => _startCall(video: true),
              ),
            ],
            _HeaderIconButton(
              icon: Icons.more_vert_rounded,
              tooltip: _l10n.ckMoreOptions,
              onTap: _openOverflowMenu,
            ),
          ],
        ),
      );

  Widget _buildSearchBar(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _model.setSearchQuery,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: _l10n.ckSearchHint,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppTheme.of(context).textTertiary,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppTheme.of(context).secondaryText,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: AppTheme.of(context).primaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _searchController.clear();
                safeSetState(() => _model.setSearchActive(false));
              },
              icon: Icon(
                Icons.close_rounded,
                color: AppTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      );

  Widget _buildConversationBody(BuildContext context) {
    if (_model.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        itemCount: 6,
        itemBuilder: (context, index) => Align(
          alignment:
              index.isEven ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.52,
            height: 54,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      );
    }

    final visible = _model.visibleMessages;
    if (visible.isEmpty) {
      final searching = _model.searchQuery.trim().isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  searching
                      ? Icons.search_off_rounded
                      : Icons.chat_bubble_outline_rounded,
                  color: AppTheme.of(context).primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                searching ? _l10n.ckNoSearchResults : _l10n.ckNoMessages,
                style: AppTheme.of(context).titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      color: AppTheme.of(context).primaryText,
                    ),
              ),
              if (!searching) ...[
                const SizedBox(height: 8),
                Text(
                  _l10n.ckEmptySubtitle,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      itemCount: visible.length + _model.groupedMessages.length,
      itemBuilder: (context, index) => _buildRowWithSeparators(visible, index),
    );
  }

  /// Interleaves date separators with the flat message list: a row at index
  /// [i] is either the day chip that precedes its group's first message or
  /// the message itself. Mirrors the web room's `groupedMessages`.
  Widget _buildRowWithSeparators(List<ChatMessageView> visible, int i) {
    // Walk the flattened (groupKey, count) pairs to place separators.
    final groups = _model.groupedMessages;
    var consumed = 0;
    for (final group in groups) {
      if (i == consumed) {
        return _buildDateChip(_model.formatDayLabel(group.key));
      }
      consumed += 1;
      final groupLen = group.value.length;
      if (i < consumed + groupLen) {
        final message = group.value[i - consumed];
        if (message.isSystem) {
          return _buildSystemMessage(message);
        }
        return _buildMessageBubble(context, message);
      }
      consumed += groupLen;
    }
    return const SizedBox.shrink();
  }

  Widget _buildDateChip(String label) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTheme.of(context).labelSmall.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  color: AppTheme.of(context).textTertiary,
                ),
          ),
        ),
      );

  Widget _buildSystemMessage(ChatMessageView message) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.of(context).primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam_rounded,
                size: 14,
                color: AppTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message.text,
                  style: AppTheme.of(context).labelSmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildMessageBubble(BuildContext context, ChatMessageView message) {
    final theme = AppTheme.of(context);
    final isMe = message.isMine;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              _buildAvatar(context, size: 28),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  message.imageUrl != null ? 6 : 16,
                  message.imageUrl != null ? 6 : 12,
                  message.imageUrl != null ? 6 : 16,
                  message.imageUrl != null ? 6 : 10,
                ),
                decoration: BoxDecoration(
                  color: isMe ? theme.primary : theme.secondaryBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(22),
                    topRight: const Radius.circular(22),
                    bottomLeft: Radius.circular(isMe ? 22 : 8),
                    bottomRight: Radius.circular(isMe ? 8 : 22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: theme.primaryText.withValues(alpha: 0.06),
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 240,
                            maxHeight: 240,
                          ),
                          child: Image.network(
                            message.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                _l10n.ckImageMessage,
                                style: theme.labelSmall.override(
                                  font: GoogleFonts.plusJakartaSans(),
                                  color: isMe
                                      ? theme.secondaryBackground
                                      : theme.primaryText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (message.text.isNotEmpty) ...[
                      if (message.imageUrl != null)
                        const SizedBox(height: 6),
                      Text(
                        message.text,
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: isMe ? theme.secondaryBackground : theme.primaryText,
                        ).copyWith(height: 1.4),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _model.formatTime(message.createdAt),
                      style: theme.labelSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                        ),
                        color: isMe
                            ? theme.secondaryBackground.withValues(alpha: 0.78)
                            : theme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick replies (web parity: chips while the thread is fresh) ──
  Widget _buildQuickReplies(BuildContext context) {
    if (!_model.showQuickReplies || _model.isSearching) {
      return const SizedBox.shrink();
    }
    final replies = [
      _l10n.ckQuickReplyHello,
      _l10n.ckQuickReplyTomorrow,
      _l10n.ckQuickReplyRate,
      _l10n.ckQuickReplyThanks,
    ];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: replies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => OutlinedButton(
          onPressed: () {
            _messageController.text = replies[index];
            _sendMessage();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.of(context).primary,
            side: BorderSide(
              color: AppTheme.of(context).primary.withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(replies[index]),
        ),
      ),
    );
  }

  // ── Composer pill: attach + input + sticker, round send outside ──
  Widget _buildComposer(BuildContext context) {
    final hasText = _messageController.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppThemeData.shadowLg,
                ),
                child: Row(
                  children: [
                    _ComposerIconButton(
                      icon: _isSendingImage
                          ? Icons.hourglass_top_rounded
                          : Icons.attach_file_rounded,
                      onTap: _isSendingImage ? null : _pickAndSendImage,
                    ),
                    Expanded(
                      child: AppTextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        onChanged: (_) => safeSetState(() {}),
                        textInputAction: TextInputAction.newline,
                        onSubmitted: (_) => _sendMessage(),
                        placeholder: _l10n.ckWriteMessage,
                        placeholderStyle:
                            AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.plusJakartaSans(),
                                  color: AppTheme.of(context).textTertiary,
                                ),
                        radius: 26,
                        fillColor: AppTheme.of(context).primaryBackground,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.plusJakartaSans(),
                              color: AppTheme.of(context).primaryText,
                            ),
                      ),
                    ),
                    _ComposerIconButton(
                      icon: _showStickerPicker
                          ? Icons.close_rounded
                          : Icons.emoji_emotions_outlined,
                      onTap: () => safeSetState(
                        () => _showStickerPicker = !_showStickerPicker,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: hasText ? _sendMessage : null,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.of(context).primary,
                      AppTheme.of(context).primary.withValues(alpha: 0.82),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: AppThemeData.shadowLg,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: hasText
                      ? AppTheme.of(context).onPrimary
                      : AppTheme.of(context).onPrimary.withValues(alpha: 0.45),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, {required double size}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: _headerPhoto.trim().isEmpty
            ? Icon(
                Icons.person_rounded,
                color: AppTheme.of(context).primary,
                size: size * 0.46,
              )
            : Image.network(
                _headerPhoto,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_rounded,
                  color: AppTheme.of(context).primary,
                  size: size * 0.46,
                ),
              ),
      );
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 22,
          color: enabled
              ? AppTheme.of(context).primary
              : AppTheme.of(context).textTertiary,
        ),
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  const _ComposerIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 22,
          color: AppTheme.of(context).secondaryText,
        ),
      ),
    );
  }
}
