import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '/auth/auth_util.dart';
import '/components/screen_header.dart';
import '/components/tinted_menu_tile.dart';
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
          backgroundColor: AppTheme.of(context).secondaryBackground,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const ScreenHeader(
                  title: 'Settings',
                  subtitle: 'Manage preferences, account, and support options.',
                ),
                const SizedBox(height: 18),
                _buildHeroCard(),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'General & Account Configuration',
                  children: [
                    TintedMenuTile(
                      icon: Icons.language_rounded,
                      tint: AppThemeData.accentPurple,
                      title: 'Language',
                      subtitle: 'Choose the language used across the app',
                      onTap: () =>
                          context.pushNamed(LanguageSettingsWidget.routeName),
                    ),
                    TintedMenuTile(
                      icon: Icons.notifications_rounded,
                      tint: AppThemeData.accentYellow,
                      title: 'Notifications',
                      subtitle: 'Review booking, message, and payment updates',
                      onTap: () =>
                          context.pushNamed(MyNotificationsWidget.routeName),
                    ),
                    TintedMenuTile(
                      icon: Icons.security_rounded,
                      tint: AppThemeData.accentTeal,
                      title: 'Security',
                      subtitle: 'Password, login protection, and 2FA settings',
                      onTap: () =>
                          context.pushNamed(SecuritySettingsWidget.routeName),
                    ),
                    TintedMenuTile(
                      icon: Icons.edit_rounded,
                      tint: AppThemeData.accentSky,
                      title: 'Edit profile',
                      subtitle: 'Update your personal registration information',
                      onTap: () => context.pushNamed(EditProfileWidget.routeName),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Legal & Feedback',
                  children: [
                    TintedMenuTile(
                      icon: Icons.add_comment_rounded,
                      tint: AppThemeData.accentBlue,
                      title: 'Send feedback',
                      subtitle: 'Open an email draft to share product feedback',
                      onTap: () => _launchUrl(
                        'mailto:support@serbisyohubph.com?subject=SHPH%20Feedback',
                      ),
                    ),
                    TintedMenuTile(
                      icon: Icons.description_rounded,
                      tint: AppThemeData.accentNavy,
                      title: 'Terms of Service',
                      subtitle: 'Read the terms governing your use of SerbisyoHub',
                      onTap: () => context.pushNamed(TermsOfServiceWidget.routeName),
                    ),
                    TintedMenuTile(
                      icon: Icons.verified_user_rounded,
                      tint: AppThemeData.accentBlueGray,
                      title: 'Privacy Policy',
                      subtitle: 'Understand how we collect and use your data',
                      onTap: () => context.pushNamed(PrivacyPolicyWidget.routeName),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TintedMenuTile(
                  icon: Icons.logout_rounded,
                  tint: AppThemeData.destructiveCrimson,
                  title: 'Log out',
                  subtitle: 'Sign out of your account on this device',
                  titleColor: AppThemeData.destructiveCrimson,
                  onTap: _handleLogout,
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
            colors: AppThemeData.settingsBannerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppThemeData.radiusCard),
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
            const _GearShieldBadge(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control your app experience',
                    style: AppTheme.of(context).titleLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700),
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Appearance, security, notifications, and support all live here.',
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
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
  }) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: theme.labelMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                  letterSpacing: 0.4,
                  color: theme.secondaryText,
                ),
          ),
        ),
        Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              children[i],
            ],
          ],
        ),
      ],
    );
  }
}

class _GearShieldBadge extends StatelessWidget {
  const _GearShieldBadge();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 54,
        height: 54,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            Positioned(
              right: -6,
              bottom: -6,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppThemeData.profileHeroGradient.last,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppThemeData.settingsBannerGradient.first,
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: AppThemeData.settingsBannerGradient.first,
                  size: 13,
                ),
              ),
            ),
          ],
        ),
      );
}
