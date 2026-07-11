import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
    _apiConfigured = OpenRouterConfig.apiKey.isNotEmpty &&
        OpenRouterConfig.apiKey != 'your-openrouter-api-key-here';
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

  void _buildSystemPrompt() {
    final name = currentUserDisplayName;
    final email = currentUserEmail;
    final uid = currentUserUid;

    _systemPrompt = '''
You are a helpful customer support assistant for the SHPH (Serbisyo Hub PH) app, a home services booking platform in the Philippines. Answer questions clearly and concisely based on the information below.

USER INFORMATION:
- Name: ${name.isNotEmpty ? name : 'Not set'}
- Email: ${email.isNotEmpty ? email : 'Not set'}
- User ID: ${uid.isNotEmpty ? uid : 'Not available'}

APP FEATURES:
- Service booking: Users browse categories, select services, choose date/time, and book
- Live matching: After booking, the app finds nearby providers in real-time
- Booking statuses: confirmed, en_route, on_site, in_progress, completed, cancelled
- Payment: credit/debit cards, GCash, Maya, e-wallets (managed in Profile > Payment Methods)
- Provider tracking: Real-time map with provider location and ETA
- Cancellation: Available from booking details page; policies may apply
- User profile: Edit name, photo, contact info from Profile page
- Notifications: Available in the notifications section

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
      final response = await _callOpenRouter(text);
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

  Future<String> _callOpenRouter(String message) async {
    final apiKey = OpenRouterConfig.apiKey;
    if (apiKey.isEmpty || apiKey == 'your-openrouter-api-key-here') {
      throw Exception('API key not configured');
    }

    final body = _buildRequestBody(message);

    final httpResponse = await http
        .post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://shph.app',
            'X-Title': 'SHPH',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (httpResponse.statusCode == 200) {
      final data = jsonDecode(httpResponse.body) as Map<String, dynamic>;
      final choices = data['choices'] as List;
      if (choices.isNotEmpty) {
        final content = choices[0]['message']['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
    }

    final errorBody = httpResponse.statusCode != 200
        ? 'API returned status ${httpResponse.statusCode}'
        : 'Empty response from API';
    throw Exception(errorBody);
  }

  Map<String, dynamic> _buildRequestBody(String newMessage) {
    final msgs = <Map<String, dynamic>>[
      {'role': 'system', 'content': _systemPrompt},
    ];
    for (final msg in _messages) {
      msgs.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }
    msgs.add({'role': 'user', 'content': newMessage});

    return {
      'model': 'deepseek/deepseek-v4-flash-free',
      'messages': msgs,
      'temperature': 0.7,
      'max_tokens': 2048,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.smart_toy_rounded, color: theme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat Assistant',
                  style: theme.titleSmall.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  _isLoading ? 'Typing...' : 'Online',
                  style: theme.labelSmall.override(
                    color: _isLoading ? theme.primary : const Color(0xFF16A34A),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
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
    );
  }

  Widget _buildBubble(_ChatMessage msg, AppThemeData theme) {
    final align =
        msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = msg.isUser ? theme.primary : theme.secondaryBackground;
    final textColor = msg.isUser ? Colors.white : theme.primaryText;
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
              style: GoogleFonts.poppins(
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
