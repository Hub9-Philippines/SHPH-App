import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/auth/auth_util.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/l10n/app_localizations.dart';
import '/pages/phone_verify_user/phone_verify_user_widget.dart';
import '/pages/signin/signin_widget.dart';
import '/services/auth_service.dart';
import '/services/error_handler.dart';
import '/theme/app_theme.dart';
import '../../auth/shph_auth/shph_auth_manager.dart';
import 'unified_auth_model.dart';

export 'unified_auth_model.dart';

class UnifiedAuthWidget extends StatefulWidget {
  const UnifiedAuthWidget({super.key});

  static String routeName = 'UnifiedAuth';
  static String routePath = '/unifiedAuth';

  @override
  State<UnifiedAuthWidget> createState() => _UnifiedAuthWidgetState();
}

class _UnifiedAuthWidgetState extends State<UnifiedAuthWidget> {
  late UnifiedAuthModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, UnifiedAuthModel.new);
    _model.inputTextController ??= TextEditingController();
    _model.inputFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = AppTheme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 32),
                  _buildSocialSection(theme),
                  const SizedBox(height: 24),
                  _buildDivider(theme),
                  const SizedBox(height: 24),
                  _buildInputSection(theme),
                  const SizedBox(height: 24),
                  _buildContinueButton(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.handyman_rounded, color: theme.onPrimary, size: 38),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to Serbisyo',
          style: theme.headlineLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in or enter your details to continue',
          style: theme.bodyMedium.copyWith(
            color: theme.secondaryText,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSection(AppThemeData theme) {
    return Column(
      children: [
        FFButtonWidget(
          onPressed: () async {
            try {
              // Social Google sign-in
              final authManagerObj = authManager as ShphAuthManager;
              final user = await authManagerObj.signInWithGoogle(context);
              if (!context.mounted) return;
              if (user != null) {
                final authService = AuthService.instance;
                if (authService.currentUser?['phone_number'] == null) {
                  // Direct to Step 2 phone collection
                  await context.pushNamed(PhoneVerifyUserWidget.routeName);
                } else {
                  context.goNamed('Home');
                }
              }
            } catch (e) {
              ErrorHandler.showError(ErrorHandler.describeError(e, _l10n));
            }
          },
          text: 'Continue with Google',
          icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
          options: FFButtonOptions(
            width: double.infinity,
            height: 52,
            color: theme.secondaryBackground,
            textStyle: theme.titleMedium.copyWith(
              color: theme.primaryText,
              fontWeight: FontWeight.w600,
            ),
            borderSide: BorderSide(color: theme.alternate, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        FFButtonWidget(
          onPressed: () async {
            try {
              final authManagerObj = authManager as ShphAuthManager;
              final user = await authManagerObj.signInWithApple(context);
              if (!context.mounted) return;
              if (user != null) {
                final authService = AuthService.instance;
                if (authService.currentUser?['phone_number'] == null) {
                  await context.pushNamed(PhoneVerifyUserWidget.routeName);
                } else {
                  context.goNamed('Home');
                }
              }
            } catch (e) {
              ErrorHandler.showError(ErrorHandler.describeError(e, _l10n));
            }
          },
          text: 'Continue with Apple',
          icon: const Icon(Icons.apple_rounded, size: 22),
          options: FFButtonOptions(
            width: double.infinity,
            height: 52,
            color: theme.secondaryBackground,
            textStyle: theme.titleMedium.copyWith(
              color: theme.primaryText,
              fontWeight: FontWeight.w600,
            ),
            borderSide: BorderSide(color: theme.alternate, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(AppThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: theme.alternate, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '- OR -',
            style: theme.labelMedium.copyWith(
              color: theme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.alternate, thickness: 1)),
      ],
    );
  }

  Widget _buildInputSection(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email or Mobile Number',
          style: theme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _model.inputTextController!,
          focusNode: _model.inputFocusNode,
          placeholder: 'e.g. user@email.com or 09171234567',
          placeholderStyle: theme.labelMedium.copyWith(color: theme.secondaryText),
          fillColor: theme.secondaryBackground,
          radius: 12,
          style: theme.bodyMedium.copyWith(fontSize: 16),
          onChanged: (val) {
            _model.updateInput(val);
            safeSetState(() {});
          },
        ),
        if (_model.inputMode == AuthInputMode.phone && _model.sanitizedPhone.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Formatted: ${_model.sanitizedPhone}',
              style: theme.bodySmall.copyWith(color: theme.primary),
            ),
          ),
        if (_model.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _model.errorMessage!,
              style: theme.bodySmall.copyWith(color: theme.error),
            ),
          ),
      ],
    );
  }

  Widget _buildContinueButton(AppThemeData theme) {
    return FFButtonWidget(
      onPressed: (!_model.isValid || _model.isLoading)
          ? null
          : () async {
              _model.isLoading = true;
              safeSetState(() {});

              try {
                if (_model.inputMode == AuthInputMode.email) {
                  // Navigate to Sign In / Password prompt
                  _model.isLoading = false;
                  safeSetState(() {});
                  await context.pushNamed(
                    SigninWidget.routeName,
                    queryParameters: {
                      'email': _model.inputTextController!.text.trim(),
                    },
                  );
                } else if (_model.inputMode == AuthInputMode.phone) {
                  // Trigger Phone OTP flow
                  final phone = _model.sanitizedPhone;
                  FFAppState().phone = phone;
                  await AuthService.instance.authApi.sendOtpPin(phoneNumber: phone);
                  _model.isLoading = false;
                  safeSetState(() {});
                  if (!context.mounted) return;
                  await context.pushNamed(PhoneVerifyUserWidget.routeName);
                }
              } catch (e) {
                _model.isLoading = false;
                final message = ErrorHandler.describeError(e, _l10n);
                _model.errorMessage = message;
                safeSetState(() {});
              }
            },
      text: _model.isLoading ? 'Processing...' : 'Continue',
      options: FFButtonOptions(
        width: double.infinity,
        height: 52,
        color: _model.isValid ? theme.primary : theme.alternate,
        textStyle: theme.titleMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
        borderRadius: BorderRadius.circular(12),
        disabledColor: theme.alternate,
      ),
    );
  }
}
