import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/auth_service.dart';
import '/services/kyc_hub_service.dart';
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

  String get _kycStatus => KycHubService.normalizeStatus(
        _model.status['status'] ?? _model.status['verification_status'],
      );

  bool get _isVerified => _kycStatus == 'approved';
  bool get _isRejected => _kycStatus == 'rejected';
  bool get _isPending => _kycStatus == 'pending';

  Future<void> _skipKyc() async {
    final skipped = await KycHubService.instance.skipKyc();
    if (!mounted) return;
    if (skipped) {
      await AuthService.instance.refreshCurrentUser();
      if (!mounted) return;
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not skip verification. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

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
                        _isVerified
                            ? Icons.verified
                            : _isRejected
                                ? Icons.cancel
                                : _isPending
                                    ? Icons.hourglass_bottom
                                    : Icons.shield,
                        size: 64,
                        color: _isVerified
                            ? theme.success
                            : _isRejected
                                ? theme.error
                                : theme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isVerified
                            ? "You're Verified!"
                            : _isRejected
                                ? 'Verification Rejected'
                                : _isPending
                                    ? 'Under Review'
                                    : 'Verify Your Identity',
                        style: theme.titleLarge,
                      ),
                      if (_isRejected &&
                          _model.status['rejection_reason'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _model.status['rejection_reason'].toString(),
                          style: theme.bodyMedium?.copyWith(color: theme.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (_isVerified)
                        ElevatedButton(
                          onPressed: () => context.go('/'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                          ),
                          child: const Text('Continue'),
                        ),
                      if (_isPending)
                        Text(
                          'We\'re reviewing your documents. This usually takes 1-2 business days.',
                          style: theme.bodySmall?.copyWith(
                              color: theme.secondaryText),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                if (!_isVerified && !_isPending) ...[
                  const SizedBox(height: 24),
                  Text('Steps', style: theme.titleSmall),
                  const SizedBox(height: 12),
                  _buildStep(
                    theme,
                    'Liveness Check',
                    'Face verification selfie',
                    Icons.face,
                    true,
                    () => context.go('/face-verification'),
                  ),
                  const SizedBox(height: 8),
                  _buildStep(
                    theme,
                    'Government ID',
                    'Upload valid ID front and back',
                    Icons.badge,
                    true,
                    () => context.pushNamed(DocumentScanWidget.routeName),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.pushNamed(
                        DocumentScanWidget.routeName,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Start Verification'),
                    ),
                  ),
                  if (!_isRejected) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _skipKyc,
                        child: const Text('I\'ll do this later'),
                      ),
                    ),
                  ],
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
              width: 44,
              height: 44,
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
                  Text(title,
                      style: theme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: theme.bodySmall
                          ?.copyWith(color: theme.secondaryText)),
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
