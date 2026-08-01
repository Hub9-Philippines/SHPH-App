import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
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
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || widget.roomId == null) {
      return;
    }

    _messageController.clear();
    await _model.sendMessage(message, widget.roomId!);
    _scrollToBottom(animated: true);
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
                _buildComposer(context),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppThemeData.shadowCard,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 10),
              _buildAvatar(context, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.providerName ?? 'Conversation',
                      style: AppTheme.of(context).titleMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                            color: AppTheme.of(context).primaryText,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _model.messages.isEmpty
                          ? 'Start the conversation'
                          : 'Connected to this thread',
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.plusJakartaSans(),
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Chat',
                  style: AppTheme.of(context).labelSmall.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: AppTheme.of(context).primary,
                      ),
                ),
              ),
            ],
          ),
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

    if (_model.messages.isEmpty) {
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
                  Icons.chat_bubble_outline_rounded,
                  color: AppTheme.of(context).primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'No messages yet',
                style: AppTheme.of(context).titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      color: AppTheme.of(context).primaryText,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Send the first message to coordinate service details, arrival timing, or updates.',
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: AppTheme.of(context).secondaryText,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      itemCount: _model.messages.length,
      itemBuilder: (context, index) {
        final message = _model.messages[index];
        final isMe = message['isMe'] as bool? ?? false;
        final showStatus = isMe && message['status'] != null;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.68,
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.of(context).primary : AppTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(22),
                        topRight: const Radius.circular(22),
                        bottomLeft: Radius.circular(isMe ? 22 : 8),
                        bottomRight: Radius.circular(isMe ? 8 : 22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: AppTheme.of(context).primaryText.withValues(alpha: 0.06),
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'] as String? ?? '',
                          style: AppTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.plusJakartaSans(),
                                color: isMe
                                    ? AppTheme.of(context).secondaryBackground
                                    : AppTheme.of(context).primaryText,
                              )
                              .copyWith(height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message['time'] as String? ?? '',
                              style: AppTheme.of(context).labelSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    color: isMe
                                        ? AppTheme.of(context).secondaryBackground.withValues(alpha: 0.78)
                                        : AppTheme.of(context).textTertiary,
                                  ),
                            ),
                            if (showStatus) ...[
                              const SizedBox(width: 8),
                              Text(
                                _statusLabel(message['status'] as String?),
                                style: AppTheme.of(context).labelSmall.override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: isMe
                                          ? AppTheme.of(context).secondaryBackground.withValues(alpha: 0.86)
                                          : AppTheme.of(context).secondaryText,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isMe) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.providerName ?? 'Contact',
                      style: AppTheme.of(context).labelSmall.override(
                            font: GoogleFonts.plusJakartaSans(),
                            color: AppTheme.of(context).textTertiary,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer(BuildContext context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: AppThemeData.shadowLg,
                  ),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Write a message...',
                      hintStyle: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.plusJakartaSans(),
                            color: AppTheme.of(context).textTertiary,
                          ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: AppTheme.of(context).primaryText,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _sendMessage,
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
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildAvatar(BuildContext context, {required double size}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: (widget.providerPhoto ?? '').trim().isEmpty
            ? Icon(
                Icons.person_rounded,
                color: AppTheme.of(context).primary,
                size: size * 0.46,
              )
            : Image.network(
                widget.providerPhoto!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person_rounded,
                  color: AppTheme.of(context).primary,
                  size: size * 0.46,
                ),
              ),
      );

  String _statusLabel(String? status) {
    switch (status) {
      case 'sending':
        return 'Sending';
      case 'failed':
        return 'Failed';
      case 'sent':
      case 'delivered':
        return 'Sent';
      default:
        return '';
    }
  }
}
