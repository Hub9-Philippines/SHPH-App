import 'package:flutter/material.dart';

import '/api/models/support_ticket.dart';
import '/api/resources/support_api.dart';
import '/theme/app_theme.dart';

/// Help assistant — FAQ accordion + support ticket creation.
///
/// Mirrors `shph-app/src/views/support/HelpAssistantPage.vue`. The Vue page
/// uses Gemini AI for chat; the SHPH backend only exposes FAQ + tickets, so
/// this Flutter port is FAQ + ticket form only (no AI chat).
class HelpAssistantPage extends StatefulWidget {
  const HelpAssistantPage({super.key});

  static String routeName = 'HelpAssistant';
  static String routePath = '/help-assistant';

  @override
  State<HelpAssistantPage> createState() => _HelpAssistantPageState();
}

class _HelpAssistantPageState extends State<HelpAssistantPage> {
  List<ShphFaq> _faq = const [];
  bool _isLoadingFaq = true;
  String? _faqError;

  final _messageCtrl = TextEditingController();
  String _selectedCategory = 'general';
  bool _isSubmitting = false;
  String? _submitMessage;

  static const _categories = [
    ('general', 'General'),
    ('booking', 'Booking'),
    ('payment', 'Payment'),
    ('account', 'Account'),
    ('technical', 'Technical'),
  ];

  @override
  void initState() {
    super.initState();
    _loadFaq();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFaq() async {
    setState(() {
      _isLoadingFaq = true;
      _faqError = null;
    });
    try {
      final faq = await ShphSupportApi.instance.listFaq();
      if (mounted) {
        setState(() {
          _faq = faq;
          _isLoadingFaq = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFaq = false;
          _faqError = 'Failed to load FAQ: $e';
        });
      }
    }
  }

  Future<void> _submitTicket() async {
    final message = _messageCtrl.text.trim();
    if (message.isEmpty) {
      setState(() => _submitMessage = 'Please describe your issue');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
    });
    try {
      await ShphSupportApi.instance.createTicket(
        category: _selectedCategory,
        message: message,
      );
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitMessage = 'Ticket submitted. We will contact you soon.';
        });
        _messageCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitMessage = 'Submission failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Help',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text('Frequently Asked Questions',
              style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (_isLoadingFaq)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_faqError != null)
            _ErrorRow(message: _faqError!, onRetry: _loadFaq)
          else if (_faq.isEmpty)
            _EmptyCard(label: 'No FAQ entries yet')
          else
            ..._faq.map((f) => _FaqTile(faq: f)),
          const SizedBox(height: 24),
          Text('Contact Support',
              style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Can\'t find what you need? Submit a ticket and our team will get back to you.',
            style: theme.bodyMedium.override(color: theme.secondaryText),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$2)))
                .toList(),
            onChanged: (v) =>
                setState(() => _selectedCategory = v ?? 'general'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Describe your issue or question',
              border: OutlineInputBorder(),
            ),
          ),
          if (_submitMessage != null) ...[
            const SizedBox(height: 12),
            Text(_submitMessage!,
                style: theme.bodyMedium.override(
                  color: _submitMessage!.startsWith('Ticket submitted')
                      ? Colors.green.shade700
                      : theme.error,
                )),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submitTicket,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_isSubmitting ? 'Submitting…' : 'Submit Ticket'),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});
  final ShphFaq faq;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Text(faq.question,
            style: theme.bodyMedium.override(fontWeight: FontWeight.w700)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(faq.answer, style: theme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(color: theme.secondaryText)),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      children: [
        Text(message, style: theme.bodyMedium.override(color: theme.error)),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
