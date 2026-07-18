import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/shph_api.dart';
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

  Future<void> _initiateCall(String callType) async {
    if (widget.roomId == null) return;
    try {
      await ShphChatApi.instance
          .initiateCall(threadId: widget.roomId!, callType: callType);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$callType call initiated...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call failed: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadFile() async {
    final selection = await FilePicker.pickFiles(
      withData: true,
      allowMultiple: false,
    );
    final file = selection == null ? null : selection.files.single;
    if (file?.bytes == null || widget.roomId == null || !mounted) return;
    try {
      final result = await ShphChatApi.instance.uploadFile(
        widget.roomId!,
        fileBytes: file!.bytes!,
        fileName: file.name,
      );
      if (mounted) {
        final messageUrl = result['url']?.toString();
        if (messageUrl == null || messageUrl.isEmpty) {
          throw StateError('The API did not return an attachment URL');
        }
        _messageController.text = messageUrl;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('File attached'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Upload failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showMessageActions(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Message'),
              onTap: () {
                Navigator.pop(ctx);
                _editMessage(message);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text('Delete Message',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteMessage(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editMessage(Map<String, dynamic> message) async {
    final controller =
        TextEditingController(text: message['text'] as String? ?? '');
    final newText = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (newText == null || newText.isEmpty || widget.roomId == null || !mounted)
      return;
    try {
      await ShphChatApi.instance
          .editMessage(widget.roomId!, '', content: newText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Message edited'), backgroundColor: Colors.green),
        );
        _model.initializeChatSubscription(widget.roomId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to edit: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteMessage(Map<String, dynamic> message) async {
    if (widget.roomId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ShphChatApi.instance.deleteMessage(widget.roomId!, '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Message deleted'), backgroundColor: Colors.green),
        );
        _model.initializeChatSubscription(widget.roomId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
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

  Future<void> _showThreadInfo() async {
    if (widget.roomId == null) return;
    try {
      final details =
          await ShphChatApi.instance.getThreadDetails(widget.roomId!);
      if (!mounted) return;
      final participants = details['participants'] as List? ?? [];
      final createdAt = details['created_at']?.toString() ?? '';
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  const Text('Thread Info',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              if (widget.providerName != null) ...[
                _infoRow('Provider', widget.providerName!),
                const Divider(height: 1),
              ],
              if (participants.isNotEmpty) ...[
                _infoRow('Participants', participants.length.toString()),
                const Divider(height: 1),
              ],
              if (createdAt.isNotEmpty) ...[
                _infoRow('Created', createdAt),
                const Divider(height: 1),
              ],
              _infoRow('Thread ID', widget.roomId!.substring(0, 8)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load thread details: $e')),
      );
    }
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF4F7FB),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF8FBFF),
                          Color(0xFFF2F7FB),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _buildConversationBody(),
                  ),
                ),
                _buildComposer(),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              wrapWithModel(
                model: _model.backButtonModel,
                updateCallback: () => safeSetState(() {}),
                child: const BackButtonWidget(),
              ),
              const SizedBox(width: 10),
              _buildAvatar(size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.providerName ?? 'Conversation',
                      style: AppTheme.of(context).titleMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                            color: const Color(0xFF14213D),
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
                            font: GoogleFonts.poppins(),
                            color: const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Chat',
                  style: AppTheme.of(context).labelSmall.override(
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                        color: AppTheme.of(context).primary,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _initiateCall('audio'),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(Icons.phone_rounded,
                      size: 18, color: AppTheme.of(context).primary),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _initiateCall('video'),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(Icons.videocam_rounded,
                      size: 18, color: AppTheme.of(context).primary),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showThreadInfo,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(Icons.info_outline,
                      size: 18, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildConversationBody() {
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
              color: Colors.white.withValues(alpha: 0.88),
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
                  color: const Color(0xFFEAF6F2),
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
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      color: const Color(0xFF14213D),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Send the first message to coordinate service details, arrival timing, or updates.',
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(),
                      color: const Color(0xFF64748B),
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
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress:
                        isMe ? () => _showMessageActions(message) : null,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      decoration: BoxDecoration(
                        color:
                            isMe ? AppTheme.of(context).primary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(22),
                          topRight: const Radius.circular(22),
                          bottomLeft: Radius.circular(isMe ? 22 : 8),
                          bottomRight: Radius.circular(isMe ? 8 : 22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withValues(alpha: 0.06),
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
                                  font: GoogleFonts.poppins(),
                                  color: isMe
                                      ? Colors.white
                                      : const Color(0xFF14213D),
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
                                      font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      color: isMe
                                          ? Colors.white.withValues(alpha: 0.78)
                                          : const Color(0xFF94A3B8),
                                    ),
                              ),
                              if (showStatus) ...[
                                const SizedBox(width: 8),
                                Text(
                                  _statusLabel(message['status'] as String?),
                                  style:
                                      AppTheme.of(context).labelSmall.override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: isMe
                                                ? Colors.white
                                                    .withValues(alpha: 0.86)
                                                : const Color(0xFF64748B),
                                          ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isMe) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.providerName ?? 'Contact',
                      style: AppTheme.of(context).labelSmall.override(
                            font: GoogleFonts.poppins(),
                            color: const Color(0xFF94A3B8),
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

  Widget _buildComposer() => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: _pickAndUploadFile,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.attach_file_rounded,
                      size: 22, color: Color(0xFF64748B)),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 22,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (value) {
                      if (widget.roomId != null) {
                        _model.sendTypingIndicator(widget.roomId!);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Write a message...',
                      hintStyle: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(),
                            color: const Color(0xFF94A3B8),
                          ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.poppins(),
                          color: const Color(0xFF14213D),
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
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
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

  Widget _buildAvatar({required double size}) => Container(
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
