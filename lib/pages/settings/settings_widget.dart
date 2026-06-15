import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Text(
              'Settings',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General',
                      style: AppTheme.of(context).bodyLarge.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingTile(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () => context.pushNamed(LanguageSettingsWidget.routeName),
                    ),
                    _buildSettingTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage your notifications',
                      onTap: () => context.pushNamed(MyNotificationsWidget.routeName),
                    ),
                    _buildSettingTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Toggle dark theme',
                      trailing: Switch(
                        value: _model.darkMode,
                        onChanged: (value) {
                          safeSetState(() {
                            _model.darkMode = value;
                          });
                        },
                        activeThumbColor: AppTheme.of(context).primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Account',
                      style: AppTheme.of(context).bodyLarge.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingTile(
                      icon: Icons.lock_outline,
                      title: 'Security',
                      subtitle: 'Password and 2FA settings',
                      onTap: () => context.pushNamed(SecuritySettingsWidget.routeName),
                    ),
                    _buildSettingTile(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () => context.pushNamed(EditProfileWidget.routeName),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Support',
                      style: AppTheme.of(context).bodyLarge.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingTile(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      subtitle: 'Get help with using the app',
                      onTap: () => _launchUrl('https://help.example.com'),
                    ),
                    _buildSettingTile(
                      icon: Icons.share_outlined,
                      title: 'Share the App',
                      subtitle: 'Share with friends and family',
                      onTap: () {
                        // TODO: Implement share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share feature coming soon')),
                        );
                      },
                    ),
                    _buildSettingTile(
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      subtitle: 'Help us improve the app',
                      onTap: () {
                        // TODO: Implement feedback form
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Feedback form coming soon')),
                        );
                      },
                    ),
                    _buildSettingTile(
                      icon: Icons.star_outline,
                      title: 'Rate the App',
                      subtitle: 'Rate us on the app store',
                      onTap: () {
                        // TODO: Implement app store rating
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('App store rating coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'About',
                      style: AppTheme.of(context).bodyLarge.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingTile(
                      icon: Icons.info_outline,
                      title: 'App Version',
                      subtitle: '1.0.0',
                      onTap: null,
                    ),
                    _buildSettingTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms and conditions',
                      onTap: () => _launchUrl('https://example.com/terms'),
                    ),
                    _buildSettingTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      onTap: () => _launchUrl('https://example.com/privacy'),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement logout
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logout coming soon')),
                          );
                        },
                        child: Text(
                          'Log Out',
                          style: AppTheme.of(context).titleSmall.override(
                                color: Colors.white,
                                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SHPH Service Provider App',
                      style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x1A368EFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.of(context).primary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: AppTheme.of(context).titleSmall.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTheme.of(context).bodySmall.override(
                  color: AppTheme.of(context).secondaryText,
                ),
          ),
          trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios_rounded, size: 16) : null),
        ),
      );
}
