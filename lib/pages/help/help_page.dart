import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/shph_api.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'chatbot_page.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  static String routeName = 'Help';
  static String routePath = '/help';

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<Map<String, dynamic>> _faq = [];
  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSupport();
  }

  Future<void> _loadSupport() async {
    if (mounted) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ShphSupportApi.instance.listFaq(),
        ShphSupportApi.instance.listTickets(),
      ]);
      final ticketData = results[1] as Map<String, dynamic>;
      final rawTickets = ticketData['results'] ?? ticketData['tickets'];
      if (!mounted) return;
      setState(() {
        _faq = (results[0] as List).whereType<Map<String, dynamic>>().toList();
        _tickets = rawTickets is List
            ? rawTickets.whereType<Map<String, dynamic>>().toList()
            : [];
      });
    } catch (e) {
      LoggingService.error('Support load failed: $e', tag: 'HelpPage');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createTicket() async {
    final subject = TextEditingController();
    final message = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New support ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subject,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: message,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'How can we help?'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (subject.text.trim().isNotEmpty &&
                  message.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (submitted != true) return;
    try {
      await ShphSupportApi.instance.createTicket({
        'subject': subject.text.trim(),
        'message': message.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support ticket created.')),
      );
      await _loadSupport();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create ticket: $e')),
      );
    }
  }

  Future<void> _showTicket(Map<String, dynamic> ticket) async {
    final id = ticket['id']?.toString();
    var detail = ticket;
    if (id != null) {
      try {
        detail = await ShphSupportApi.instance.getTicket(id);
      } catch (_) {}
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(detail['subject']?.toString() ?? 'Support ticket',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Status: ${detail['status'] ?? 'open'}'),
            const SizedBox(height: 16),
            Text((detail['message'] ?? detail['description'] ?? '').toString()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text(
          'Help & Support',
          style: theme.titleLarge.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSupport,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                children: [
                  _FaqSection(
                    theme: theme,
                    title: 'Frequently asked questions',
                    items: _faq
                        .map((item) => _FaqItem(
                              question: (item['question'] ??
                                      item['title'] ??
                                      'Question')
                                  .toString(),
                              answer: (item['answer'] ?? item['content'] ?? '')
                                  .toString(),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text('Your tickets', style: theme.titleSmall),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _createTicket,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('New ticket'),
                      ),
                    ],
                  ),
                  if (_tickets.isEmpty)
                    const Card(
                        child: ListTile(title: Text('No support tickets yet.')))
                  else
                    ..._tickets.map((ticket) => Card(
                          child: ListTile(
                            onTap: () => _showTicket(ticket),
                            leading: const Icon(Icons.support_agent_rounded),
                            title: Text(ticket['subject']?.toString() ??
                                'Support ticket'),
                            subtitle:
                                Text('Status: ${ticket['status'] ?? 'open'}'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                          ),
                        )),
                ],
              )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(ChatbotPage.routeName),
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat_rounded),
        label: const Text('Chat with us'),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({
    required this.theme,
    required this.title,
    required this.items,
  });

  final AppThemeData theme;
  final String title;
  final List<_FaqItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.titleSmall.override(
              font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              color: theme.secondaryText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  _FaqTile(
                    theme: theme,
                    item: items[i],
                  ),
                  if (!isLast)
                    Divider(
                      indent: 16,
                      endIndent: 16,
                      color: theme.alternate,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.theme, required this.item});

  final AppThemeData theme;
  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          item.question,
          style: theme.bodyMedium.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.answer,
              style: GoogleFonts.poppins(
                color: theme.secondaryText,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}
