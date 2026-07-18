import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/profiles_service.dart';
import '/services/verification_timer_service.dart';
import '/theme/app_theme.dart';
import 'verification_reviewing_model.dart';

export 'verification_reviewing_model.dart';

class VerificationReviewingWidget extends StatefulWidget {
  const VerificationReviewingWidget({super.key});

  static String routeName = 'VerificationReviewing';
  static String routePath = '/pro-verification-progress';

  @override
  State<VerificationReviewingWidget> createState() =>
      _VerificationReviewingWidgetState();
}

class _VerificationReviewingWidgetState
    extends State<VerificationReviewingWidget> {
  late VerificationReviewingModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Use persistent timer service for navigation-safe countdown
  final _timerService = VerificationTimerService.instance;

  // Timer for periodic status checks
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, VerificationReviewingModel.new);
    // Start checking verification status periodically
    _startStatusCheck();
  }

  /// Start periodic status check every 10 seconds
  void _startStatusCheck() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkVerificationStatus();
    });
    // Check immediately on load
    _checkVerificationStatus();
  }

  /// Check if user is verified and redirect if so
  Future<void> _checkVerificationStatus() async {
    try {
      final statusResp = await ProfilesService.instance.getKycStatus();
      final status = statusResp?['verification_status'] as String?;

      if (status == 'verified' && mounted) {
        // Stop checking
        _statusCheckTimer?.cancel();
        // Redirect to Pro Dashboard
        context.goNamed(ProDashboardWidget.routeName);
      }
    } catch (e) {
      // Ignore errors, will retry on next check
    }
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
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
            title: Text(
              'Verification In Progress',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.pushNamed(EditProfileWidget.routeName);
                },
                tooltip: 'Edit Profile',
              ),
            ],
          ),
          body: SafeArea(
            top: true,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Countdown Timer with Progress
                      StreamBuilder<int>(
                        stream: _timerService.timerStream,
                        initialData: _timerService.remainingSeconds,
                        builder: (context, snapshot) {
                          final remainingSeconds =
                              snapshot.data ?? _timerService.remainingSeconds;
                          return Column(
                            children: [
                              // Progress Ring with timer in center
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Progress ring (background shows remaining, valueColor shows progress)
                                    SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: CircularProgressIndicator(
                                        value: remainingSeconds / (30 * 60),
                                        strokeWidth: 12,
                                        backgroundColor: AppTheme.of(context)
                                            .primaryText
                                            .withValues(alpha: 0.1),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                    // Timer text (smaller than ring so ring is visible around it)
                                    Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        color: AppTheme.of(context)
                                            .primaryBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            VerificationTimerService.formatTime(
                                                remainingSeconds),
                                            style: AppTheme.of(context)
                                                .headlineMedium
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                          ),
                                          Text(
                                            'remaining',
                                            style: AppTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  color: AppTheme.of(context)
                                                      .secondaryText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Estimated Review Time: 30 minutes',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        'Verification Submitted',
                        style: AppTheme.of(context).headlineMedium.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
                        child: Text(
                          'Your documents have been submitted for review. Our team will verify your information within 24-48 hours. You will receive a notification once your account is approved.',
                          textAlign: TextAlign.center,
                          style: AppTheme.of(context).bodyMedium.override(
                                color: AppTheme.of(context).secondaryText,
                              ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Info Cards
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _buildInfoCard(
                              context,
                              Icons.description_outlined,
                              'Document Upload',
                              'Your government ID has been uploaded successfully.',
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              context,
                              Icons.face_outlined,
                              'Face Scan',
                              'Your biometric selfie has been captured.',
                            ),
                            const SizedBox(height: 16),
                            _buildInfoCard(
                              context,
                              Icons.schedule_outlined,
                              'Review Timeline',
                              '24-48 hours for verification.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Back to Home Button
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              context.go('/');
                            },
                            child: Center(
                              child: Text(
                                'Back to Home',
                                style: AppTheme.of(context).titleSmall.override(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Contact Support
                      InkWell(
                        onTap: () async {
                          await launchURL(
                            'mailto:support@serbisyohubph.com?subject=Verification%20Support',
                          );
                        },
                        child: Text(
                          'Need help? Contact Support',
                          style: AppTheme.of(context).bodyMedium.override(
                                color: AppTheme.of(context).primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.of(context).primaryText.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.of(context).primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.of(context).bodyLarge.override(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTheme.of(context).bodySmall.override(
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
