import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        text: 'Hello! I\'m your virtual assistant. How can I help you today?',
        isUser: false,
      ),
    );
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
            text: 'Sorry, I encountered an error. Please try again later.',
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
      return _buildLocalResponse(message);
    }

    final messages = _buildMessagePayload(message);

    try {
      final httpResponse = await http
          .post(
            Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://shph.app',
              'X-Title': 'SHPH',
            },
            body: jsonEncode({
              'model': 'deepseek/deepseek-v4-flash-free',
              'messages': messages,
              'temperature': 0.7,
              'max_tokens': 1024,
            }),
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
      return _buildLocalResponse(message);
    } catch (_) {
      return _buildLocalResponse(message);
    }
  }

  List<Map<String, String>> _buildMessagePayload(String newMessage) {
    final msgs = <Map<String, String>>[];
    for (final msg in _messages) {
      msgs.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }
    msgs.add({'role': 'user', 'content': newMessage});
    return msgs;
  }

  String _buildLocalResponse(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('book') || lower.contains('service')) {
      return 'To book a service, go to the Home page, select a category, choose your service, and follow the booking steps. You can track your booking status from the Bookings tab.';
    }
    if (lower.contains('cancel')) {
      return 'You can cancel a booking from the booking details page. Open My Bookings, select the booking, and tap "Cancel Booking". Please note that cancellation policies may apply.';
    }
    if (lower.contains('payment') || lower.contains('pay')) {
      return 'We accept credit/debit cards, GCash, Maya, and other e-wallets. You can manage your payment methods in Profile > Payment Methods.';
    }
    if (lower.contains('refund')) {
      return 'Refunds are processed within 5-7 business days to your original payment method. For specific refund inquiries, please contact our support team.';
    }
    if (lower.contains('password') || lower.contains('login')) {
      return 'You can reset your password by tapping "Forgot Password" on the login screen. For security changes, go to Profile > Security.';
    }
    if (lower.contains('profile') || lower.contains('edit')) {
      return 'Go to your Profile page and tap "Edit Profile" to update your information. You can change your name, photo, and contact details there.';
    }
    if (lower.contains('help') || lower.contains('support')) {
      return 'You\'re in the right place! Browse our FAQs on the Help page for common questions, or chat with me for more specific assistance.';
    }
    return 'I\'m here to help! You can ask me about booking services, cancellations, payments, account settings, or any other questions about the app. What would you like to know?';
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
              child: Icon(Icons.smart_toy_rounded, color: theme.primary, size: 22),
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
                    style: theme.labelSmall.override(color: theme.secondaryText),
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
    final align = msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
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
    defaultValue: 'your-openrouter-api-key-here',
  );
}
