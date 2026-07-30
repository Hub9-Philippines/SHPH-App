import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/screen_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'e_k_y_c_begin_model.dart';

export 'e_k_y_c_begin_model.dart';

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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  ScreenHeader(
                    title: 'Provider Verification',
                    padding: const EdgeInsets.only(bottom: 24),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.of(context)
                              .primary
                              .withValues(alpha: 0.19),
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
                      const SizedBox(height: 16),
                      Text(
                        'Complete Your Verification',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: AppTheme.of(context).primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'To become a verified provider and start accepting bookings, we need to verify your identity with a valid government ID and a face scan. This ensures trust and safety for all users.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.of(context).secondaryText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'What you\'ll need:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppTheme.of(context).primaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRequirementCard(
                        icon: Icons.face_rounded,
                        title: 'Face Verification',
                        subtitle: 'Take a selfie to verify your identity',
                        bgColor: AppTheme.of(context).accent2,
                      ),
                      const SizedBox(height: 12),
                      _buildRequirementCard(
                        icon: Icons.credit_card_rounded,
                        title: 'Government ID',
                        subtitle:
                            'Scan your driver\'s license, passport, or national ID',
                        bgColor: AppTheme.of(context).accent3,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context)
                              .primary
                              .withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: AppTheme.of(context).primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This process typically takes 2-3 minutes. Your information is encrypted and secure.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.of(context).primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  FFButtonWidget(
                    onPressed: () async {
                      await context.pushNamed(DocumentScanWidget.routeName);
                    },
                    text: 'Start Document Scan',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 52,
                      color: AppTheme.of(context).primary,
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
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

  Widget _buildRequirementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
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
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.of(context).primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.of(context).primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
      );
}
