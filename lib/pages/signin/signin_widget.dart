import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '/auth/post_auth_navigation_flow.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import '../../auth/supabase_auth/supabase_auth_manager.dart';
import 'signin_model.dart';

export 'signin_model.dart';

class SigninWidget extends StatefulWidget {
  const SigninWidget({super.key});

  static String routeName = 'Signin';
  static String routePath = '/signin';

  @override
  State<SigninWidget> createState() => _SigninWidgetState();
}

class _SigninWidgetState extends State<SigninWidget>
    with TickerProviderStateMixin {
  late SigninModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SigninModel.new);

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
          child: Icon(Icons.handyman_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome back!',
          style: theme.headlineLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue with your home services.',
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
            Duration.zero,
            () {
              _model.isPhoneValid =
                  _model.phoneFieldTextController.text.length == 13;
              FFAppState().phone = _model.phoneFieldTextController.text;
              safeSetState(() {});
            },
          ),
          autofocus: false,
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
        const SizedBox(height: 20),
        FFButtonWidget(
          onPressed: _model.isPhoneLoginLoading
              ? null
              : (_model.phoneFieldTextController.text == '' ||
                      !_model.isPhoneValid)
                  ? null
                  : () async {
                      _model.errorMessage = null;
                      _model.isPhoneLoginLoading = true;
                      safeSetState(() {});
                      final phoneNumberVal =
                          _model.phoneFieldTextController.text;
                      if (phoneNumberVal.isEmpty ||
                          !phoneNumberVal.startsWith('+')) {
                        _model.isPhoneLoginLoading = false;
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
                        await beginPhoneAuth(
                          context: context,
                          phoneNumber: phoneNumberVal,
                          onCodeSent: (context) async {
                            if (!context.mounted) return;
                            context.goNamedAuth(
                              PhoneVerifyUserWidget.routeName,
                              context.mounted,
                              ignoreRedirect: true,
                            );
                          },
                        );
                      } catch (e) {
                        _model.isPhoneLoginLoading = false;
                        _model.errorMessage =
                            'An error occurred. Please try again.';
                        safeSetState(() {});
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    },
          text: _model.isPhoneLoginLoading ? 'Signing In...' : 'Sign In',
          options: FFButtonOptions(
            width: double.infinity,
            height: 52,
            color: _model.isPhoneLoginLoading ? theme.alternate : theme.primary,
            textStyle: theme.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
            borderRadius: BorderRadius.circular(12),
            disabledColor: theme.alternate,
            disabledTextColor: theme.secondaryBackground,
          ),
        ),
        const SizedBox(height: 16),
        _OrDivider(),
        const SizedBox(height: 16),
        _SocialButton(
          icon: Icons.g_mobiledata_rounded,
          label: 'Continue with Google',
          onTap: () async {
            final user = await (authManager as SupabaseAuthManager)
                .signInWithGoogle(context);
            if (user != null && context.mounted) {
              await PostAuthNavigationFlow().handlePostAuthNavigation(
                context: context,
                userId: user.uid!,
              );
            }
          },
        ),
        const SizedBox(height: 10),
        _SocialButton(
          icon: Icons.apple_rounded,
          label: 'Continue with Apple',
          onTap: () async {
            final user = await (authManager as SupabaseAuthManager)
                .signInWithApple(context);
            if (user != null && context.mounted) {
              await PostAuthNavigationFlow().handlePostAuthNavigation(
                context: context,
                userId: user.uid!,
              );
            }
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => context.goNamed(ForgotPasswordWidget.routeName),
              child: Text(
                'Forgot password',
                style: theme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primary,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account yet? ",
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
            GestureDetector(
              onTap: () => context.goNamed(SignupWidget.routeName),
              child: Text(
                'Sign Up',
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
              _model.isEmailvalid = functions.checkEmailRegex(
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
                color:
                    !_model.isEmailvalid ? theme.error : theme.alternate,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    !_model.isEmailvalid ? theme.error : theme.alternate,
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
        if (!_model.isEmailvalid)
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
            labelText: 'Enter your password',
            labelStyle: theme.bodyLarge.copyWith(color: theme.secondaryText),
            hintText: '••••••••',
            hintStyle: theme.bodyLarge.copyWith(color: theme.secondaryText),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: theme.alternate, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: theme.alternate, width: 1.5),
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
        const SizedBox(height: 20),
        FFButtonWidget(
          onPressed: _model.isEmailLoginLoading
              ? null
              : (_model.emailTextFieldTextController.text == '' ||
                      _model.passwordTextFieldTextController.text == '' ||
                      !_model.isEmailvalid)
                  ? null
                  : () async {
                      _model.errorMessage = null;
                      _model.isEmailLoginLoading = true;
                      safeSetState(() {});
                      try {
                        GoRouter.of(context).prepareAuthEvent();
                        final user = await (authManager
                                as SupabaseAuthManager)
                            .signInWithEmail(
                          context,
                          _model.emailTextFieldTextController.text,
                          _model.passwordTextFieldTextController.text,
                        );
                        if (user == null) {
                          _model.isEmailLoginLoading = false;
                          _model.errorMessage = 'Invalid email or password';
                          safeSetState(() {});
                          return;
                        }
                        if (!context.mounted) return;
                        await PostAuthNavigationFlow()
                            .handlePostAuthNavigation(
                          context: context,
                          userId: user.uid!,
                        );
                      } catch (e) {
                        _model.isEmailLoginLoading = false;
                        _model.errorMessage =
                            'An error occurred. Please try again.';
                        safeSetState(() {});
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    },
          text: _model.isEmailLoginLoading ? 'Signing In...' : 'Sign In',
          options: FFButtonOptions(
            width: double.infinity,
            height: 52,
            color: _model.isEmailLoginLoading ? theme.alternate : theme.primary,
            textStyle: theme.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
            borderRadius: BorderRadius.circular(12),
            disabledColor: theme.alternate,
            disabledTextColor: theme.secondaryBackground,
          ),
        ),
        const SizedBox(height: 16),
        _OrDivider(),
        const SizedBox(height: 16),
        _SocialButton(
          icon: Icons.g_mobiledata_rounded,
          label: 'Continue with Google',
          onTap: () async {
            final user = await (authManager as SupabaseAuthManager)
                .signInWithGoogle(context);
            if (user != null && context.mounted) {
              await PostAuthNavigationFlow().handlePostAuthNavigation(
                context: context,
                userId: user.uid!,
              );
            }
          },
        ),
        const SizedBox(height: 10),
        _SocialButton(
          icon: Icons.apple_rounded,
          label: 'Continue with Apple',
          onTap: () async {
            final user = await (authManager as SupabaseAuthManager)
                .signInWithApple(context);
            if (user != null && context.mounted) {
              await PostAuthNavigationFlow().handlePostAuthNavigation(
                context: context,
                userId: user.uid!,
              );
            }
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => context.goNamed(ForgotPasswordWidget.routeName),
              child: Text(
                'Forgot password',
                style: theme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primary,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account yet? ",
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
            GestureDetector(
              onTap: () => context.goNamed(SignOptionsWidget.routeName),
              child: Text(
                'Sign Up',
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

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: theme.alternate)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: theme.bodySmall.copyWith(color: theme.secondaryText),
          ),
        ),
        Expanded(child: Divider(color: theme.alternate)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: theme.alternate),
        ),
      ),
    );
  }
}
