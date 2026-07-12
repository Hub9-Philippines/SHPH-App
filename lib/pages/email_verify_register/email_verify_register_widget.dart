import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '/api/shph_api.dart';
import '/auth/post_auth_navigation_flow.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import 'email_verify_register_model.dart';

export 'email_verify_register_model.dart';

class EmailVerifyRegisterWidget extends StatefulWidget {
  const EmailVerifyRegisterWidget({
    super.key,
    required this.email,
    required this.password,
    this.role,
  });

  final String email;
  final String password;
  final String? role;

  static String routeName = 'EmailVerifyRegister';
  static String routePath = '/email-verify-register';

  @override
  State<EmailVerifyRegisterWidget> createState() =>
      _EmailVerifyRegisterWidgetState();
}

class _EmailVerifyRegisterWidgetState
    extends State<EmailVerifyRegisterWidget> {
  late EmailVerifyRegisterModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EmailVerifyRegisterModel.new);
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
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: wrapWithModel(
            model: _model.backButtonModel,
            updateCallback: () => safeSetState(() {}),
            child: const BackButtonWidget(),
          ),
          title: Text(
            'Email Verification',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(
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
          actions: const [],
          centerTitle: true,
          elevation: 0,
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
                        'Enter verification code',
                        style: AppTheme.of(context)
                            .headlineMedium
                            .override(
                              font: GoogleFonts.poppins(
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
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                      child: Text(
                        'We\'ve sent a 6-digit code to',
                        textAlign: TextAlign.center,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
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
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 32),
                      child: Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontStyle: AppTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: AppTheme.of(context).primary,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              fontStyle: AppTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
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
                                    font: GoogleFonts.poppins(
                                      fontWeight: AppTheme.of(context)
                                          .bodyLarge
                                          .fontWeight,
                                    ),
                                    letterSpacing: 2,
                                    fontSize: 28,
                                  ),
                              entryAnimation: MaterialPinAnimation.slide,
                              fillColor:
                                  AppTheme.of(context).secondaryBackground,
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
                          final code = _model.pinCodeValue;
                          if (code.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter verification code.'),
                              ),
                            );
                            return;
                          }
                          if (code.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code must be 6 digits.'),
                              ),
                            );
                            return;
                          }

                          try {
                            final data = await ShphAuthApi.instance.registerVerify(
                              payload: {
                                'email': widget.email,
                                'pin': code,
                                'password': widget.password,
                              },
                            );

                            if (!context.mounted) return;

                            final userId = data['user_id'] as String? ??
                                data['id'] as String?;
                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Verification succeeded but could not determine user.'),
                                ),
                              );
                              return;
                            }

                            await PostAuthNavigationFlow()
                                .handlePostAuthNavigation(
                              context: context,
                              userId: userId,
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            _model.pinCodeController.triggerError();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Verification failed: ${e.toString()}'),
                              ),
                            );
                          }
                        },
                        text: 'Verify',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          padding: const EdgeInsets.all(8),
                          iconPadding: EdgeInsetsDirectional.zero,
                          color: AppTheme.of(context).primary,
                          textStyle:
                              AppTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: AppTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
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
                        'Didn\'t receive the code?',
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.poppins(
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
                        _model.pinCodeController.clear();
                        _model.pinCodeController.clearError();
                        _model.pinCodeValue = '';
                        safeSetState(() {});

                        await ShphAuthApi.instance.registerResend(
                          payload: {'email': widget.email},
                        );

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification code resent.'),
                          ),
                        );
                      },
                      child: Text(
                        'Resend Code',
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.poppins(
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
