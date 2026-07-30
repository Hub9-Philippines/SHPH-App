import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/screen_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'i_d_verify_model.dart';

export 'i_d_verify_model.dart';

class IDVerifyWidget extends StatefulWidget {
  const IDVerifyWidget({super.key});

  static String routeName = 'IDVerify';
  static String routePath = '/iDVerify';

  @override
  State<IDVerifyWidget> createState() => _IDVerifyWidgetState();
}

class _IDVerifyWidgetState extends State<IDVerifyWidget> {
  late IDVerifyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, IDVerifyModel.new);
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  ScreenHeader(
                    title: 'eKYC Verification',
                    padding: const EdgeInsets.only(bottom: 24),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.of(context)
                              .primary
                              .withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.center,
                          child: Icon(
                            Icons.verified_user_outlined,
                            color: AppTheme.of(context).primary,
                            size: 64,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Identity Verification',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: AppTheme.of(context).primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We need to verify your identity to comply with regulatory requirements and ensure account security.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.of(context).secondaryText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Required Documents',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.of(context).primaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.of(context).alternate,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)
                                .primary
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.credit_card,
                            color: AppTheme.of(context).primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Government ID',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppTheme.of(context).primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Driver\'s license, passport, national ID card, NBI Clearance or Police Clearance',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.of(context).secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).accent3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.of(context).tertiary,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.of(context).tertiary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Important Information',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppTheme.of(context).tertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'â€¢ Ensure your document is clear and well-lit\nâ€¢ All corners of the document should be visible\nâ€¢ Remove any covers or cases from your ID\nâ€¢ Process typically takes 2-3 minutes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.of(context).primaryText,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FFButtonWidget(
                    onPressed: () async {
                      await context.pushNamed(DocumentScanWidget.routeName);
                    },
                    text: 'Start Document Scanner',
                    icon: const Icon(
                      Icons.document_scanner,
                      size: 24,
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56,
                      color: AppTheme.of(context).primary,
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      elevation: 0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FFButtonWidget(
                    onPressed: () async {
                      context.goNamed(HomeWidget.routeName);
                    },
                    text: 'I\'ll do this later',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48,
                      color: Colors.transparent,
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      elevation: 0,
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
      );
}
