import 'package:flutter/material.dart';

import '/api/resources/admin_api.dart';
import '/theme/app_theme.dart';

class AdminKycDetailPage extends StatefulWidget {
  const AdminKycDetailPage({
    required this.submissionId,
    super.key,
  });

  final int submissionId;

  static String routeName = 'AdminKycDetail';
  static String routePath = '/admin-kyc/:id';

  @override
  State<AdminKycDetailPage> createState() => _AdminKycDetailPageState();
}

class _AdminKycDetailPageState extends State<AdminKycDetailPage> {
  Map<String, dynamic>? _submission;
  bool _isLoading = true;
  String? _fetchError;
  String? _actionLoading;
  bool _rejectOpen = false;
  final _rejectController = TextEditingController();
  String? _previewUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _rejectController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _fetchError = null;
    });
    try {
      final all = await ShphAdminApi.instance.listKyc();
      final found = all.where((s) {
        final id = s['id'];
        if (id is int) return id == widget.submissionId;
        return int.tryParse(id?.toString() ?? '') == widget.submissionId;
      }).toList();
      if (mounted) {
        setState(() {
          _submission = found.isNotEmpty ? found.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fetchError = 'Failed to load submission: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approve() async {
    if (_submission == null) return;
    setState(() => _actionLoading = 'approve');
    try {
      await ShphAdminApi.instance.approveKyc(widget.submissionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC approved!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = null);
    }
  }

  Future<void> _reject() async {
    if (_submission == null) return;
    final reason = _rejectController.text.trim();
    if (reason.isEmpty) return;
    setState(() => _actionLoading = 'reject');
    try {
      await ShphAdminApi.instance.rejectKyc(widget.submissionId, reason);
      if (mounted) {
        setState(() => _rejectOpen = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC rejected')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = null);
    }
  }

  Color _statusColor(String status, AppThemeData theme) {
    switch (status) {
      case 'approved':
        return theme.success;
      case 'rejected':
        return theme.error;
      default:
        return theme.warning;
    }
  }

  Widget _buildDocCard(String label, String? url, AppThemeData theme) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              label.toUpperCase(),
              style: theme.labelSmall.override(
                color: theme.secondaryText,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _previewUrl = url),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                color: theme.secondaryBackground,
                child: Icon(Icons.broken_image, color: theme.secondaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('KYC Review'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _submission != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (_submission!['user_name'] as String?) ??
                            (_submission!['user_email'] as String?) ??
                            'Unknown',
                        style: theme.titleLarge.override(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_submission!['user_email'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _submission!['user_email'] as String,
                          style: theme.bodySmall
                              .override(color: theme.secondaryText),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Submitted: ${_submission!['created_at'] ?? '—'}',
                        style: theme.bodySmall
                            .override(color: theme.secondaryText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID Type: ${_submission!['id_type'] ?? 'N/A'}',
                        style: theme.bodySmall
                            .override(color: theme.secondaryText),
                      ),
                      if (_submission!['liveness_score'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Liveness Score: ${_submission!['liveness_score']}',
                          style: theme.bodySmall
                              .override(color: theme.secondaryText),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                  _submission!['status'] as String? ??
                                      'pending',
                                  theme),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (_submission!['status'] as String?)
                                      ?.toUpperCase() ??
                                  'PENDING',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.secondaryBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_submission!['submitter_role'] ?? 'provider'} KYC',
                              style: TextStyle(
                                color: theme.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDocCard(
                          'ID Front', _submission!['id_front_url'], theme),
                      _buildDocCard(
                          'ID Back', _submission!['id_back_url'], theme),
                      _buildDocCard('Selfie', _submission!['selfie_url'], theme),
                      _buildDocCard('NBI / Police Clearance',
                          _submission!['nbi_clearance_url'], theme),
                      _buildDocCard(
                          'Portfolio', _submission!['portfolio_url'], theme),
                      _buildDocCard(
                          'Resume', _submission!['resume_url'], theme),
                      if (_submission!['rejection_reason'] != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Rejection Reason: ${_submission!['rejection_reason']}',
                            style: TextStyle(color: theme.error),
                          ),
                        ),
                      ],
                      if (_submission!['status'] == 'pending') ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _actionLoading != null ? null : _approve,
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.success,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: _actionLoading == 'approve'
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Text('Approve'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _actionLoading != null
                                ? null
                                : () => setState(() => _rejectOpen = true),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : _fetchError != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_fetchError!,
                              style: theme.bodyMedium
                                  .override(color: theme.error)),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : const Center(child: Text('Submission not found.')),
      bottomSheet: _rejectOpen
          ? Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reject KYC',
                          style: theme.titleMedium
                              .override(fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () => setState(() => _rejectOpen = false),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _rejectController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Rejection Reason',
                      hintText: 'Explain why this submission is rejected...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _rejectController.text.trim().isEmpty ||
                              _actionLoading != null
                          ? null
                          : _reject,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _actionLoading == 'reject'
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Confirm Rejection'),
                    ),
                  ),
                ],
              ),
            )
          : null,
      // Image preview overlay
      floatingActionButton: _previewUrl != null
          ? FloatingActionButton(
              onPressed: () => setState(() => _previewUrl = null),
              child: const Icon(Icons.close),
            )
          : null,
    );
  }
}
