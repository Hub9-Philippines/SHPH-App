import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/theme/app_theme.dart';

class AboutWidget extends StatefulWidget {
  const AboutWidget({super.key});

  static const String routeName = 'About';
  static const String routePath = '/pro/about';

  @override
  State<AboutWidget> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget> {
  static const _supportEmail = 'support@serbisyohubph.com';
  static const _websiteUrl = 'https://api.serbisyohub.ph';
  static const _facebookUrl = 'https://www.facebook.com/SerbisyoHub/';

  final String appVersion = '1.0.0';
  final String buildNumber = '100';

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
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
        child: Column(
          children: [
            // App Logo & Info
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // App Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.of(context)
                              .primary
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_repair_service,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'SerbisyoHub',
                    style: AppTheme.of(context).headlineMedium.override(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version $appVersion ($buildNumber)',
                    style: AppTheme.of(context).bodyMedium.override(
                          color: AppTheme.of(context).secondaryText,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting skilled professionals with clients who need quality services.',
                    style: AppTheme.of(context).bodyMedium.override(
                          color: AppTheme.of(context).secondaryText,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Links
            _buildSection(
              title: 'Legal',
              children: [
                _buildLinkTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => context.pushNamed(TermsOfServiceWidget.routeName),
                ),
                _buildLinkTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => context.pushNamed(PrivacyPolicyWidget.routeName),
                ),
              ],
            ),

            _buildSection(
              title: 'Connect',
              children: [
                _buildLinkTile(
                  icon: Icons.language,
                  title: 'Website',
                  subtitle: 'api.serbisyohub.ph',
                  onTap: () => launchURL(_websiteUrl),
                ),
                _buildLinkTile(
                  icon: Icons.facebook,
                  title: 'Facebook',
                  subtitle: '@SerbisyoHub',
                  onTap: () => launchURL(_facebookUrl),
                ),
                _buildLinkTile(
                  icon: Icons.alternate_email,
                  title: 'Instagram',
                  subtitle: '@serbisyohub',
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await _openSupportEmail(
                      subject: 'Request Official Instagram Link',
                      body:
                          'Hello SerbisyoHub team,\n\nPlease share the current official Instagram profile link.',
                    );
                    if (!mounted) {
                      return;
                    }
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Instagram access is currently routed to support email.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Credits
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '© 2024 SerbisyoHub. All rights reserved.',
                style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) =>
      Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              title,
              style: AppTheme.of(context).titleSmall.override(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) =>
      ListTile(
      leading: Icon(
        icon,
        color: AppTheme.of(context).primary,
      ),
      title: Text(
        title,
        style: AppTheme.of(context).bodyLarge,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTheme.of(context).bodySmall,
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.of(context).secondaryText,
      ),
      onTap: onTap,
    );
}
