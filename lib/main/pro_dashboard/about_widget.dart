import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';

class AboutWidget extends StatefulWidget {
  const AboutWidget({super.key});

  static const String routeName = 'About';
  static const String routePath = '/pro/about';

  @override
  State<AboutWidget> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget> {
  final String appVersion = '1.0.0';
  final String buildNumber = '100';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
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
                  onTap: () {
                    // TODO: Navigate to Terms of Service
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Terms of Service coming soon')),
                    );
                  },
                ),
                _buildLinkTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    // TODO: Navigate to Privacy Policy
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Privacy Policy coming soon')),
                    );
                  },
                ),
              ],
            ),

            _buildSection(
              title: 'Connect',
              children: [
                _buildLinkTile(
                  icon: Icons.language,
                  title: 'Website',
                  subtitle: 'www.serbisyohub.ph',
                  onTap: () {
                    // TODO: Open website
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening website...')),
                    );
                  },
                ),
                _buildLinkTile(
                  icon: Icons.facebook,
                  title: 'Facebook',
                  subtitle: '@SerbisyoHub',
                  onTap: () {
                    // TODO: Open Facebook
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Facebook...')),
                    );
                  },
                ),
                _buildLinkTile(
                  icon: Icons.alternate_email,
                  title: 'Instagram',
                  subtitle: '@serbisyohub',
                  onTap: () {
                    // TODO: Open Instagram
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Instagram...')),
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
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
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
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
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
}
