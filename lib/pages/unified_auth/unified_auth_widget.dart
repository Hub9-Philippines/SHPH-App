import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/auth/auth_util.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/l10n/app_localizations.dart';
import '/pages/forgot_password/forgot_password_widget.dart';
import '/pages/phone_verify_user/phone_verify_user_widget.dart';
import '/pages/signup/signup_widget.dart';
import '/services/auth_service.dart';
import '/services/error_handler.dart';
import '/theme/app_theme.dart';
import '../../auth/shph_auth/shph_auth_manager.dart';
import 'unified_auth_model.dart';

export 'unified_auth_model.dart';

class UnifiedAuthWidget extends StatefulWidget {
  const UnifiedAuthWidget({super.key, this.initialInput});

  final String? initialInput;

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
    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    if (widget.initialInput != null && widget.initialInput!.isNotEmpty) {
      _model.inputTextController!.text = widget.initialInput!;
      _model.updateInput(widget.initialInput!);
    }
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
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
      children: [
        Center(
          child: Image.asset(
            'assets/images/shph-logo.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.handyman_rounded, color: theme.onPrimary, size: 40),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome to Serbisyo',
          textAlign: TextAlign.center,
          style: theme.headlineLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in or create an account to get started',
          textAlign: TextAlign.center,
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
              final authManagerObj = authManager as ShphAuthManager;
              final user = await authManagerObj.signInWithGoogle(context);
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
          text: 'Continue with Google',
          icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
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
          icon: const Icon(Icons.apple_rounded, size: 24),
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
              letterSpacing: 1.2,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Email or Mobile Number',
              style: theme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
            if (_model.inputMode == AuthInputMode.email)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Email',
                  style: theme.bodySmall.copyWith(
                    color: theme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (_model.inputMode == AuthInputMode.phone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Mobile (+63)',
                  style: theme.bodySmall.copyWith(
                    color: theme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
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

        // Inline Password Entry (shown if email user exists)
        if (_model.showPasswordField) ...[
          const SizedBox(height: 16),
          Text(
            'Password',
            style: theme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _model.passwordTextController!,
            focusNode: _model.passwordFocusNode,
            placeholder: 'Enter your password',
            obscureText: !_model.isPasswordVisible,
            placeholderStyle: theme.labelMedium.copyWith(color: theme.secondaryText),
            fillColor: theme.secondaryBackground,
            radius: 12,
            style: theme.bodyMedium.copyWith(fontSize: 16),
            suffix: IconButton(
              icon: Icon(
                _model.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: theme.secondaryText,
                size: 20,
              ),
              onPressed: () {
                _model.isPasswordVisible = !_model.isPasswordVisible;
                safeSetState(() {});
              },
            ),
            onChanged: (val) => safeSetState(() {}),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.pushNamed(ForgotPasswordWidget.routeName),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: theme.bodySmall.copyWith(
                  color: theme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],

        if (_model.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _model.errorMessage!,
              style: theme.bodySmall.copyWith(color: theme.error),
            ),
          ),
      ],
    );
  }

  Widget _buildContinueButton(AppThemeData theme) {
    final buttonText = _model.showPasswordField ? 'Sign In' : 'Continue';

    return FFButtonWidget(
      onPressed: (!_model.isValid || _model.isLoading)
          ? null
          : () async {
              _model.isLoading = true;
              _model.errorMessage = null;
              safeSetState(() {});

              try {
                if (_model.inputMode == AuthInputMode.email) {
                  final email = _model.inputTextController!.text.trim();

                  if (!_model.showPasswordField) {
                    // Step 1: Check account availability
                    final res = await AuthService.instance.authApi.checkAccount(
                      identifier: email,
                    );

                    _model.isLoading = false;
                    final exists = res['exists'] == true || res['hasPassword'] == true;

                    if (exists) {
                      _model.showPasswordField = true;
                      safeSetState(() {});
                      _model.passwordFocusNode?.requestFocus();
                    } else {
                      safeSetState(() {});
                      if (!context.mounted) return;
                      await context.pushNamed(
                        SignupWidget.routeName,
                        queryParameters: {'email': email},
                      );
                    }
                  } else {
                    // Step 2: Perform email + password login
                    final password = _model.passwordTextController!.text.trim();
                    final authManagerObj = authManager as ShphAuthManager;
                    final user = await authManagerObj.signInWithEmail(
                      context,
                      email,
                      password,
                    );
                    _model.isLoading = false;
                    safeSetState(() {});
                    if (!context.mounted) return;
                    if (user != null) {
                      context.goNamed('Home');
                    }
                  }
                } else if (_model.inputMode == AuthInputMode.phone) {
                  // Trigger Mobile OTP flow
                  final phone = _model.sanitizedPhone;
                  FFAppState().phone = phone;
                  await AuthService.instance.authApi.sendOtpPin(phoneNumber: phone);
                  _model.isLoading = false;
                  safeSetState(() {});
                  if (!context.mounted) return;
                  await context.pushNamed(
                    PhoneVerifyUserWidget.routeName,
                    queryParameters: {'phone': phone},
                  );
                }
              } catch (e) {
                _model.isLoading = false;
                final message = ErrorHandler.describeError(e, _l10n);
                _model.errorMessage = message;
                safeSetState(() {});
              }
            },
      text: buttonText,
      options: FFButtonOptions(
        width: double.infinity,
        height: 52,
        color: theme.primary,
        textStyle: theme.titleMedium.copyWith(
          color: theme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        disabledColor: theme.secondaryText.withOpacity(0.3),
        disabledTextColor: theme.primaryBackground,
      ),
    );
  }
}
