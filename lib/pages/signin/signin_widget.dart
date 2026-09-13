import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '/auth/auth_util.dart';
import '/auth/post_auth_navigation_flow.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/services/error_handler.dart';
import '/theme/app_theme.dart';
import '../../auth/shph_auth/shph_auth_manager.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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
                    _buildTabBar(theme),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 520,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _l10n.siWelcome,
          textAlign: TextAlign.center,
          style: theme.headlineLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _l10n.siWelcomeSubtitle,
          textAlign: TextAlign.center,
          style: theme.bodyMedium.copyWith(
            color: AppTheme.of(context).secondaryText,
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
                  _l10n.siPhone,
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
                  _l10n.siEmail,
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
          _l10n.siMobileNumber,
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
                        _model.errorMessage = _l10n.siPhoneNumberRequired;
                        safeSetState(() {});
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_l10n.siPhoneNumberRequired),
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
                        final message = ErrorHandler.describeError(e, _l10n);
                        _model.errorMessage = message;
                        safeSetState(() {});
                        if (!context.mounted) return;
                        ErrorHandler.showError(message);
                      }
                    },
          text: _model.isPhoneLoginLoading ? _l10n.siSigningIn : _l10n.siSignIn,
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
            disabledTextColor: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        _OrDivider(),
        const SizedBox(height: 16),
        _SocialButton(
          icon: Icons.g_mobiledata_rounded,
          label: _l10n.siContinueWithGoogle,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_l10n.siGoogleComingSoon)),
            );
          },
        ),
        const SizedBox(height: 10),
        _SocialButton(
          icon: Icons.apple_rounded,
          label: _l10n.siContinueWithApple,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_l10n.siAppleComingSoon)),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => context.goNamed(ForgotPasswordWidget.routeName),
              child: Text(
                _l10n.siForgotPassword,
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
              _l10n.siNoAccountYet,
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => context.goNamed(SignupWidget.routeName),
              child: Text(
                _l10n.siSignUp,
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
          _l10n.siEmail,
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
              _l10n.siInvalidEmail,
              style: theme.bodySmall.copyWith(color: theme.error),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          _l10n.siPassword,
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
            hintText: '••••••••',
            hintStyle: theme.bodyLarge.copyWith(color: theme.secondaryText),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.alternate,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.primary,
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
                                as ShphAuthManager)
                            .signInWithEmail(
                          context,
                          _model.emailTextFieldTextController.text,
                          _model.passwordTextFieldTextController.text,
                        );
                        if (user == null) {
                          _model.isEmailLoginLoading = false;
                          _model.errorMessage = _l10n.siInvalidEmailOrPassword;
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
                        final message = ErrorHandler.describeError(e, _l10n);
                        _model.errorMessage = message;
                        safeSetState(() {});
                        if (!context.mounted) return;
                        ErrorHandler.showError(message);
                      }
                    },
          text: _model.isEmailLoginLoading ? _l10n.siSigningIn : _l10n.siSignIn,
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
            disabledTextColor: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        _OrDivider(),
        const SizedBox(height: 16),
        _SocialButton(
          icon: Icons.g_mobiledata_rounded,
          label: _l10n.siContinueWithGoogle,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_l10n.siGoogleComingSoon)),
            );
          },
        ),
        const SizedBox(height: 10),
        _SocialButton(
          icon: Icons.apple_rounded,
          label: _l10n.siContinueWithApple,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_l10n.siAppleComingSoon)),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => context.goNamed(ForgotPasswordWidget.routeName),
              child: Text(
                _l10n.siForgotPassword,
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
              _l10n.siNoAccountYet,
              style: theme.bodyMedium.copyWith(color: theme.secondaryText),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => context.goNamed(SignupWidget.routeName),
              child: Text(
                _l10n.siSignUp,
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
            AppLocalizations.of(context)!.siOrContinueWith,
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
      child: AppButton(
        onPressed: onTap,
        variant: AppButtonVariant.outlined,
        borderRadius: 12,
        borderSide: BorderSide(color: theme.alternate),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: theme.primaryText),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.bodyMedium.copyWith(
                color: theme.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
