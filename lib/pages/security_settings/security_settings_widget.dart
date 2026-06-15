import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/supabase.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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
  List<UserIdentity> _sessions = [];
  bool _isLoadingSessions = true;
  String? _mfaQRCode;
  String? _mfaFactorId;
  final _mfaCodeController = TextEditingController();

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
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await SupaFlow.client.auth.updateUser(
        UserAttributes(
          password: _newPasswordController.text,
        ),
      );

      if (response.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing password: $e')),
        );
      }
    }
  }

  Future<void> _loadSessions() async {
    try {
      final response = await SupaFlow.client.auth.getUser();
      final sessions = response.user?.identities ?? [];

      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoadingSessions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSessions = false;
        });
      }
    }
  }

  Future<void> _checkMFAStatus() async {
    try {
      final response = await SupaFlow.client.auth.mfa.listFactors();
      final hasTotpFactor = response.all.any((f) => f.factorType == 'totp');

      if (mounted) {
        setState(() {
          _model.twoFactorEnabled = hasTotpFactor;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking MFA status: $e');
      }
      if (mounted) {
        setState(() {
          _model.twoFactorEnabled = false;
        });
      }
    }
  }

  Future<void> _enrollMFA() async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (kDebugMode) {
        print('Enrolling MFA for user: ${user.email}');
        print('Issuer: SerbisyoHubPH');
      }

      final response = await SupaFlow.client.auth.mfa.enroll(
        factorType: FactorType.totp,
        issuer: 'SerbisyoHubPH',
      );

      if (kDebugMode) {
        print('MFA enrollment response: ${response.id}');
        print('QR Code: ${response.totp?.qrCode}');
      }

      if (response.totp?.qrCode != null) {
        if (mounted) {
          setState(() {
            _mfaQRCode = response.totp!.qrCode;
            _mfaFactorId = response.id;
          });
          _showMFAEnrollmentDialog();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error enrolling MFA: $e');
        print('Error type: ${e.runtimeType}');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error enrolling MFA: $e')),
        );
      }
    }
  }

  Future<void> _verifyAndEnableMFA() async {
    final code = _mfaCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
      return;
    }

    try {
      final challenge = await SupaFlow.client.auth.mfa.challenge(
        factorId: _mfaFactorId!,
      );

      await SupaFlow.client.auth.mfa.verify(
        factorId: _mfaFactorId!,
        challengeId: challenge.id,
        code: code,
      );

      if (mounted) {
        setState(() {
          _model.twoFactorEnabled = true;
          _mfaQRCode = null;
          _mfaFactorId = null;
          _mfaCodeController.clear();
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA enabled successfully')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying MFA: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid verification code: $e')),
        );
      }
    }
  }

  Future<void> _disableMFA() async {
    try {
      final response = await SupaFlow.client.auth.mfa.listFactors();
      final totpFactor = response.all.firstWhere(
        (f) => f.factorType == 'totp',
        orElse: () => throw Exception('No TOTP factor found'),
      );

      await SupaFlow.client.auth.mfa.unenroll(totpFactor.id);

      if (mounted) {
        setState(() {
          _model.twoFactorEnabled = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA disabled successfully')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disabling MFA: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error disabling 2FA: $e')),
        );
      }
    }
  }

  void _showMFAEnrollmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup 2FA'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan this QR code with your authenticator app',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_mfaQRCode != null)
                Image.network(
                  _mfaQRCode!,
                  width: 200,
                  height: 200,
                ),
              const SizedBox(height: 16),
              const Text(
                'Enter the 6-digit code from your app',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mfaCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '123456',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _mfaCodeController.clear();
              setState(() {
                _mfaQRCode = null;
                _mfaFactorId = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _verifyAndEnableMFA,
            child: const Text('Verify & Enable'),
          ),
        ],
      ),
    );
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
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} minutes ago';
        }
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
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
              'Security',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Password',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: !_model.showCurrentPassword,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          labelStyle: AppTheme.of(context).bodyMedium,
                          hintText: 'Enter current password',
                          hintStyle: AppTheme.of(context).bodyMedium,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).secondaryText,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).primary,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).error,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).error,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: AppTheme.of(context).secondaryBackground,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _model.showCurrentPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              safeSetState(() {
                                _model.showCurrentPassword =
                                    !_model.showCurrentPassword;
                              });
                            },
                          ),
                        ),
                        style: AppTheme.of(context).bodyMedium,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Current password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: !_model.showNewPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: AppTheme.of(context).bodyMedium,
                          hintText: 'Enter new password',
                          hintStyle: AppTheme.of(context).bodyMedium,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).secondaryText,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).primary,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).error,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).error,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: AppTheme.of(context).secondaryBackground,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _model.showNewPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              safeSetState(() {
                                _model.showNewPassword =
                                    !_model.showNewPassword;
                              });
                            },
                          ),
                        ),
                        style: AppTheme.of(context).bodyMedium,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'New password is required';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_model.showConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          labelStyle: AppTheme.of(context).bodyMedium,
                          hintText: 'Confirm new password',
                          hintStyle: AppTheme.of(context).bodyMedium,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).secondaryText,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).primary,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).error,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.of(context).error,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: AppTheme.of(context).secondaryBackground,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _model.showConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              safeSetState(() {
                                _model.showConfirmPassword =
                                    !_model.showConfirmPassword;
                              });
                            },
                          ),
                        ),
                        style: AppTheme.of(context).bodyMedium,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      FFButtonWidget(
                        onPressed: _changePassword,
                        text: 'Change Password',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          color: AppTheme.of(context).primary,
                          textStyle: AppTheme.of(context).titleSmall.override(
                                color: Colors.white,
                                font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600),
                              ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Two-Factor Authentication',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enable 2FA',
                                    style: AppTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add an extra layer of security to your account',
                                    style:
                                        AppTheme.of(context).bodySmall.override(
                                              color: AppTheme.of(context)
                                                  .secondaryText,
                                            ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _model.twoFactorEnabled,
                              onChanged: _toggle2FA,
                              activeThumbColor: AppTheme.of(context).primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Login Activity',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                            ),
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingSessions) const Center(
                              child: CircularProgressIndicator(),
                            ) else _sessions.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'No active sessions found',
                                    style: AppTheme.of(context).bodyMedium,
                                  ),
                                )
                              : Column(
                                  children: [
                                    ..._sessions.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final session = entry.value;
                                      final isCurrent = index == 0;
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  isCurrent
                                                      ? 'Current Device'
                                                      : 'Other Device',
                                                  style: AppTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                ),
                                                if (isCurrent)
                                                  Text(
                                                    'Active now',
                                                    style: AppTheme.of(context)
                                                        .bodySmall
                                                        .override(
                                                          color: Colors.green,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              session.provider,
                                              style: AppTheme.of(context)
                                                  .bodySmall
                                                  .override(
                                                    color: AppTheme.of(context)
                                                        .secondaryText,
                                                  ),
                                            ),
                                            if (session.createdAt != null &&
                                                session
                                                    .createdAt!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Last active: ${_formatDate(session.createdAt!)}',
                                                style: AppTheme.of(context)
                                                    .bodySmall
                                                    .override(
                                                      color:
                                                          AppTheme.of(context)
                                                              .secondaryText,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
