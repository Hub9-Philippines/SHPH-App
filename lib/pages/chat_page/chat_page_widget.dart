import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/back_button/back_button_widget.dart';
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
      }
    };
    // Initialize Supabase real-time subscription for chat messages
    if (widget.roomId != null) {
      _model.initializeChatSubscription(widget.roomId!);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || widget.roomId == null) return;

    // Send message to Supabase
    _model.sendMessage(message, widget.roomId!);
    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primary,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.network(
                        widget.providerPhoto ??
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
                      ).image,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.providerName ?? 'Provider',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                            ),
                      ),
                      Text(
                        'Online',
                        style: AppTheme.of(context).bodySmall.override(
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Chat Messages Area
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                    itemCount: _model.messages.length,
                    itemBuilder: (context, index) {
                      final message = _model.messages[index];
                      final isMe = message['isMe'] as bool;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin:
                              const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 4),
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 12, 16, 12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? AppTheme.of(context).primary
                                : AppTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              bottomRight: isMe
                                  ? Radius.zero
                                  : const Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Colors.black.withValues(alpha: 0.05),
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['text'] as String,
                                style: AppTheme.of(context).bodyMedium.override(
                                      color: isMe
                                          ? Colors.white
                                          : AppTheme.of(context).primaryText,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['time'] as String,
                                style: AppTheme.of(context).bodySmall.override(
                                      color: isMe
                                          ? Colors.white70
                                          : AppTheme.of(context).secondaryText,
                                      fontSize: 10,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Message Input Bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 8, 16, 8),
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: AppTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            style: AppTheme.of(context).bodyMedium,
                            maxLines: null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
