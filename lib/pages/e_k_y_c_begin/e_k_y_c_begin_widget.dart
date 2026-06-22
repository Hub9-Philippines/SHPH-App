import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'e_k_y_c_begin_model.dart';

export 'e_k_y_c_begin_model.dart';

/// Create a starting page for eKYC (Electronic Know Your Customer) for
/// verifying users like "We need to verify your identity" then the list of
/// what will be the requirements - a face scan and an ID or document scan
class EKYCBeginWidget extends StatefulWidget {
  const EKYCBeginWidget({super.key});

  static String routeName = 'eKYCBegin';
  static String routePath = '/eKYCBegin';

  @override
  State<EKYCBeginWidget> createState() => _EKYCBeginWidgetState();
}

class _EKYCBeginWidgetState extends State<EKYCBeginWidget> {
  late EKYCBeginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EKYCBeginModel.new);
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
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Text(
              'Provider Verification',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                      fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                    ),
                    letterSpacing: 0,
                    fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                    fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                  ),
            ),
            actions: const [],
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Color(0x31368EFF),
                            shape: BoxShape.circle,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional.center,
                            child: Icon(
                              Icons.verified_user_rounded,
                              color: AppTheme.of(context).primary,
                              size: 64,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Complete Your Verification',
                              textAlign: TextAlign.center,
                              style:
                                  AppTheme.of(context).headlineMedium.override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: AppTheme.of(context)
                                              .headlineMedium
                                              .fontStyle,
                                        ),
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: AppTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                            ),
                            Text(
                              'To become a verified provider and start accepting bookings, we need to verify your identity with a valid government ID and a face scan. This ensures trust and safety for all users.',
                              textAlign: TextAlign.center,
                              style: AppTheme.of(context).bodyLarge.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: AppTheme.of(context)
                                          .bodyLarge
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .bodyLarge
                                          .fontStyle,
                                    ),
                                    color: AppTheme.of(context).secondaryText,
                                    letterSpacing: 0,
                                    fontWeight: AppTheme.of(context)
                                        .bodyLarge
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyLarge
                                        .fontStyle,
                                    lineHeight: 1.5,
                                  ),
                            ),
                          ].divide(const SizedBox(height: 16)),
                        ),
                        Text(
                          'What you\'ll need:',
                          textAlign: TextAlign.center,
                          style: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: AppTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                fontStyle:
                                    AppTheme.of(context).titleMedium.fontStyle,
                              ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.of(context).alternate,
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppTheme.of(context).accent2,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional.center,
                                            child: Icon(
                                              Icons.face_rounded,
                                              color:
                                                  AppTheme.of(context).primary,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Face Verification',
                                                style: AppTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            AppTheme.of(context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          AppTheme.of(context)
                                                              .titleSmall
                                                              .fontStyle,
                                                    ),
                                              ),
                                              Text(
                                                'Take a selfie to verify your identity',
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
                                                      color:
                                                          AppTheme.of(context)
                                                              .secondaryText,
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
                                            ].divide(const SizedBox(height: 4)),
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 16)),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.of(context).alternate,
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppTheme.of(context).accent3,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional.center,
                                            child: Icon(
                                              Icons.credit_card_rounded,
                                              color:
                                                  AppTheme.of(context).primary,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Government ID',
                                                style: AppTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            AppTheme.of(context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          AppTheme.of(context)
                                                              .titleSmall
                                                              .fontStyle,
                                                    ),
                                              ),
                                              Text(
                                                'Scan your driver\'s license, passport, or national ID',
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
                                                      color:
                                                          AppTheme.of(context)
                                                              .secondaryText,
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
                                            ].divide(const SizedBox(height: 4)),
                                          ),
                                        ),
                                      ].divide(const SizedBox(width: 16)),
                                    ),
                                  ),
                                ),
                              ].divide(const SizedBox(height: 15)),
                            ),
                          ].divide(const SizedBox(height: 24)),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0x2D368EFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.info_rounded,
                                  color: AppTheme.of(context).primary,
                                  size: 20,
                                ),
                                Expanded(
                                  child: Text(
                                    'This process typically takes 2-3 minutes. Your information is encrypted and secure.',
                                    style: AppTheme.of(context)
                                        .bodySmall
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: AppTheme.of(context)
                                                .bodySmall
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .bodySmall
                                                .fontStyle,
                                          ),
                                          color: AppTheme.of(context).primary,
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
                              ].divide(const SizedBox(width: 12)),
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(height: 20)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        await context.pushNamed(DocumentScanWidget.routeName);
                      },
                      text: 'Start Document Scan',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 52,
                        padding: const EdgeInsets.all(8),
                        iconPadding:
                            EdgeInsetsDirectional.zero,
                        color: AppTheme.of(context).primary,
                        textStyle: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontStyle:
                                    AppTheme.of(context).titleSmall.fontStyle,
                              ),
                              color: Colors.white,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              fontStyle:
                                  AppTheme.of(context).titleSmall.fontStyle,
                            ),
                        elevation: 0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(12),
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
