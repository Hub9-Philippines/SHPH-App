import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/report_problem/report_problem_widget.dart';
import '/theme/app_theme.dart';

/// Client-facing Help & Support page.
class ClientHelpSupportWidget extends StatefulWidget {
  const ClientHelpSupportWidget({super.key});

  static const String routeName = 'ClientHelpSupport';
  static const String routePath = '/help-support';

  @override
  State<ClientHelpSupportWidget> createState() =>
      _ClientHelpSupportWidgetState();
}

class _ClientHelpSupportWidgetState extends State<ClientHelpSupportWidget> {
  static const String _supportEmail = 'support@serbisyohubph.com';

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How do I book a service?',
      'answer':
          'Browse or search for a service, select a provider, choose a date and time, then confirm your booking and payment.',
    },
    {
      'question': 'How do I cancel or reschedule a booking?',
      'answer':
          "Open the booking detail from the Bookings tab and tap 'Reschedule' or 'Cancel'. Cancellation fees may apply depending on timing.",
    },
    {
      'question': 'What payment methods are accepted?',
      'answer':
          'We accept credit/debit cards and major e-wallets through our secure payment partner.',
    },
    {
      'question': 'How do I track my provider?',
      'answer':
          'Once the provider is en route, you can see their live location on the booking detail map.',
    },
    {
      'question': 'How do refunds work?',
      'answer':
          'Refunds are processed to the original payment method. Processing times depend on your bank or wallet provider.',
    },
    {
      'question': 'How do I report a problem with a service?',
      'answer':
          'Open the booking detail, tap the menu, and select "Report a Problem". You can also email us directly below.',
    },
  ];

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:$_supportEmail');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: wrapWithModel(
          model: createModel(context, BackButtonModel.new),
          updateCallback: () => safeSetState(() {}),
          child: const BackButtonWidget(),
        ),
        title: Text(
          'Help & Support',
          style: theme.titleLarge.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactCard(theme),
              const SizedBox(height: 24),
              Text(
                'Frequently Asked Questions',
                style: theme.titleMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              _buildFaqList(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(AppThemeData theme) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help?',
              style: theme.titleMedium.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our support team is available to assist you. Reach out via email.',
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.email_outlined, color: theme.primary),
                title: Text(_supportEmail, style: theme.bodyLarge),
                trailing: Icon(Icons.chevron_right, color: theme.secondaryText),
                onTap: _launchEmail,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    Icon(Icons.report_problem_outlined, color: theme.primary),
                title: Text('Report a problem', style: theme.bodyLarge),
                trailing: Icon(Icons.chevron_right, color: theme.secondaryText),
                onTap: () => context.goNamed(ReportProblemWidget.routeName),
              ),
            ),
          ],
        ),
      );

  Widget _buildFaqList(AppThemeData theme) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return ExpansionTile(
            title: Text(
              faq['question']!,
              style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  faq['answer']!,
                  style: theme.bodyMedium.copyWith(color: theme.secondaryText),
                ),
              ),
            ],
          );
        },
      );
}
