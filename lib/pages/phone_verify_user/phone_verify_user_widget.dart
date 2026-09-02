import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '/auth/post_auth_navigation_flow.dart';
import '/auth/auth_util.dart';
import '/auth/test_auth_user.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/l10n/app_localizations.dart';
import '/services/auth_service.dart';
import '/services/error_handler.dart';
import '/theme/app_theme.dart';
import '../../auth/shph_auth/shph_auth_manager.dart';
import 'phone_verify_user_model.dart';

export 'phone_verify_user_model.dart';

class PhoneVerifyUserWidget extends StatefulWidget {
  const PhoneVerifyUserWidget({super.key});

  static String routeName = 'PhoneVerifyUser';
  static String routePath = '/phoneVerifyUser';

  @override
  State<PhoneVerifyUserWidget> createState() => _PhoneVerifyUserWidgetState();
}

class _PhoneVerifyUserWidgetState extends State<PhoneVerifyUserWidget> {
  late PhoneVerifyUserModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, PhoneVerifyUserModel.new);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CupertinoPageHeader(
            backgroundColor: AppTheme.of(context).primaryBackground,
            title: _l10n.phvTitle,
            titleStyle: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight:
                        AppTheme.of(context).titleLarge.fontWeight,
                    fontStyle:
                        AppTheme.of(context).titleLarge.fontStyle,
                  ),
                  letterSpacing: 0,
                  fontWeight:
                      AppTheme.of(context).titleLarge.fontWeight,
                  fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                ),
          ),
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 40, 0, 16),
                      child: Text(
                        _l10n.phvEnterCode,
                        style: AppTheme.of(context)
                            .headlineMedium
                            .override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: AppTheme.of(context)
                                    .headlineMedium
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .headlineMedium
                                    .fontStyle,
                              ),
                              letterSpacing: 0,
                              fontWeight: AppTheme.of(context)
                                  .headlineMedium
                                  .fontWeight,
                              fontStyle: AppTheme.of(context)
                                  .headlineMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 32),
                      child: Text(
                        _l10n.phvSentCode,
                        textAlign: TextAlign.center,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: AppTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0,
                              fontWeight: AppTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: AppTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                    if (kDebugMode)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Debug: use 000000 to bypass',
                          textAlign: TextAlign.center,
                          style: AppTheme.of(context).bodySmall.override(
                                color: AppTheme.of(context).textTertiary,
                              ),
                        ),
                      ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate cell size based on available width
                          // Available width = constraint width (which is full minus padding)
                          // For 6 cells with 8px spacing between them:
                          // totalWidth = (6 × cellSize) + (5 × spacing)
                          // Solve for cellSize: cellSize = (totalWidth - (5 × spacing)) / 6
                          const spacing = 8.0;
                          const numCells = 6;
                          const totalSpacing = (numCells - 1) * spacing;
                          final availableWidth = constraints.maxWidth;
                          final cellSize = (availableWidth - totalSpacing) / numCells;
                          
                          return MaterialPinField(
                            length: 6,
                            pinController: _model.pinCodeController,
                            onCompleted: (pin) {
                              _model.pinCodeValue = pin;
                              safeSetState(() {});
                            },
                            onChanged: (pin) {
                              _model.pinCodeValue = pin;
                              safeSetState(() {});
                            },
                            theme: MaterialPinTheme(
                              shape: MaterialPinShape.filled,
                              cellSize: Size(cellSize, cellSize),
                              spacing: spacing,
                              borderRadius: BorderRadius.circular(12),
                              textStyle: AppTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: AppTheme.of(context)
                                          .bodyLarge
                                          .fontWeight,
                                    ),
                                    letterSpacing: 2,
                                    fontSize: 28,
                                  ),
                              entryAnimation: MaterialPinAnimation.slide,
                              fillColor: AppTheme.of(context).secondaryBackground,
                              showCursor: false,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            autoFocus: true,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 16),
                      child: FFButtonWidget(
                        onPressed: () async {
                          GoRouter.of(context).prepareAuthEvent();
                          final smsCodeVal = _model.pinCodeValue;
                          if (smsCodeVal.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_l10n.phvErrEnterCode),
                              ),
                            );
                            return;
                          }
                          if (smsCodeVal.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_l10n.phvErrCodeDigits),
                              ),
                            );
                            return;
                          }
                          if (kDebugMode && smsCodeVal == '000000') {
                            final testUser = TestAuthUser(
                              testUid: 'test-user-id',
                              testPhone: FFAppState().phone.isNotEmpty
                                  ? FFAppState().phone
                                  : '+639000000000',
                            );
                            currentUser = testUser;
                            if (!context.mounted) return;
                            await PostAuthNavigationFlow()
                                .handlePostAuthNavigation(
                              context: context,
                              userId: testUser.uid!,
                            );
                            return;
                          }
                          final authService = AuthService.instance;
                          final isRegister =
                              authService.pendingDeliveryMethod != null;
                          final phone = authService.pendingPhone != null &&
                                  authService.pendingPhone!.isNotEmpty
                              ? authService.pendingPhone!
                              : FFAppState().phone;

                          final dynamic verifiedUser;
                          try {
                            if (isRegister) {
                              verifiedUser =
                                  await (authManager as ShphAuthManager)
                                      .verifyRegistration(
                                phoneNumber: phone,
                                pin: smsCodeVal,
                              );
                              authService.clearPendingRegistration();
                            } else {
                              verifiedUser = await verifySmsCode(
                                context: context,
                                smsCode: smsCodeVal,
                                phoneNumber: phone,
                              );
                            }
                          } catch (e) {
                            final message = ErrorHandler.describeError(e, _l10n);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                            _model.pinCodeController.triggerError();
                            return;
                          }
                          if (verifiedUser == null) {
                            _model.pinCodeController.triggerError();
                            return;
                          }

                          // Handle post-auth navigation based on profile completeness and account type
                          if (!context.mounted) return;
                          await PostAuthNavigationFlow()
                              .handlePostAuthNavigation(
                            context: context,
                            userId: verifiedUser.uid,
                          );
                        },
                        text: _l10n.phvVerify,
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          padding: const EdgeInsets.all(8),
                          iconPadding: EdgeInsetsDirectional.zero,
                          color: AppTheme.of(context).primary,
                          textStyle:
                              AppTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: AppTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: AppTheme.of(context).onPrimary,
                                    letterSpacing: 0,
                                    fontWeight: AppTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                          elevation: 0,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                      child: Text(
                        _l10n.phvDidntReceive,
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: AppTheme.of(context)
                                    .bodySmall
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .bodySmall
                                    .fontStyle,
                              ),
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0,
                              fontWeight: AppTheme.of(context)
                                  .bodySmall
                                  .fontWeight,
                              fontStyle: AppTheme.of(context)
                                  .bodySmall
                                  .fontStyle,
                            ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        final authService = AuthService.instance;
                        final isRegister =
                            authService.pendingDeliveryMethod != null;
                        final phoneNumberVal =
                            authService.pendingPhone != null &&
                                    authService.pendingPhone!.isNotEmpty
                                ? authService.pendingPhone!
                                : FFAppState().phone;
                        if (phoneNumberVal.isEmpty ||
                            !phoneNumberVal.startsWith('+')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_l10n.siPhoneNumberRequired),
                            ),
                          );
                          return;
                        }
                        // Clear the PIN field and error state
                        _model.pinCodeController.clear();
                        _model.pinCodeController.clearError();
                        _model.pinCodeValue = '';
                        safeSetState(() {});

                        try {
                          if (isRegister) {
                            await authService.authApi
                                .registerResend(phoneNumber: phoneNumberVal);
                          } else {
                            await beginPhoneAuth(
                              context: context,
                              phoneNumber: phoneNumberVal,
                              onCodeSent: (context) async {
                                context.replaceNamed(
                                  PhoneVerifyUserWidget.routeName,
                                );
                              },
                            );
                          }
                        } catch (e) {
                          final message = ErrorHandler.describeError(e, _l10n);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                      child: Text(
                        _l10n.phvResendCode,
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontStyle: AppTheme.of(context)
                                    .bodySmall
                                    .fontStyle,
                              ),
                              color: AppTheme.of(context).primary,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              fontStyle: AppTheme.of(context)
                                  .bodySmall
                                  .fontStyle,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
