import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/auth_util.dart';
import '/components/screen_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/ai_service.dart';
import '/theme/app_theme.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  static String routeName = 'Chatbot';
  static String routePath = '/chatbot';

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  _ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  String _systemPrompt = '';
  bool _apiConfigured = false;

  @override
  void initState() {
    super.initState();
    _apiConfigured = AIService.instance.isAvailable;
    _buildSystemPrompt();
    _messages.add(
      _ChatMessage(
        text: _apiConfigured
            ? 'Hello! I\'m your virtual assistant. How can I help you today?'
            : 'Hello! I\'m your virtual assistant. '
                'To enable AI responses, set the OPENROUTER_API_KEY '
                'environment variable. For now, I\'ll let you know '
                'when the AI is ready to assist.',
        isUser: false,
      ),
    );
  }

  void _buildSystemPrompt() async {
    final basePrompt = await AIService.instance.bookingSystemPrompt();
    final email = currentUserEmail;
    final uid = currentUserUid;

    _systemPrompt = '''
$basePrompt

ADDITIONAL USER INFO:
- Email: ${email.isNotEmpty ? email : 'Not set'}
- User ID: ${uid.isNotEmpty ? uid : 'Not available'}

Use the user's name when addressing them. If asked something you don't know, say so honestly. Never make up information. Keep responses friendly and helpful.
''';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;
    _inputController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await AIService.instance.chat(text, systemPrompt: _systemPrompt);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: _apiConfigured
                ? 'Sorry, I encountered an error connecting to the AI service. '
                    'Please check your connection and try again.'
                : 'AI chat requires an API key. '
                    'Please set OPENROUTER_API_KEY when building the app:\n'
                    '  flutter run --dart-define=OPENROUTER_API_KEY=sk-or-v1-...',
            isUser: false,
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: ScreenHeader(
                    title: 'Chat Assistant',
                    subtitle: _isLoading ? 'Typing...' : 'Online',
                    padding: const EdgeInsets.fromLTRB(0, 12, 20, 18),
                  ),
                ),
              ],
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                return _buildBubble(msg, theme);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Getting answer...',
                    style:
                        theme.labelSmall.override(color: theme.secondaryText),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              border: Border(top: BorderSide(color: theme.alternate)),
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: theme.secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: theme.alternate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildBubble(_ChatMessage msg, AppThemeData theme) {
    final align =
        msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = msg.isUser ? theme.primary : theme.secondaryBackground;
    final textColor = msg.isUser ? theme.secondaryBackground : theme.primaryText;
    final borderRadius = msg.isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OpenRouterConfig {
  OpenRouterConfig._();

  static const String apiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );
}
