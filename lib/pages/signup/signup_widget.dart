import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '/auth/auth_util.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/pages/email_verify/email_verify_widget.dart';
import '/pages/phone_verify_user/phone_verify_user_widget.dart';
import '/services/auth_service.dart';
import '/services/error_handler.dart';
import '/theme/app_theme.dart';
import '../../auth/shph_auth/shph_auth_manager.dart';
import 'signup_model.dart';

export 'signup_model.dart';

class SignupWidget extends StatefulWidget {
  const SignupWidget({
    super.key,
    this.email,
    this.phoneNumber,
    this.method,
    this.name,
  });

  final String? email;
  final String? phoneNumber;
  final String? method; // 'google', 'apple', 'email', 'mobile'
  final String? name;

  static String routeName = 'Signup';
  static String routePath = '/signup';

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  late SignupModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SignupModel.new);

    _model.phoneFieldTextController ??= TextEditingController();
    _model.phoneFieldFocusNode ??= FocusNode();
    _model.phoneFieldMask = MaskTextInputFormatter(mask: '+63##########');

    _model.firstNameTextController ??= TextEditingController();
    _model.firstNameFocusNode ??= FocusNode();
    _model.middleNameTextController ??= TextEditingController();
    _model.middleNameFocusNode ??= FocusNode();
    _model.lastNameTextController ??= TextEditingController();
    _model.lastNameFocusNode ??= FocusNode();
    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();
    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();
    _model.confirmPasswordTextController ??= TextEditingController();
    _model.confirmPasswordFocusNode ??= FocusNode();

    if (widget.email != null && widget.email!.isNotEmpty) {
      _model.emailTextController!.text = widget.email!;
    }
    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      _model.phoneFieldTextController!.text = widget.phoneNumber!;
    }
    if (widget.name != null && widget.name!.isNotEmpty) {
      final parts = widget.name!.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        _model.firstNameTextController!.text = parts.sublist(0, parts.length - 1).join(' ');
        _model.lastNameTextController!.text = parts.last;
      } else if (parts.length == 1) {
        _model.firstNameTextController!.text = parts.first;
      }
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
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          Navigator.of(context).pop();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: theme.primaryBackground,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: CupertinoPageHeader(
              title: '',
              backgroundColor: Colors.transparent,
              leading: wrapWithModel(
                model: _model.backButtonModel,
                updateCallback: () => safeSetState(() {}),
                child: const BackButtonWidget(),
              ),
            ),
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 32),
                    _buildForm(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeData theme) {
    String badgeText = 'Step 2: Complete Your Account';
    if (widget.method == 'google') {
      badgeText = 'Google Account Sign Up (Step 2)';
    } else if (widget.method == 'apple') {
      badgeText = 'Apple Account Sign Up (Step 2)';
    } else if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      badgeText = 'Mobile Sign Up (Step 2)';
    } else {
      badgeText = 'Email Sign Up (Step 2)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            badgeText,
            style: theme.bodySmall.copyWith(
              color: theme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Personal Information',
          style: theme.headlineLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please fill in your first and last name to proceed to verification.',
          style: theme.bodyMedium.copyWith(
            color: theme.secondaryText,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AppThemeData theme) {
    final isOAuth = widget.method == 'google' || widget.method == 'apple';
    final isMobile = widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: theme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please ensure your First Name and Last Name match your legal name as shown on your government ID.',
                  style: theme.bodySmall.copyWith(
                    color: theme.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _fieldLabel(theme, 'First Name'),
        const SizedBox(height: 8),
        _inputField(
          theme,
          controller: _model.firstNameTextController!,
          focusNode: _model.firstNameFocusNode,
          hint: 'Enter your first name',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _fieldLabel(theme, 'Last Name'),
        const SizedBox(height: 8),
        _inputField(
          theme,
          controller: _model.lastNameTextController!,
          focusNode: _model.lastNameFocusNode,
          hint: 'Enter your last name',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        if (!isMobile) ...[
          _fieldLabel(theme, 'Email Address'),
          const SizedBox(height: 8),
          AppTextField(
            controller: _model.emailTextController!,
            focusNode: _model.emailFocusNode,
            readOnly: isOAuth,
            placeholder: 'user@email.com',
            placeholderStyle: theme.labelMedium.copyWith(color: theme.secondaryText),
            fillColor: isOAuth ? theme.alternate.withOpacity(0.3) : theme.secondaryBackground,
            radius: 12,
            style: theme.bodyMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
        ],
        if (isMobile) ...[
          _fieldLabel(theme, 'Mobile Number'),
          const SizedBox(height: 8),
          AppTextField(
            controller: _model.phoneFieldTextController!,
            focusNode: _model.phoneFieldFocusNode,
            readOnly: true,
            placeholder: '+639XXXXXXXXX',
            placeholderStyle: theme.labelMedium.copyWith(color: theme.secondaryText),
            fillColor: theme.alternate.withOpacity(0.3),
            radius: 12,
            style: theme.bodyMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
        ],
        if (!isOAuth) ...[
          _fieldLabel(theme, 'Password'),
          const SizedBox(height: 8),
          _inputField(
            theme,
            controller: _model.passwordTextController!,
            focusNode: _model.passwordFocusNode,
            hint: 'Create a password',
            textInputAction: TextInputAction.next,
            obscure: true,
          ),
          const SizedBox(height: 16),
          _fieldLabel(theme, 'Confirm Password'),
          const SizedBox(height: 8),
          _inputField(
            theme,
            controller: _model.confirmPasswordTextController!,
            focusNode: _model.confirmPasswordFocusNode,
            hint: 'Confirm your password',
            textInputAction: TextInputAction.done,
            obscure: true,
          ),
          const SizedBox(height: 16),
        ],
        if (_model.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _model.errorMessage!,
              style: theme.bodySmall.copyWith(color: theme.error),
            ),
          ),
        FFButtonWidget(
          onPressed: _model.isLoading
              ? null
              : () async {
                  _model.errorMessage = null;

                  final firstName = _model.firstNameTextController!.text.trim();
                  final lastName = _model.lastNameTextController!.text.trim();

                  if (firstName.isEmpty || lastName.isEmpty) {
                    _model.errorMessage = 'Please enter your first and last name.';
                    safeSetState(() {});
                    return;
                  }

                  if (!isOAuth) {
                    final pwd = _model.passwordTextController!.text;
                    final confirmPwd = _model.confirmPasswordTextController!.text;
                    if (pwd.isEmpty || pwd != confirmPwd) {
                      _model.errorMessage = 'Passwords do not match or are empty.';
                      safeSetState(() {});
                      return;
                    }
                  }

                  _model.isLoading = true;
                  safeSetState(() {});

                  try {
                    if (isMobile) {
                      // Step 3 Mobile SMS Verification
                      final phone = _model.phoneFieldTextController!.text.trim();
                      FFAppState().phone = phone;
                      await AuthService.instance.authApi.sendOtpPin(phoneNumber: phone);
                      _model.isLoading = false;
                      safeSetState(() {});
                      if (!context.mounted) return;
                      await context.pushNamed(
                        PhoneVerifyUserWidget.routeName,
                        queryParameters: {'phone': phone},
                      );
                    } else {
                      // Step 3 Email Verification (for Email, Google, Apple)
                      final email = _model.emailTextController!.text.trim();
                      FFAppState().email = email;
                      await AuthService.instance.authApi.sendEmailOtp(email: email);
                      _model.isLoading = false;
                      safeSetState(() {});
                      if (!context.mounted) return;
                      await context.pushNamed(
                        EmailVerifyWidget.routeName,
                        queryParameters: {'email': email},
                      );
                    }
                  } catch (e) {
                    _model.isLoading = false;
                    final message = ErrorHandler.describeError(e, _l10n);
                    _model.errorMessage = message;
                    safeSetState(() {});
                  }
                },
          text: 'Continue to Step 3 Verification',
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
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(AppThemeData theme, String text) {
    return Text(
      text,
      style: theme.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.primaryText,
      ),
    );
  }

  Widget _inputField(
    AppThemeData theme, {
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    TextInputAction textInputAction = TextInputAction.next,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      obscureText: obscure,
      keyboardType: keyboardType,
      placeholder: hint,
      placeholderStyle: theme.labelMedium.copyWith(color: theme.secondaryText),
      fillColor: theme.secondaryBackground,
      radius: 12,
      style: theme.bodyMedium.copyWith(fontSize: 16),
    );
  }
}
