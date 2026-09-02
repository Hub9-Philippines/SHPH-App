import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/cupertino_ui/cupertino_page_header.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

class TermsOfServiceWidget extends StatefulWidget {
  const TermsOfServiceWidget({super.key});

  static const String routeName = 'TermsOfService';
  static const String routePath = '/terms-of-service';

  @override
  State<TermsOfServiceWidget> createState() => _TermsOfServiceWidgetState();
}

class _TermsOfServiceWidgetState extends State<TermsOfServiceWidget> {
  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CupertinoPageHeader(
            title: _l10n.tosTitle,
            backgroundColor: AppTheme.of(context).primaryBackground,
            titleStyle: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _l10n.tosLastUpdated('March 15, 2024'),
                style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
              const SizedBox(height: 24),
              _section(
                title: _l10n.tosAcceptance,
                body:
                    'By accessing or using Serbisyo, you agree to be bound by these Terms of Service. '
                    'If you do not agree to all the terms, you may not use the platform.\n\n'
                    'We reserve the right to update these terms at any time. Continued use of the platform '
                    'after changes constitutes acceptance of the new terms.',
              ),
              _section(
                title: _l10n.tosAccounts,
                body:
                    'You are responsible for maintaining the confidentiality of your account credentials '
                    'and for all activities that occur under your account. You must provide accurate, '
                    'current, and complete information during registration.\n\n'
                    'You may not use the platform if you are under 18 years of age.',
              ),
              _section(
                title: _l10n.tosServicesBookings,
                body:
                    'Serbisyo connects clients with service providers. While we facilitate the booking '
                    'and payment process, the actual service delivery is between the client and the provider.\n\n'
                    'We do not guarantee the quality, safety, or legality of services listed on the platform. '
                    'Users are encouraged to communicate directly and verify credentials before engaging.',
              ),
              _section(
                title: _l10n.tosProhibited,
                body:
                    'You agree not to use the platform for any unlawful purpose, to impersonate any person, '
                    'to interfere with the operation of the platform, or to engage in any fraudulent activity.\n\n'
                    'Violation of these rules may result in immediate termination of your account.',
              ),
              _section(
                title: _l10n.tosPaymentsFees,
                body:
                    'All payments are processed securely through our payment partners. Service fees are '
                    'clearly displayed before you confirm a booking. Refunds are handled in accordance '
                    'with our refund policy, which varies by service category.',
              ),
              _section(
                title: _l10n.tosLimitation,
                body:
                    'Serbisyo shall not be liable for any indirect, incidental, special, consequential, '
                    'or punitive damages arising from your use of the platform. Our total liability is '
                    'limited to the amount you paid for the specific service in question.',
              ),
              _section(
                title: _l10n.tosContact,
                body:
                    'For questions about these terms, please contact us at '
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
