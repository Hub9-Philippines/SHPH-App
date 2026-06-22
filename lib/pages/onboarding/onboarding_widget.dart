import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;

import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'onboarding_model.dart';

export 'onboarding_model.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});

  static String routeName = 'Onboarding';
  static String routePath = '/onboarding';

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  late OnboardingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, OnboardingModel.new);

    // On page load action - request permissions in background
    SchedulerBinding.instance.addPostFrameCallback((_) {
      LoggingService.debug('Page initialized, rendering content',
          tag: 'Onboarding');
      // Request permissions asynchronously without blocking UI
      _requestPermissionsInBackground();
    });
  }

  /// Request permissions in background without blocking UI
  void _requestPermissionsInBackground() {
    Future.microtask(() async {
      try {
        await requestPermission(locationPermission);
      } catch (e) {
        LoggingService.warning('Location permission error: $e',
            tag: 'Onboarding');
      }
      try {
        await requestPermission(cameraPermission);
      } catch (e) {
        LoggingService.warning('Camera permission error: $e',
            tag: 'Onboarding');
      }
    });
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
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FFButtonWidget(
                      onPressed: () async {
                        // Mark onboarding as completed
                        FFAppState().hasCompletedOnboarding = true;
                        context.goNamed(SignOptionsWidget.routeName);
                      },
                      text: 'Skip',
                      options: FFButtonOptions(
                        height: 40,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 0, 20, 0),
                        iconPadding:
                            EdgeInsetsDirectional.zero,
                        color: const Color(0x1E368EFF),
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
                                  color: AppTheme.of(context).primary,
                                  letterSpacing: 0,
                                  fontWeight: AppTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                        elevation: 0,
                        borderRadius: BorderRadius.circular(24),
                        hoverColor: const Color(0xFF7C7C7C),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  constraints: const BoxConstraints(
                    minHeight: 400,
                    maxHeight: 700,
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 40),
                        child: PageView(
                          controller: _model.pageViewController ??=
                              PageController(initialPage: 0),
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20, 0, 20, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/images/onboarding-1.png',
                                      width: double.infinity,
                                      height: MediaQuery.sizeOf(context).height * 0.4,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Text(
                                    'Find Skilled Pros in Seconds',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .headlineMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .headlineMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .headlineMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  Text(
                                    'From expert locksmiths to master carpenters, get your home projects done by the best in the business.',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20, 0, 20, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/images/onboarding-2.png',
                                      width: double.infinity,
                                      height: MediaQuery.sizeOf(context).height * 0.4,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Text(
                                    'Grow Your Service Business',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .headlineMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .headlineMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .headlineMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  Text(
                                    'Join our community of Pros to find local clients, manage your schedule, and get paid securely.',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20, 0, 20, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/images/onboarding-3.png',
                                      width: double.infinity,
                                      height: MediaQuery.sizeOf(context).height * 0.4,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Text(
                                    'Safe, Fast & Reliable',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .headlineMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .headlineMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .headlineMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  Text(
                                    'Verified profiles, transparent reviews, and secure payments for total peace of mind.',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 0, 0, 16),
                          child: smooth_page_indicator.SmoothPageIndicator(
                            controller: _model.pageViewController ??=
                                PageController(initialPage: 0),
                            count: 3,
                            axisDirection: Axis.horizontal,
                            onDotClicked: (i) async {
                              await _model.pageViewController!.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                              safeSetState(() {});
                            },
                            effect: smooth_page_indicator.ExpandingDotsEffect(
                              expansionFactor: 2,
                              spacing: 5,
                              radius: 3,
                              dotWidth: 15,
                              dotHeight: 5,
                              dotColor: const Color(0x13368EFF),
                              activeDotColor:
                                  AppTheme.of(context).primary,
                              paintStyle: PaintingStyle.fill,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FFButtonWidget(
                onPressed: () async {
                  LoggingService.debug(
                    'Next button pressed, current page: ${_model.pageViewCurrentIndex}',
                    tag: 'Onboarding',
                  );
                    if (_model.pageViewCurrentIndex.toString() == '2') {
                      // Mark onboarding as completed when navigating from last page
                      FFAppState().hasCompletedOnboarding = true;
                      await context.pushNamed(SignOptionsWidget.routeName);
                    } else {
                    await _model.pageViewController?.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
                text: 'Next',
                options: FFButtonOptions(
                  width: MediaQuery.sizeOf(context).width * 0.92,
                  height: 52,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  iconPadding:
                      EdgeInsetsDirectional.zero,
                  color: AppTheme.of(context).primary,
                  textStyle: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.poppins(
                          fontWeight: AppTheme.of(context)
                              .titleSmall
                              .fontWeight,
                          fontStyle:
                              AppTheme.of(context).titleSmall.fontStyle,
                        ),
                        color: Colors.white,
                        letterSpacing: 0,
                        fontWeight:
                            AppTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            AppTheme.of(context).titleSmall.fontStyle,
                      ),
                  elevation: 0,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
