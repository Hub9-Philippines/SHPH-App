import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '/auth/shph_auth/auth_util.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'settings_model.dart';

export 'settings_model.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  static String routeName = 'Settings';
  static String routePath = '/settings';

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  late SettingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SettingsModel.new);
    _model.darkMode = AppTheme.themeMode == ThemeMode.dark;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Log out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Log out'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm || !mounted) {
      return;
    }

    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    if (!mounted) {
      return;
    }

    GoRouter.of(context).clearRedirectLocation();
    context.goNamedAuth(SplashWidget.routeName, context.mounted);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF4F7FB),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: wrapWithModel(
                        model: _model.backButtonModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const BackButtonWidget(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: AppTheme.of(context).titleLarge.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: const Color(0xFF14213D),
                                ),
                          ),
                          Text(
                            'Manage preferences, account, and support options.',
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.poppins(),
                                  color: const Color(0xFF64748B),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildHeroCard(),
                const SizedBox(height: 18),
                _buildSection(
                  title: 'General',
                  children: [
                    _buildSettingTile(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: 'Choose the language used across the app',
                      onTap: () =>
                          context.pushNamed(LanguageSettingsWidget.routeName),
                    ),
                    _buildSettingTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Review booking, message, and payment updates',
                      onTap: () =>
                          context.pushNamed(MyNotificationsWidget.routeName),
                    ),
                    _buildToggleTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark mode',
                      subtitle: 'Switch between light and dark appearance',
                      value: _model.darkMode,
                      onChanged: (value) {
                        safeSetState(() => _model.darkMode = value);
                        setDarkModeSetting(
                          context,
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildSection(
                  title: 'Account',
                  children: [
                    _buildSettingTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Security',
                      subtitle: 'Password, login activity, and 2FA settings',
                      onTap: () =>
                          context.pushNamed(SecuritySettingsWidget.routeName),
                    ),
                    _buildSettingTile(
                      icon: Icons.edit_outlined,
                      title: 'Edit profile',
                      subtitle: 'Update your personal information',
                      onTap: () =>
                          context.pushNamed(EditProfileWidget.routeName),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildSection(
                  title: 'Support',
                  children: [
                    _buildSettingTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'FAQs, contact support, and more',
                      onTap: () =>
                          context.pushNamed(ClientHelpSupportWidget.routeName),
                    ),
                    _buildSettingTile(
                      icon: Icons.report_problem_outlined,
                      title: 'Report a problem',
                      subtitle: 'Submit a support ticket for app issues',
                      onTap: () =>
                          context.pushNamed(ReportProblemWidget.routeName),
                    ),
                    _buildSettingTile(
                      icon: Icons.feedback_outlined,
                      title: 'Send feedback',
                      subtitle: 'Open an email draft to share product feedback',
                      onTap: () => _launchUrl(
                        'mailto:support@serbisyohubph.com?subject=SHPH%20Feedback',
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle:
                          'Read the terms governing your use of SerbisyoHub',
                      onTap: () =>
                          context.pushNamed(TermsOfServiceWidget.routeName),
                    ),
                    _buildSettingTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Understand how we collect and use your data',
                      onTap: () =>
                          context.pushNamed(PrivacyPolicyWidget.routeName),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: BorderSide(
                      color: AppTheme.of(context).error.withValues(alpha: 0.28),
                    ),
                    foregroundColor: AppTheme.of(context).error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Log Out',
                    style: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                          color: AppTheme.of(context).error,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeroCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF17212B),
              Color(0xFF23384D),
              Color(0xFF2F5368),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A17212B),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.settings_suggest_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control your app experience',
                    style: AppTheme.of(context).titleMedium.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Appearance, security, notifications, and support all live here.',
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.poppins(),
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: AppTheme.of(context).labelLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: const Color(0xFF64748B),
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      );

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: AppTheme.of(context).primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFF14213D),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.poppins(),
                              color: const Color(0xFF64748B),
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppTheme.of(context).primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.of(context).titleSmall.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          color: const Color(0xFF14213D),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.poppins(),
                          color: const Color(0xFF64748B),
                        ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.of(context).primary,
            ),
          ],
        ),
      );
}
