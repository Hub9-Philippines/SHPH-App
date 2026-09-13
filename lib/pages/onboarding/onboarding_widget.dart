import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;

import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  /// First onboarding slide: pick the in-app language (English/Filipino).
  /// Choosing a language applies it instantly via [FFAppState.locale].
  Widget _buildLanguageSlide(BuildContext context) {
    final theme = AppTheme.of(context);
    final current = FFAppState().locale;

    Widget option(String label, String locale) {
      final selected = current == locale;
      return GestureDetector(
        onTap: () {
          FFAppState().locale = locale;
          safeSetState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
            color: selected
                ? theme.primary.withValues(alpha: 0.08)
                : theme.secondaryBackground,
            border: Border.all(
              color: selected ? theme.primary : theme.border,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.titleMedium.copyWith(
                    color: selected ? theme.primary : theme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: theme.primary,
                  size: 24,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: theme.border,
                  size: 24,
                ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _l10n.chooseYourLanguage,
            textAlign: TextAlign.center,
            style: AppTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: AppTheme.of(context).headlineMedium.fontWeight,
                    fontStyle: AppTheme.of(context).headlineMedium.fontStyle,
                  ),
                  letterSpacing: 0,
                  fontWeight: AppTheme.of(context).headlineMedium.fontWeight,
                  fontStyle: AppTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            _l10n.chooseYourLanguageSubtitle,
            textAlign: TextAlign.center,
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                  ),
                  letterSpacing: 0,
                  fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
          const SizedBox(height: 32),
          option('English', 'en'),
          const SizedBox(height: 12),
          option('Filipino', 'fil'),
        ],
      ),
    );
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
                        context.goNamed(SigninWidget.routeName);
                      },
                      text: _l10n.onbSkip,
                      options: FFButtonOptions(
                        height: 40,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 0, 20, 0),
                        iconPadding:
                            EdgeInsetsDirectional.zero,
                        color: AppTheme.of(context)
                            .primary
                            .withValues(alpha: 0.12),
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
                        hoverColor: AppTheme.of(context).alternate,
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
                            _buildLanguageSlide(context),
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
                                          font: GoogleFonts.plusJakartaSans(
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
                                          font: GoogleFonts.plusJakartaSans(
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
                                          font: GoogleFonts.plusJakartaSans(
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
                                          font: GoogleFonts.plusJakartaSans(
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
                                          font: GoogleFonts.plusJakartaSans(
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
                                          font: GoogleFonts.plusJakartaSans(
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
                            count: 4,
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
                              dotColor: AppTheme.of(context)
                                  .primary
                                  .withValues(alpha: 0.08),
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
                    if (_model.pageViewCurrentIndex.toString() == '3') {
                      // Mark onboarding as completed when navigating from last page
                      FFAppState().hasCompletedOnboarding = true;
                      await context.pushNamed(SigninWidget.routeName);
                    } else {
                    await _model.pageViewController?.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
                text: _l10n.onbNext,
                options: FFButtonOptions(
                  width: MediaQuery.sizeOf(context).width * 0.92,
                  height: 52,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  iconPadding:
                      EdgeInsetsDirectional.zero,
                  color: AppTheme.of(context).primary,
                  textStyle: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: AppTheme.of(context)
                              .titleSmall
                              .fontWeight,
                          fontStyle:
                              AppTheme.of(context).titleSmall.fontStyle,
                        ),
                        color: AppTheme.of(context).onPrimary,
                        letterSpacing: 0,
                        fontWeight:
                            AppTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            AppTheme.of(context).titleSmall.fontStyle,
                      ),
                  elevation: 2,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
