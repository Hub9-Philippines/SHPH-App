import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/resources/auth_api.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'security_settings_model.dart';

export 'security_settings_model.dart';

class SecuritySettingsWidget extends StatefulWidget {
  const SecuritySettingsWidget({super.key});

  static String routeName = 'SecuritySettings';
  static String routePath = '/security-settings';

  @override
  State<SecuritySettingsWidget> createState() => _SecuritySettingsWidgetState();
}

class _SecuritySettingsWidgetState extends State<SecuritySettingsWidget> {
  late SecuritySettingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SecuritySettingsModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate() || _isChangingPassword) {
      return;
    }

    setState(() => _isChangingPassword = true);
    try {
      await ShphAuthApi.instance.updatePassword(
        newPassword: _newPasswordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error changing password',
        tag: 'SecuritySettings',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing password: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
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
                            'Security',
                            style: AppTheme.of(context).titleLarge.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: const Color(0xFF14213D),
                                ),
                          ),
                          Text(
                            'Protect your account, password, and sign-in access.',
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
                  title: 'Password',
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          label: 'Current password',
                          hint: 'Enter current password',
                          obscureText: !_model.showCurrentPassword,
                          toggle: () => safeSetState(
                            () => _model.showCurrentPassword =
                                !_model.showCurrentPassword,
                          ),
                          isVisible: _model.showCurrentPassword,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Current password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: 'New password',
                          hint: 'Enter new password',
                          obscureText: !_model.showNewPassword,
                          toggle: () => safeSetState(
                            () => _model.showNewPassword =
                                !_model.showNewPassword,
                          ),
                          isVisible: _model.showNewPassword,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'New password is required';
                            }
                            if (value.trim().length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirm new password',
                          hint: 'Re-enter your new password',
                          obscureText: !_model.showConfirmPassword,
                          toggle: () => safeSetState(
                            () => _model.showConfirmPassword =
                                !_model.showConfirmPassword,
                          ),
                          isVisible: _model.showConfirmPassword,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed:
                                _isChangingPassword ? null : _changePassword,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppTheme.of(context).primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _isChangingPassword
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Change Password',
                                    style: AppTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: Colors.white,
                                        ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildSection(
                  title: 'Biometric Login',
                  child: _buildInfoRow(
                    icon: Icons.fingerprint,
                    title: 'Manage biometric login',
                    subtitle:
                        'Register Face ID / Touch ID for faster, secure sign-in.',
                    trailing: Icon(Icons.chevron_right,
                        color: const Color(0xFF94A3B8)),
                    onTap: () => context.push(BiometricSetupPage.routePath),
                  ),
                ),
                const SizedBox(height: 18),
                _buildSection(
                  title: 'Notification Preferences',
                  child: _buildInfoRow(
                    icon: Icons.notifications_outlined,
                    title: 'Push notifications & Do Not Disturb',
                    subtitle:
                        'Choose which notifications you receive and when.',
                    trailing: Icon(Icons.chevron_right,
                        color: const Color(0xFF94A3B8)),
                    onTap: () =>
                        context.push(NotificationPreferencesPage.routePath),
                  ),
                ),
                const SizedBox(height: 18),
                _buildSection(
                  title: 'Login Activity',
                  child: _buildInfoRow(
                    icon: Icons.devices_outlined,
                    title: 'Active sessions',
                    subtitle:
                        'View and revoke devices signed in to your account.',
                    trailing: Icon(Icons.chevron_right,
                        color: const Color(0xFF94A3B8)),
                    onTap: () => context.push(SessionsPage.routePath),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeroCard() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3A0CA3),
              Color(0xFF4361EE),
              Color(0xFF4CC9F0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A4361EE),
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
              child: const Icon(Icons.lock_person_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keep your account protected',
                    style: AppTheme.of(context).titleMedium.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage password strength, 2FA, and recent account access in one place.',
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.poppins(),
                          color: Colors.white.withValues(alpha: 0.84),
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
    required Widget child,
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
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
            child: child,
          ),
        ],
      );

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required bool isVisible,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) =>
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: AppTheme.of(context).primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: AppTheme.of(context).error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: AppTheme.of(context).error),
          ),
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(
              isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      );

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withValues(alpha: 0.10),
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
            if (trailing != null) trailing,
          ],
        ),
      );
}
