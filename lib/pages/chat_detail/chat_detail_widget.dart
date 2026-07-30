import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'chat_detail_model.dart';

export 'chat_detail_model.dart';

class ChatDetailWidget extends StatefulWidget {
  const ChatDetailWidget({super.key, required this.threadId});

  final String threadId;

  static String routeName = 'ChatDetail';
  static String routePath = '/chat/:threadId';

  @override
  State<ChatDetailWidget> createState() => _ChatDetailWidgetState();
}

class _ChatDetailWidgetState extends State<ChatDetailWidget> {
  late ChatDetailModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ChatDetailModel.new);
    _model.loadThread(widget.threadId).then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final name = _model.threadDetails?['name']?.toString() ?? 'Chat';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primaryBackground,
          title: Text(name, style: theme.titleMedium),
          centerTitle: true,
          elevation: 0,
        ),
        body: _model.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _model.scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _model.messages.length,
                      itemBuilder: (context, index) {
                        final msg = _model.messages[index];
                        return _buildMessageBubble(context, msg, theme);
                      },
                    ),
                  ),
                  _buildInputBar(context, theme),
                ],
              ),
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, Map<String, dynamic> msg, AppThemeData theme) {
    final isMine = msg['sender']?.toString() == 'me' ||
        msg['is_mine'] == true;
    final content = msg['content']?.toString() ??
        msg['message_text']?.toString() ??
        '';
    final time = msg['created_at']?.toString() ?? '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine ? theme.primary : theme.secondaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMine
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isMine
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: GoogleFonts.plusJakartaSans(
                color: isMine ? Colors.white : theme.primaryText,
                fontSize: 14,
              ),
            ),
            if (time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatTime(time),
                  style: GoogleFonts.plusJakartaSans(
                    color: isMine
                        ? Colors.white.withValues(alpha: 0.7)
                        : theme.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInputBar(BuildContext context, AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _model.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: theme.textTertiary,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: theme.primaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.plusJakartaSans(
                color: theme.primaryText,
                fontSize: 14,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send_rounded, color: theme.primary),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final success = await _model.sendMessage(widget.threadId);
    if (success) safeSetState(() {});
  }
}
