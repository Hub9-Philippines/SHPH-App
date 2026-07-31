import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';

class PrivacyPolicyWidget extends StatefulWidget {
  const PrivacyPolicyWidget({super.key});

  static const String routeName = 'PrivacyPolicy';
  static const String routePath = '/privacy-policy';

  @override
  State<PrivacyPolicyWidget> createState() => _PrivacyPolicyWidgetState();
}

class _PrivacyPolicyWidgetState extends State<PrivacyPolicyWidget> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Privacy Policy',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated: March 15, 2024',
                style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
              const SizedBox(height: 24),
              _section(
                title: 'Information We Collect',
                body:
                    'We collect information you provide directly, such as when you create an account, '
                    'book a service, or communicate with other users. This includes your name, email address, '
                    'phone number, and payment details.\n\n'
                    'We also automatically collect certain information when you use the app, including '
                    'device information, location data (with your permission), and usage statistics.',
              ),
              _section(
                title: 'How We Use Your Information',
                body:
                    'Your information is used to provide, maintain, and improve our services; '
                    'process transactions; send notifications; and personalize your experience.\n\n'
                    'We may also use your information to communicate with you about updates, '
                    'security alerts, and support messages.',
              ),
              _section(
                title: 'Information Sharing',
                body:
                    'We do not sell your personal information. We may share your information with '
                    'service providers who help us operate the platform, and with other users as '
                    'necessary to facilitate bookings (e.g., your name and contact details are shared '
                    'with the service provider you book).',
              ),
              _section(
                title: 'Data Security',
                body:
                    'We implement industry-standard security measures to protect your data, including '
                    'encryption in transit and at rest. However, no method of transmission over the '
                    'Internet is 100% secure.',
              ),
              _section(
                title: 'Your Rights',
                body:
                    'You may access, update, or delete your account information at any time through '
                    'the app settings. You can also contact us to request a copy of your data or '
                    'to have it permanently deleted.',
              ),
              _section(
                title: 'Contact Us',
                body:
                    'If you have questions about this Privacy Policy, please contact us at '
                    'support@serbisyohubph.com.',
              ),
            ],
          ),
        ),
      );

  Widget _section({required String title, required String body}) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: AppTheme.of(context).secondaryText,
                    lineHeight: 1.6,
                  ),
            ),
          ],
        ),
      );
}
