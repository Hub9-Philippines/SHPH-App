import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/resources/auth_api.dart';
import '/api/resources/sessions_api.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _sessions = [];
  bool _isLoadingSessions = true;
  bool _isChangingPassword = false;
  bool _isProcessingMfa = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SecuritySettingsModel.new);
    _loadSessions();
    _checkMFAStatus();
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
      // SHPH API does not expose a change-password-with-current-password
      // endpoint; trigger a password reset email instead.
      final email = await _getUserEmail();
      if (email.isEmpty) {
        throw Exception('Unable to determine account email');
      }
      await ShphAuthApi.instance.requestPasswordReset(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.ssPasswordResetSent),
          ),
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
          SnackBar(content: Text(_l10n.ssErrorPasswordReset(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
      }
    }
  }

  Future<String> _getUserEmail() async {
    try {
      final data = await ShphAuthApi.instance.getCurrentUser();
      final user = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : data;
      return (user['email'] ?? data['email'] ?? '').toString();
    } catch (e) {
      return '';
    }
  }

  Future<void> _loadSessions() async {
    try {
      final response = await ShphSessionsApi.instance.listSessions();
      if (!mounted) {
        return;
      }

      final sessions = response['sessions'] as List? ?? response['results'] as List?;
      setState(() {
        _sessions = sessions == null
            ? const []
            : List<Map<String, dynamic>>.from(
                sessions.whereType<Map<String, dynamic>>(),
              );
        _isLoadingSessions = false;
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading sessions',
        tag: 'SecuritySettings',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isLoadingSessions = false);
      }
    }
  }

  Future<void> _checkMFAStatus() async {
    // SHPH API has no TOTP MFA management endpoint; leave disabled.
    if (mounted) {
      setState(() => _model.twoFactorEnabled = false);
    }
  }

  Future<void> _enrollMFA() async {
    if (_isProcessingMfa) {
      return;
    }

    setState(() => _isProcessingMfa = true);
    try {
      // SHPH API does not expose TOTP MFA enrollment; notify user.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.ss2FAEnrollmentUnavailable),
          ),
        );
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error enrolling MFA',
        tag: 'SecuritySettings',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _model.twoFactorEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.ssErrorEnrolling2FA(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingMfa = false);
      }
    }
  }

  Future<void> _disableMFA() async {
    if (_isProcessingMfa) {
      return;
    }

    setState(() => _isProcessingMfa = true);
    try {
      // SHPH API does not expose TOTP MFA management.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.ss2FAManagementUnavailable),
          ),
        );
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error disabling MFA',
        tag: 'SecuritySettings',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.ssErrorDisabling2FA(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingMfa = false);
      }
    }
  }

  Future<void> _toggle2FA(bool value) async {
    if (value) {
      await _enrollMFA();
    } else {
      await _disableMFA();
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final difference = DateTime.now().difference(date);

      if (difference.inMinutes < 1) {
        return _l10n.ssJustNow;
      }
      if (difference.inHours < 1) {
        return _l10n.ssMinutesAgo(difference.inMinutes);
      }
      if (difference.inDays < 1) {
        return _l10n.ssHoursAgo(difference.inHours);
      }
      if (difference.inDays == 1) {
        return _l10n.ssYesterday;
      }
      if (difference.inDays < 7) {
        return _l10n.ssDaysAgo(difference.inDays);
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
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
          backgroundColor: AppTheme.of(context).secondaryBackground,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                      Material(
                        color: AppTheme.of(context).primaryBackground,
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
                            _l10n.ssSecurity,
                            style: AppTheme.of(context).titleLarge.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: AppTheme.of(context).primaryText,
                                ),
                          ),
                          Text(
                            _l10n.ssSubtitle,
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.plusJakartaSans(),
                                  color: AppTheme.of(context).secondaryText,
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
                  title: _l10n.ssPassword,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          label: _l10n.ssCurrentPassword,
                          hint: _l10n.ssEnterCurrentPassword,
                          obscureText: !_model.showCurrentPassword,
                          toggle: () => safeSetState(
                            () => _model.showCurrentPassword =
                                !_model.showCurrentPassword,
                          ),
                          isVisible: _model.showCurrentPassword,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return _l10n.ssCurrentPasswordRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: _l10n.ssNewPassword,
                          hint: _l10n.ssEnterNewPassword,
                          obscureText: !_model.showNewPassword,
                          toggle: () => safeSetState(
                            () => _model.showNewPassword =
                                !_model.showNewPassword,
                          ),
                          isVisible: _model.showNewPassword,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return _l10n.ssNewPasswordRequired;
                            }
                            if (value.trim().length < 8) {
                              return _l10n.ssPasswordMinLength;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: _l10n.ssConfirmNewPassword,
                          hint: _l10n.ssReenterNewPassword,
                          obscureText: !_model.showConfirmPassword,
                          toggle: () => safeSetState(
                            () => _model.showConfirmPassword =
                                !_model.showConfirmPassword,
                          ),
                          isVisible: _model.showConfirmPassword,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return _l10n.ssConfirmPasswordRequired;
                            }
                            if (value != _newPasswordController.text) {
                              return _l10n.ssPasswordsDoNotMatch;
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
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.of(context).onPrimary,
                                    ),
                                  )
                                : Text(
                                    _l10n.ssChangePassword,
                                    style: AppTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: AppTheme.of(context).onPrimary,
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
                  title: _l10n.ssTwoFactorAuth,
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.verified_user_outlined,
                        title: _l10n.ssSecureYourLogin,
                        subtitle: _l10n.ssAuthenticatorApp,
                        trailing: Switch.adaptive(
                          value: _model.twoFactorEnabled,
                          onChanged: _isProcessingMfa ? null : _toggle2FA,
                          activeThumbColor: AppTheme.of(context).primary,
                        ),
                      ),
                      if (_isProcessingMfa) ...[
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(minHeight: 3),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _buildSection(
                  title: _l10n.ssLoginActivity,
                  child: _isLoadingSessions
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _sessions.isEmpty
                          ? _buildEmptySessions()
                          : Column(
                              children: _sessions.asMap().entries.map((entry) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        entry.key == _sessions.length - 1 ? 0 : 12,
                                  ),
                                  child: _buildSessionCard(
                                    session: entry.value,
                                    isCurrent: entry.key == 0,
                                  ),
                                );
                              }).toList(),
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
                    _l10n.ssHeroTitle,
                    style: AppTheme.of(context).titleMedium.override(
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _l10n.ssHeroSubtitle,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
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
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(26),
              boxShadow: AppThemeData.shadowCard,
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
          fillColor: AppTheme.of(context).surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: AppTheme.of(context).border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: AppTheme.of(context).border),
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
  }) =>
      Row(
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
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          color: AppTheme.of(context).primaryText,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: AppTheme.of(context).secondaryText,
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
        ],
      );

  Widget _buildEmptySessions() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.of(context).surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.of(context).border),
        ),
        child: Text(
          _l10n.ssNoActiveSessions,
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.plusJakartaSans(),
                color: AppTheme.of(context).secondaryText,
              ),
        ),
      );

  Widget _buildSessionCard({
    required Map<String, dynamic> session,
    required bool isCurrent,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.of(context).surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrent
                ? AppTheme.of(context).primary.withValues(alpha: 0.20)
                : AppTheme.of(context).border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppTheme.of(context).primary.withValues(alpha: 0.12)
                    : AppTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isCurrent ? Icons.smartphone_rounded : Icons.devices_rounded,
                color: AppTheme.of(context).primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isCurrent ? _l10n.ssCurrentDevice : _l10n.ssOtherSignIn,
                          style: AppTheme.of(context).titleSmall.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: AppTheme.of(context).primaryText,
                              ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FFF4),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _l10n.ssActiveNow,
                            style: AppTheme.of(context).labelSmall.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: const Color(0xFF0F9D58),
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session['provider']?.toString() ??
                        session['device_name']?.toString() ??
                        _l10n.ssUnknownDevice,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: const Color(0xFF334155),
                        ),
                  ),
                  if ((session['created_at']?.toString() ??
                              session['createdAt']?.toString() ??
                              '')
                          .isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _l10n.ssLastActive(_formatDate(session['created_at']?.toString() ?? session['createdAt']?.toString() ?? '')),
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.plusJakartaSans(),
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}
