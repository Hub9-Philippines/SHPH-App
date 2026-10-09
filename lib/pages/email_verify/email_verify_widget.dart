import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/auth/auth_util.dart';
import '/auth/base_auth_user_provider.dart';
import '/auth/post_auth_navigation_flow.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/l10n/app_localizations.dart';
import '/services/auth_service.dart';
import '/services/error_handler.dart';
import '/theme/app_theme.dart';
import '../../auth/shph_auth/shph_auth_manager.dart';
import '../../auth/shph_auth/shph_user_provider.dart';
import 'email_verify_model.dart';

export 'email_verify_model.dart';

class EmailVerifyWidget extends StatefulWidget {
  const EmailVerifyWidget({super.key, this.email});

  final String? email;

  static String routeName = 'EmailVerify';
  static String routePath = '/emailVerify';

  @override
  State<EmailVerifyWidget> createState() => _EmailVerifyWidgetState();
}

class _EmailVerifyWidgetState extends State<EmailVerifyWidget> {
  late EmailVerifyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EmailVerifyModel.new);
    _model.pinCodeController ??= TextEditingController();
    _model.pinCodeFocusNode ??= FocusNode();
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
    final targetEmail = widget.email ?? FFAppState().email;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CupertinoPageHeader(
            backgroundColor: theme.primaryBackground,
            title: 'Email Verification',
          ),
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mark_email_read_rounded, color: theme.primary, size: 36),
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify your Email',
                  style: theme.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit verification code to:\n$targetEmail',
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium.copyWith(color: theme.secondaryText),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _model.pinCodeController!,
                  focusNode: _model.pinCodeFocusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  placeholder: 'Enter 6-digit code',
                  placeholderStyle: theme.titleMedium.copyWith(
                    color: theme.secondaryText,
                    letterSpacing: 2,
                  ),
                  fillColor: theme.secondaryBackground,
                  radius: 12,
                  style: theme.titleLarge.copyWith(
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (_) => safeSetState(() {}),
                ),
                if (_model.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _model.errorMessage!,
                      style: theme.bodySmall.copyWith(color: theme.error),
                    ),
                  ),
                const SizedBox(height: 32),
                FFButtonWidget(
                  onPressed: (_model.pinCodeController?.text.length != 6 || _model.isVerifying)
                      ? null
                      : () async {
                          _model.isVerifying = true;
                          _model.errorMessage = null;
                          safeSetState(() {});

                          try {
                            final code = _model.pinCodeController!.text.trim();
                            final res = await AuthService.instance.authApi.verifyEmailOtp(
                              email: targetEmail,
                              code: code,
                            );

                            final userMap = res['user'] as Map<String, dynamic>? ?? res;
                            AuthService.instance.adoptUser(userMap);
                            final user = SerbisyoHubPHShphUser(userMap);
                            currentUser = user;

                            _model.isVerifying = false;
                            safeSetState(() {});
                            if (!context.mounted) return;
                            await PostAuthNavigationFlow().handlePostAuthNavigation(
                              context: context,
                              userId: user.uid ?? '',
                            );
                          } catch (e) {
                            _model.isVerifying = false;
                            _model.errorMessage = ErrorHandler.describeError(e, _l10n);
                            safeSetState(() {});
                          }
                        },
                  text: 'Verify & Continue',
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
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    try {
                      await AuthService.instance.authApi.sendEmailOtp(email: targetEmail);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verification code resent to your email.')),
                      );
                    } catch (e) {
                      ErrorHandler.showError(ErrorHandler.describeError(e, _l10n));
                    }
                  },
                  child: Text(
                    'Resend Code',
                    style: theme.bodyMedium.copyWith(
                      color: theme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
