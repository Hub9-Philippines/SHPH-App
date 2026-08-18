import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/screen_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/auth_service.dart';
import '/services/kyc_hub_service.dart';
import '/services/kyc_submission_service.dart';
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

  String? _rejectionReason;

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
      final statusResp = await KycHubService.instance.getStatus(force: true);
      final status = KycHubService.normalizeStatus(
        statusResp['status'] ?? statusResp['verification_status'],
      );

      if (status == 'approved' && mounted) {
        // Stop checking
        _statusCheckTimer?.cancel();
        // Refresh the session user so the router guard sees the approved KYC.
        await AuthService.instance.refreshCurrentUser();
        if (!mounted) return;
        // Redirect to Pro Dashboard
        context.goNamed(ProDashboardWidget.routeName);
        return;
      }

      if (status == 'rejected' && mounted) {
        setState(() {
          _rejectionReason = statusResp['rejection_reason']?.toString();
        });
      }
    } catch (e) {
      // Ignore errors, will retry on next check
    }
  }

  void _goBackToKyc() {
    _kycReset();
    context.goNamed(EKYCBeginWidget.routeName);
  }

  void _kycReset() {
    KycSubmissionService.instance.reset();
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
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ScreenHeader(
                    title: 'Verification In Progress',
                    action: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        context.pushNamed(EditProfileWidget.routeName);
                      },
                      tooltip: 'Edit Profile',
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  Padding(
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
                                                  font: GoogleFonts.plusJakartaSans(
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
                              font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold),
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
                        child: Text(
                          _rejectionReason != null
                              ? 'Your verification was rejected. Please review the reason below and resubmit.'
                              : 'Your documents have been submitted for review. Our team will verify your information within 24-48 hours. You will receive a notification once your account is approved.',
                          textAlign: TextAlign.center,
                          style: AppTheme.of(context).bodyMedium.override(
                                color: AppTheme.of(context).secondaryText,
                              ),
                        ),
                      ),
                      if (_rejectionReason != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)
                                .error
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.of(context).error,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rejection Reason',
                                style: AppTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      color: AppTheme.of(context).error,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _rejectionReason!,
                                style: AppTheme.of(context).bodySmall.override(
                                      color: AppTheme.of(context).primaryText,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _goBackToKyc,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Resubmit Verification'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppTheme.of(context).primary,
                                foregroundColor:
                                    AppTheme.of(context).onPrimary,
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
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
                                      color: AppTheme.of(context).onPrimary,
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
                        onTap: () {
                          // TODO: Navigate to support or open email
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
              ],
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
