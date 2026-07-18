import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '/api/shph_api.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'signup_model.dart';

export 'signup_model.dart';

class SignupWidget extends StatefulWidget {
  const SignupWidget({super.key});

  static String routeName = 'Signup';
  static String routePath = '/signup';

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget>
    with TickerProviderStateMixin {
  late SignupModel _model;

  bool _skipEmailVerification = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SignupModel.new);

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    _model.phoneFieldTextController ??= TextEditingController();
    _model.phoneFieldFocusNode ??= FocusNode();
    _model.phoneFieldMask = MaskTextInputFormatter(mask: '+63##########');
    handlePhoneAuthStateChanges(context);
    _model.emailTextFieldTextController ??= TextEditingController();
    _model.emailTextFieldFocusNode ??= FocusNode();
    _model.passwordTextFieldTextController ??= TextEditingController();
    _model.passwordTextFieldFocusNode ??= FocusNode();
    _model.passwordTextFieldFocusNode!.addListener(() => safeSetState(() {}));
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
                    const SizedBox(height: 32),
                    _buildTabBar(theme),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 440,
                      child: TabBarView(
                        controller: _model.tabBarController,
                        children: [
                          _buildPhoneTab(theme),
                          _buildEmailTab(theme),
                        ],
                      ),
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
            color: const Color(0xFF889096),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(AppThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.alternate,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _model.tabBarController!.animateTo(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _model.tabBarCurrentIndex == 0
                      ? theme.secondaryBackground
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _model.tabBarCurrentIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Phone',
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium.copyWith(
                    fontWeight: _model.tabBarCurrentIndex == 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: _model.tabBarCurrentIndex == 0
                        ? theme.primaryText
                        : theme.secondaryText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _model.tabBarController!.animateTo(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _model.tabBarCurrentIndex == 1
                      ? theme.secondaryBackground
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _model.tabBarCurrentIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Email',
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium.copyWith(
                    fontWeight: _model.tabBarCurrentIndex == 1
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: _model.tabBarCurrentIndex == 1
                        ? theme.primaryText
                        : theme.secondaryText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneTab(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile number',
          style: theme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _model.phoneFieldTextController,
          focusNode: _model.phoneFieldFocusNode,
          onChanged: (_) => EasyDebounce.debounce(
            '_model.phoneFieldTextController',
            const Duration(milliseconds: 100),
            () async {
              _model.isPhoneValid =
                  _model.phoneFieldTextController.text.length == 13;
              safeSetState(() {});
              FFAppState().phone = _model.phoneFieldTextController.text;
              safeSetState(() {});
            },
          ),
          autofocus: true,
          textInputAction: TextInputAction.go,
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
                color: _model.isPhoneValid ? theme.secondaryText : theme.error,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _model.isPhoneValid ? theme.secondaryText : theme.error,
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
        if (_model.errorMessage != null && _model.tabBarCurrentIndex == 0)
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

                  if (_model.phoneFieldTextController.text != '') {
                    final phoneNumberVal =
                        _model.phoneFieldTextController.text;
                    if (phoneNumberVal.isEmpty ||
                        !phoneNumberVal.startsWith('+')) {
                      _model.isLoading = false;
                      _model.errorMessage =
                          'Phone Number is required and has to start with +.';
                      safeSetState(() {});
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Phone Number is required and has to start with +.'),
                        ),
                      );
                      return;
                    }
                    try {
                      if (!context.mounted) return;
                      FFAppState().phoneLoginMode = false;
                      await beginPhoneAuth(
                        context: context,
                        phoneNumber: phoneNumberVal,
                        onCodeSent: (context) {
                          if (!context.mounted) return;
                          context.replaceNamed(
                            PhoneVerifyUserWidget.routeName,
                          );
                        },
                      );
                      _model.isLoading = false;
                      safeSetState(() {});
                    } catch (e) {
                      _model.isLoading = false;
                      _model.errorMessage =
                          'An error occurred. Please try again.';
                      safeSetState(() {});
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  } else {
                    _model.isLoading = false;
                    _model.errorMessage =
                        'Please input your phone number to continue';
                    safeSetState(() {});
                    if (!context.mounted) return;
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) => AlertDialog(
                        title: const Text('Phone number is empty'),
                        content: const Text(
                            'Please input your phone number to continue'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(alertDialogContext),
                            child: const Text('Ok'),
                          ),
                        ],
                      ),
                    );
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

  Widget _buildEmailTab(AppThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: theme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _model.emailTextFieldTextController,
          focusNode: _model.emailTextFieldFocusNode,
          onChanged: (_) => EasyDebounce.debounce(
            '_model.emailTextFieldTextController',
            Duration.zero,
            () {
              _model.isEmailValid = functions.checkEmailRegex(
                  _model.emailTextFieldTextController.text);
              safeSetState(() {});
            },
          ),
          autofocus: false,
          textInputAction: TextInputAction.next,
          obscureText: false,
          decoration: InputDecoration(
            labelText: 'Email address',
            labelStyle: theme.bodyLarge.copyWith(color: theme.secondaryText),
            hintText: 'you@example.com',
            hintStyle: theme.bodyLarge.copyWith(color: theme.secondaryText),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: !_model.isEmailValid ? theme.error : theme.alternate,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: !_model.isEmailValid ? theme.error : theme.alternate,
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
            fillColor: theme.primaryBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
          style: theme.bodyLarge,
          cursorColor: theme.primaryText,
          validator:
              _model.emailTextFieldTextControllerValidator.asValidator(context),
        ),
        if (!_model.isEmailValid)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Invalid email',
              style: theme.bodySmall.copyWith(color: theme.error),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Password',
          style: theme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _model.passwordTextFieldTextController,
          focusNode: _model.passwordTextFieldFocusNode,
          onChanged: (_) => EasyDebounce.debounce(
            '_model.passwordTextFieldTextController',
            Duration.zero,
            () => safeSetState(() {}),
          ),
          autofocus: false,
          textInputAction: TextInputAction.done,
          obscureText: !_model.passwordTextFieldVisibility,
          decoration: InputDecoration(
            labelText: 'Create a password',
            labelStyle: theme.bodyLarge.copyWith(color: theme.secondaryText),
            hintText: '••••••••',
            hintStyle: theme.bodyLarge.copyWith(color: theme.secondaryText),
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
            fillColor: theme.primaryBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            suffixIcon: InkWell(
              onTap: () => safeSetState(
                  () => _model.passwordTextFieldVisibility = !_model.passwordTextFieldVisibility),
              focusNode: FocusNode(skipTraversal: true),
              child: Icon(
                _model.passwordTextFieldVisibility
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.secondaryText,
                size: 24,
              ),
            ),
          ),
          style: theme.bodyLarge,
          cursorColor: theme.primaryText,
          validator: _model.passwordTextFieldTextControllerValidator
              .asValidator(context),
        ),
        if (_model.errorMessage != null && _model.tabBarCurrentIndex == 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _model.errorMessage!,
              style: theme.bodySmall.copyWith(color: theme.error),
            ),
          ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _skipEmailVerification,
                  onChanged: (v) =>
                      setState(() => _skipEmailVerification = v ?? false),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Skip email verification',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FFButtonWidget(
          onPressed: _model.isLoading
              ? null
              : (_model.emailTextFieldTextController.text == '' ||
                      _model.passwordTextFieldTextController.text == '' ||
                      !_model.isEmailValid)
                  ? null
                  : () async {
                      _model.errorMessage = null;
                      _model.isLoading = true;
                      safeSetState(() {});

                      try {
                        if (_skipEmailVerification) {
                          GoRouter.of(context).prepareAuthEvent();
                          await ShphAuthApi.instance.register(payload: {
                            'email':
                                _model.emailTextFieldTextController.text,
                            'password':
                                _model.passwordTextFieldTextController.text,
                            'role': 'client',
                          });
                          if (!context.mounted) return;
                          context.goNamed(HomeWidget.routeName);
                        } else {
                          GoRouter.of(context).prepareAuthEvent();
                          await authManager.createAccountWithEmail(
                            context,
                            _model.emailTextFieldTextController.text,
                            _model.passwordTextFieldTextController.text,
                          );

                          if (!context.mounted) return;

                          context.pushReplacementNamed(
                            EmailVerifyRegisterWidget.routeName,
                            extra: {
                              'email':
                                  _model.emailTextFieldTextController.text,
                              'password':
                                  _model.passwordTextFieldTextController.text,
                            },
                          );
                        }
                      } catch (e) {
                        _model.isLoading = false;
                        _model.errorMessage =
                            'An error occurred. Please try again.';
                        safeSetState(() {});
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    },
          text: _model.isLoading ? 'Signing Up...' : 'Create Account',
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
}
