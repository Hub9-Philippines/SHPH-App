import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'kyc_hub_model.dart';

export 'kyc_hub_model.dart';

class KycHubWidget extends StatefulWidget {
  const KycHubWidget({super.key});

  static String routeName = 'KycHub';
  static String routePath = '/kyc';

  @override
  State<KycHubWidget> createState() => _KycHubWidgetState();
}

class _KycHubWidgetState extends State<KycHubWidget> {
  late KycHubModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, KycHubModel.new);
    _model.loadStatus().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final kycStatus = _model.status['status']?.toString() ?? 'not_started';
    final isVerified = kycStatus == 'approved';
    final isRejected = kycStatus == 'rejected';
    final isPending = kycStatus == 'pending' || kycStatus == 'under_review';

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Verification', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.border, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isVerified
                            ? Icons.verified
                            : isRejected
                                ? Icons.cancel
                                : isPending
                                    ? Icons.hourglass_bottom
                                    : Icons.shield,
                        size: 64,
                        color: isVerified
                            ? theme.success
                            : isRejected
                                ? theme.error
                                : theme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isVerified
                            ? "You're Verified!"
                            : isRejected
                                ? 'Verification Rejected'
                                : isPending
                                    ? 'Under Review'
                                    : 'Verify Your Identity',
                        style: theme.titleLarge,
                      ),
                      if (isRejected && _model.status['rejection_reason'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _model.status['rejection_reason'].toString(),
                          style: theme.bodyMedium?.copyWith(color: theme.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (isVerified)
                        ElevatedButton(
                          onPressed: () => context.go('/'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                          ),
                          child: const Text('Continue'),
                        ),
                      if (isPending)
                        Text('We\'re reviewing your documents. This usually takes 1-2 business days.',
                            style: theme.bodySmall?.copyWith(color: theme.secondaryText),
                            textAlign: TextAlign.center),
                    ],
                  ),
                ),
                if (!isVerified && !isPending) ...[
                  const SizedBox(height: 24),
                  Text('Steps', style: theme.titleSmall),
                  const SizedBox(height: 12),
                  _buildStep(theme, 'Liveness Check', 'Face verification selfie',
                      Icons.face, true, () => context.go('/face-verification')),
                  const SizedBox(height: 8),
                  _buildStep(theme, 'Government ID', 'Upload valid ID',
                      Icons.badge, true, () => context.go('/document-scan')),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/eKYCBegin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Start Verification'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('I\'ll do this later'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildStep(AppThemeData theme, String title, String subtitle,
      IconData icon, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: theme.bodySmall?.copyWith(color: theme.secondaryText)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.secondaryText),
          ],
        ),
      ),
    );
  }
}
