import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'pro_unverified_landing_model.dart' show ProUnverifiedLandingModel;

export 'pro_unverified_landing_model.dart';

class ProUnverifiedLandingWidget extends StatefulWidget {
  const ProUnverifiedLandingWidget({super.key});

  static String routeName = 'ProUnverifiedLanding';
  static String routePath = '/pro-unverified-landing';

  @override
  State<ProUnverifiedLandingWidget> createState() =>
      _ProUnverifiedLandingWidgetState();
}

class _ProUnverifiedLandingWidgetState
    extends State<ProUnverifiedLandingWidget> {
  late ProUnverifiedLandingModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProUnverifiedLandingModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: GestureDetector(
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
            leading: IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Back to Home',
              onPressed: () => context.goNamed(HomeWidget.routeName),
            ),
            title: Text(
              'Verification Required',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Warning Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0x2EFF5252),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 64,
                      color: AppTheme.of(context).error,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Warning Title
                  Text(
                    'Account Not Verified',
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).headlineMedium.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Warning Message
                  Text(
                    'Your account is not yet verified. To access your provider dashboard, you must complete the identity verification process.',
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).bodyLarge.override(
                          color: AppTheme.of(context).secondaryText,
                        ),
                  ),
                  const SizedBox(height: 48),
                  // Info Cards
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.of(context)
                            .primaryText
                            .withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.of(context).primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Face Scan',
                              style: AppTheme.of(context).bodyMedium.override(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.of(context).primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Document Verification',
                              style: AppTheme.of(context).bodyMedium.override(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.of(context).primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Review Process (approx. 30 min)',
                              style: AppTheme.of(context).bodyMedium.override(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Start Verification Button
                  FFButtonWidget(
                    onPressed: () {
                      context.pushNamed(DocumentScanWidget.routeName);
                    },
                    text: 'Start Verification',
                    icon: const Icon(
                      Icons.verified_user_rounded,
                      size: 24,
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56,
                      padding: const EdgeInsets.all(8),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
                      color: AppTheme.of(context).primary,
                      textStyle: AppTheme.of(context).titleMedium.override(
                            color: Colors.white,
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                          ),
                      elevation: 2,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
}
