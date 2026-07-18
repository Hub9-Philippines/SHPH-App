import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';

class HelpSupportWidget extends StatefulWidget {
  const HelpSupportWidget({super.key});

  static const String routeName = 'HelpSupport';
  static const String routePath = '/pro/help-support';

  @override
  State<HelpSupportWidget> createState() => _HelpSupportWidgetState();
}

class _HelpSupportWidgetState extends State<HelpSupportWidget> {
  static const _supportEmail = 'support@serbisyohubph.com';

  final List<Map<String, dynamic>> faqs = [
    {
      'question': 'How do I accept a job request?',
      'answer':
          'When you receive a job request, go to the "Jobs" tab in your dashboard. Tap on the job card and click "Accept" to confirm the booking.',
    },
    {
      'question': 'How do I get paid?',
      'answer':
          'Payments are processed automatically after you complete a job. Go to the "Earnings" tab to view your earnings and request a cash out to your linked payment method.',
    },
    {
      'question': 'What should I do if a client cancels?',
      'answer':
          'If a client cancels a booking, you will be notified. Cancellations within 24 hours of the scheduled time may incur a cancellation fee for the client.',
    },
    {
      'question': 'How do I update my service rates?',
      'answer':
          'Go to your Profile page, scroll down to "Hourly Rate" section, enter your new rate, and tap "Update Rate".',
    },
    {
      'question': 'How can I become a verified provider?',
      'answer':
          'Complete the eKYC verification process by submitting your valid ID and going through face verification. Verified providers get more visibility and trust from clients.',
    },
    {
      'question': 'What if I\'m running late for a job?',
      'answer':
          'Use the chat feature to message the client and inform them of the delay. Good communication helps maintain your rating and client satisfaction.',
    },
    {
      'question': 'How do ratings work?',
      'answer':
          'After completing a job, clients can rate your service from 1-5 stars and leave a review. Your overall rating is the average of all your ratings.',
    },
    {
      'question': 'Can I reject a job request?',
      'answer':
          'Yes, you can decline job requests if you\'re unavailable or the job doesn\'t match your services. However, frequent rejections may affect your visibility.',
    },
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Help & Support',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
          ),
          backgroundColor: AppTheme.of(context).primaryBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Contact Support Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.of(context).primary,
                      AppTheme.of(context).primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need more help?',
                      style: AppTheme.of(context).titleMedium.override(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our support team is available 24/7 to assist you with any issues or questions.',
                      style: AppTheme.of(context).bodyMedium.override(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildContactButton(
                            icon: Icons.email,
                            label: 'Email Us',
                            onTap: () => _openSupportEmail(
                              subject: 'Provider Support Request',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildContactButton(
                            icon: Icons.chat,
                            label: 'Live Chat',
                            onTap: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await _openSupportEmail(
                                subject: 'Provider Live Support Request',
                                body:
                                    'Please describe your issue and include any booking or account details that can help the support team assist you faster.',
                              );
                              if (!mounted) {
                                return;
                              }
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Live support is currently routed to support email.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // FAQs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: AppTheme.of(context).titleMedium.override(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: faqs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _buildFaqCard(faqs[index]),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      );

  Future<void> _openSupportEmail({
    required String subject,
    String? body,
  }) async {
    final encodedSubject = Uri.encodeComponent(subject);
    final encodedBody = Uri.encodeComponent(body ?? '');
    await launchURL(
      'mailto:$_supportEmail?subject=$encodedSubject&body=$encodedBody',
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: AppTheme.of(context).primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTheme.of(context).bodyMedium.override(
                      color: AppTheme.of(context).primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      );

  Widget _buildFaqCard(Map<String, dynamic> faq) => ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        collapsedBackgroundColor: AppTheme.of(context).secondaryBackground,
        backgroundColor: AppTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          faq['question'],
          style: AppTheme.of(context).bodyLarge.override(
                fontWeight: FontWeight.w600,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer'],
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ),
        ],
      );
}
