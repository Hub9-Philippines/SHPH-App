import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '/auth/auth_util.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/error_handler.dart';
import '/theme/app_theme.dart';
import '../../auth/shph_auth/shph_auth_manager.dart';
import 'signup_model.dart';

export 'signup_model.dart';

class SignupWidget extends StatefulWidget {
  const SignupWidget({super.key});

  static String routeName = 'Signup';
  static String routePath = '/signup';

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  late SignupModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            elevation: 0,
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
                    const SizedBox(height: 40),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.person_add_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 20),
        Text(
          'Create Account',
          style: theme.headlineLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Join SerbisyoHub PH and access home services at your fingertips.',
          style: theme.bodyMedium.copyWith(
            color: AppTheme.of(context).secondaryText,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(theme, 'First Name'),
        const SizedBox(height: 8),
        _inputField(
          theme,
          controller: _model.firstNameTextController!,
          focusNode: _model.firstNameFocusNode,
          hint: 'Juan',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _fieldLabel(theme, 'Middle Name (optional)'),
        const SizedBox(height: 8),
        _inputField(
          theme,
          controller: _model.middleNameTextController!,
          focusNode: _model.middleNameFocusNode,
          hint: 'Santos',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _fieldLabel(theme, 'Last Name'),
        const SizedBox(height: 8),
        _inputField(
          theme,
          controller: _model.lastNameTextController!,
          focusNode: _model.lastNameFocusNode,
          hint: 'Dela Cruz',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _fieldLabel(theme, 'Email'),
        const SizedBox(height: 8),
        _inputField(
          theme,
          controller: _model.emailTextController!,
          focusNode: _model.emailFocusNode,
          hint: 'you@example.com',
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _fieldLabel(theme, 'Mobile number'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _model.phoneFieldTextController,
          focusNode: _model.phoneFieldFocusNode,
          onChanged: (_) => EasyDebounce.debounce(
            '_model.phoneFieldTextController',
            const Duration(milliseconds: 100),
            () {
              _model.isPhoneValid =
                  _model.phoneFieldTextController.text.length == 13;
              safeSetState(() {});
            },
          ),
          autofocus: false,
          textInputAction: TextInputAction.next,
          obscureText: false,
          decoration: InputDecoration(
            labelText: '+63',
            labelStyle: theme.labelMedium.copyWith(fontSize: 16),
            hintText: '9123456789',
            hintStyle: theme.labelMedium.copyWith(
              fontSize: 16,
              color: theme.secondaryText,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    _model.isPhoneValid ? theme.secondaryText : theme.error,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    _model.isPhoneValid ? theme.secondaryText : theme.error,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.error, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.error, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.secondaryBackground,
          ),
          style: theme.bodyMedium.copyWith(fontSize: 16),
          textAlign: TextAlign.start,
          maxLength: 13,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          buildCounter: (context,
                  {required currentLength,
                  required isFocused,
                  maxLength}) =>
              null,
          keyboardType: TextInputType.phone,
          cursorColor: theme.primaryText,
          enableInteractiveSelection: true,
          validator:
              _model.phoneFieldTextControllerValidator.asValidator(context),
          inputFormatters: [_model.phoneFieldMask],
        ),
        const SizedBox(height: 16),
        _fieldLabel(theme, 'Password'),
        const SizedBox(height: 8),
        _inputField(
          theme,
          controller: _model.passwordTextController!,
          focusNode: _model.passwordFocusNode,
          hint: 'At least 8 characters',
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
          hint: 'Repeat your password',
          textInputAction: TextInputAction.done,
          obscure: true,
        ),
        if (_model.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _model.errorMessage!,
              style: theme.bodySmall.copyWith(color: theme.error),
            ),
          ),
        const SizedBox(height: 24),
        FFButtonWidget(
          onPressed: _model.isLoading
              ? null
              : () async {
                  _model.errorMessage = null;
                  _model.isLoading = true;
                  safeSetState(() {});

                  final phoneNumberVal =
                      _model.phoneFieldTextController.text;
                  if (phoneNumberVal.isEmpty ||
                      !phoneNumberVal.startsWith('+')) {
                    _model.isLoading = false;
                    _model.errorMessage =
                        'Phone Number is required and has to start with +.';
                    safeSetState(() {});
                    return;
                  }
                  if (_model.passwordTextController.text !=
                      _model.confirmPasswordTextController.text) {
                    _model.isLoading = false;
                    _model.errorMessage = 'Passwords do not match.';
                    safeSetState(() {});
                    return;
                  }
                  try {
                    FFAppState().phone = phoneNumberVal;
                    await (authManager as ShphAuthManager)
                        .createAccountWithEmail(
                      context,
                      email: _model.emailTextController.text.trim(),
                      password: _model.passwordTextController.text,
                      firstName: _model.firstNameTextController.text.trim(),
                      middleName:
                          _model.middleNameTextController.text.trim(),
                      lastName: _model.lastNameTextController.text.trim(),
                      phoneNumber: phoneNumberVal,
                      role: FFAppState().tempsignuprole.isNotEmpty
                          ? FFAppState().tempsignuprole
                          : 'client',
                    );
                    _model.isLoading = false;
                    safeSetState(() {});
                    if (!context.mounted) return;
                    await context.pushNamed(
                      PhoneVerifyUserWidget.routeName,
                    );
                  } catch (e) {
                    _model.isLoading = false;
                    final message = ErrorHandler.describeError(e);
                    _model.errorMessage = message;
                    safeSetState(() {});
                    if (!context.mounted) return;
                    ErrorHandler.showError(message);
                  }
                  safeSetState(() {});
                },
          text: _model.isLoading ? 'Signing Up...' : 'Sign Up',
          options: FFButtonOptions(
            width: double.infinity,
            height: 52,
            color: _model.isLoading ? theme.alternate : theme.primary,
            textStyle: theme.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
            borderRadius: BorderRadius.circular(12),
            disabledColor: theme.alternate,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
            GestureDetector(
              onTap: () => context.pushNamed(SigninWidget.routeName),
              child: Text(
                'Sign In',
                style: theme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fieldLabel(AppThemeData theme, String text) {
    return Text(
      text,
      style: theme.bodyMedium.copyWith(
        fontWeight: FontWeight.w500,
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
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: false,
      textInputAction: textInputAction,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.labelMedium.copyWith(color: theme.secondaryText),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.alternate, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.alternate, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: theme.secondaryBackground,
      ),
      style: theme.bodyMedium.copyWith(fontSize: 16),
      cursorColor: theme.primaryText,
    );
  }
}
