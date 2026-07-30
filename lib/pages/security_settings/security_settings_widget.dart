import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/supabase.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
  final _mfaCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<UserIdentity> _sessions = [];
  bool _isLoadingSessions = true;
  bool _isChangingPassword = false;
  bool _isProcessingMfa = false;
  String? _mfaQRCode;
  String? _mfaFactorId;

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
    _mfaCodeController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate() || _isChangingPassword) {
      return;
    }

    setState(() => _isChangingPassword = true);
    try {
      final response = await SupaFlow.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      if (response.user != null && mounted) {
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

  Future<void> _loadSessions() async {
    try {
      final response = await SupaFlow.client.auth.getUser();
      if (!mounted) {
        return;
      }

      setState(() {
        _sessions = response.user?.identities ?? [];
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
    try {
      final response = await SupaFlow.client.auth.mfa.listFactors();
      final hasTotpFactor = response.all.any((f) => f.factorType == 'totp');
      if (mounted) {
        setState(() => _model.twoFactorEnabled = hasTotpFactor);
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error checking MFA status',
        tag: 'SecuritySettings',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _model.twoFactorEnabled = false);
      }
    }
  }

  Future<void> _enrollMFA() async {
    if (_isProcessingMfa) {
      return;
    }

    setState(() => _isProcessingMfa = true);
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await SupaFlow.client.auth.mfa.enroll(
        factorType: FactorType.totp,
        issuer: 'SerbisyoHubPH',
      );

      if (response.totp?.qrCode == null) {
        throw Exception('Unable to generate QR code for 2FA setup');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _mfaQRCode = response.totp?.qrCode;
        _mfaFactorId = response.id;
      });
      _showMFAEnrollmentDialog();
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
          SnackBar(content: Text('Error enrolling 2FA: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingMfa = false);
      }
    }
  }

  Future<void> _verifyAndEnableMFA() async {
    final factorId = _mfaFactorId;
    final code = _mfaCodeController.text.trim();
    if (factorId == null) {
      return;
    }
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
      return;
    }

    setState(() => _isProcessingMfa = true);
    try {
      final challenge = await SupaFlow.client.auth.mfa.challenge(
        factorId: factorId,
      );

      await SupaFlow.client.auth.mfa.verify(
        factorId: factorId,
        challengeId: challenge.id,
        code: code,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _model.twoFactorEnabled = true;
        _mfaQRCode = null;
        _mfaFactorId = null;
      });
      _mfaCodeController.clear();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('2FA enabled successfully')),
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error verifying MFA',
        tag: 'SecuritySettings',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid verification code: $e')),
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
      final response = await SupaFlow.client.auth.mfa.listFactors();
      final totpFactor = response.all.firstWhere(
        (f) => f.factorType == 'totp',
        orElse: () => throw Exception('No TOTP factor found'),
      );

      await SupaFlow.client.auth.mfa.unenroll(totpFactor.id);

      if (mounted) {
        setState(() => _model.twoFactorEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA disabled successfully')),
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
          SnackBar(content: Text('Error disabling 2FA: $e')),
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

  void _showMFAEnrollmentDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Setup 2FA',
          style: AppTheme.of(context).titleMedium.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                color: AppTheme.of(context).primaryText,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scan this QR code with your authenticator app, then enter the 6-digit code to finish setup.',
                textAlign: TextAlign.center,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
              const SizedBox(height: 16),
              if (_mfaQRCode != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    _mfaQRCode!,
                    width: 220,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 18),
              TextField(
                controller: _mfaCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Verification code',
                  hintText: '123456',
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
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isProcessingMfa
                ? null
                : () {
                    _mfaCodeController.clear();
                    setState(() {
                      _mfaQRCode = null;
                      _mfaFactorId = null;
                    });
                    Navigator.of(dialogContext).pop();
                  },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isProcessingMfa ? null : _verifyAndEnableMFA,
            child: _isProcessingMfa
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify & Enable'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final difference = DateTime.now().difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      }
      if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      }
      if (difference.inDays < 1) {
        return '${difference.inHours} hours ago';
      }
      if (difference.inDays == 1) {
        return 'Yesterday';
      }
      if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
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
                            'Security',
                            style: AppTheme.of(context).titleLarge.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: AppTheme.of(context).primaryText,
                                ),
                          ),
                          Text(
                            'Protect your account, password, and sign-in access.',
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
                                          font: GoogleFonts.plusJakartaSans(
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
                  title: 'Two-Factor Authentication',
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.verified_user_outlined,
                        title: 'Secure your login',
                        subtitle:
                            'Use an authenticator app to add a second step during sign in.',
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
                  title: 'Login Activity',
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
                    'Keep your account protected',
                    style: AppTheme.of(context).titleMedium.override(
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage password strength, 2FA, and recent account access in one place.',
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
          'No active sessions were returned for this account yet.',
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.plusJakartaSans(),
                color: AppTheme.of(context).secondaryText,
              ),
        ),
      );

  Widget _buildSessionCard({
    required UserIdentity session,
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
                          isCurrent ? 'Current device' : 'Other sign-in',
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
                            'Active now',
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
                    session.provider,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: const Color(0xFF334155),
                        ),
                  ),
                  if ((session.createdAt ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Last active ${_formatDate(session.createdAt!)}',
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
