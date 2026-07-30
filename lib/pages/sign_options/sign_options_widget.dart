import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'sign_options_model.dart';

export 'sign_options_model.dart';

class SignOptionsWidget extends StatefulWidget {
  const SignOptionsWidget({super.key});

  static String routeName = 'SignOptions';
  static String routePath = '/signOptions';

  @override
  State<SignOptionsWidget> createState() => _SignOptionsWidgetState();
}

class _SignOptionsWidgetState extends State<SignOptionsWidget> {
  late SignOptionsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SignOptionsModel.new);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: true,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          body: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 40, 0, 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/welcome-graphic.png',
                    width: double.infinity,
                    height: 349.61,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Welcome to ',
                              textAlign: TextAlign.center,
                              style: AppTheme.of(context)
                                  .headlineLarge
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: AppTheme.of(context)
                                          .headlineLarge
                                          .fontStyle,
                                    ),
                                    fontSize: 24,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: AppTheme.of(context)
                                        .headlineLarge
                                        .fontStyle,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'SerbisyoHub PH',
                              textAlign: TextAlign.center,
                              style: AppTheme.of(context)
                                  .headlineLarge
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: AppTheme.of(context)
                                          .headlineLarge
                                          .fontStyle,
                                    ),
                                    color: AppTheme.of(context).primary,
                                    fontSize: 24,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: AppTheme.of(context)
                                        .headlineLarge
                                        .fontStyle,
                                  ),
                            ),
                          ],
                        ),
                        Text(
                          'Connecting Local Needs with Trusted Providers',
                          textAlign: TextAlign.center,
                          style: AppTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: AppTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color:
                                    AppTheme.of(context).secondaryText,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                fontStyle: AppTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            FFButtonWidget(
                              onPressed: () async {
                                FFAppState().tempsignuprole = 'client';
                                safeSetState(() {});

                                await context.pushNamed(SignupWidget.routeName);
                              },
                              text: 'Sign Up as Client',
                              icon: const Icon(
                                Icons.person_outline,
                                size: 24,
                              ),
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 0, 16, 0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 12, 0),
                                color: AppTheme.of(context).primary,
                                textStyle: AppTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: AppTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      color: Colors.white,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: AppTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                elevation: 0,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            FFButtonWidget(
                              onPressed: () async {
                                FFAppState().tempsignuprole = 'pro';
                                safeSetState(() {});

                                await context.pushNamed(SignupWidget.routeName);
                              },
                              text: 'Sign Up as Service Provider',
                              icon: const Icon(
                                Icons.work_outline,
                                size: 24,
                              ),
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 56,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 0, 16, 0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 12, 0),
                                color: AppTheme.of(context)
                                    .primaryBackground,
                                textStyle: AppTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: AppTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      color:
                                          AppTheme.of(context).primary,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: AppTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                elevation: 0,
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).primary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ].divide(const SizedBox(height: 16)),
                        ),
                      ].divide(const SizedBox(height: 24)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTheme.of(context)
                            .bodyMedium
                            .override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: AppTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: AppTheme.of(context)
                                  .secondaryText,
                              letterSpacing: 0,
                              fontWeight: AppTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: AppTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          await context.pushNamed(SigninWidget.routeName);
                        },
                        child: Text(
                          'Sign In',
                          style: AppTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: AppTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color:
                                    AppTheme.of(context).primary,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                fontStyle: AppTheme.of(context)
                                    .bodyMedium
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
      ),
    );
}
