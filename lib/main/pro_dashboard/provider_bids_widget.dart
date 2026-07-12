import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/services/logging_service.dart';
import '/services/provider_bids_service.dart';
import '/theme/app_theme.dart';

class ProviderBidsWidget extends StatefulWidget {
  const ProviderBidsWidget({super.key});

  static String routeName = 'ProviderBids';
  static String routePath = '/provider-bids';

  @override
  State<ProviderBidsWidget> createState() => _ProviderBidsWidgetState();
}

class _ProviderBidsWidgetState extends State<ProviderBidsWidget> {
  List<Map<String, dynamic>> _bids = [];
  bool _isLoading = true;
  final _service = ProviderBidsService.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      _bids = await _service.getProviderBids();
    } catch (e) {
      LoggingService.error('Bids load error: $e', tag: 'ProviderBids');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _withdraw(String offerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Bid?'),
        content: const Text(
            'Are you sure you want to withdraw this bid? The client will no longer see you as a candidate.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await _service.withdrawBid(offerId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid withdrawn successfully')),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to withdraw bid')),
      );
    }
  }

  String _clientName(Map<String, dynamic> bid) {
    final job = bid['job_requests'] as Map<String, dynamic>?;
    final profile = job?['profiles'] as Map<String, dynamic>?;
    return profile?['display_name'] ??
        profile?['first_name'] ??
        'Unknown Client';
  }

  String _serviceType(Map<String, dynamic> bid) {
    final job = bid['job_requests'] as Map<String, dynamic>?;
    return job?['service_type'] as String? ?? 'Unknown Service';
  }

  String _jobStatus(Map<String, dynamic> bid) {
    final job = bid['job_requests'] as Map<String, dynamic>?;
    return job?['status'] as String? ?? 'unknown';
  }

  String _bidStatus(Map<String, dynamic> bid) =>
      bid['status'] as String? ?? 'pending';

  DateTime? _offeredAt(Map<String, dynamic> bid) {
    final raw = bid['offered_at'] as String?;
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Color _statusColor(String status) {
    return switch (status) {
      'pending' => const Color(0xFFD97706),
      'accepted' => const Color(0xFF059669),
      'rejected' => const Color(0xFFDC2626),
      'timed_out' => const Color(0xFF6B7280),
      _ => const Color(0xFF6B7280),
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'pending' => 'Pending',
      'accepted' => 'Accepted',
      'rejected' => 'Withdrawn',
      'timed_out' => 'Timed Out',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Bids', style: theme.titleMedium),
            Text(
              'On-demand job offers & history',
              style: theme.bodySmall.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bids.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: _bids.length,
                    itemBuilder: (context, index) {
                      final bid = _bids[index];
                      return _buildBidCard(context, bid);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gavel_outlined, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              'No Bids Yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you receive on-demand job offers, they will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidCard(BuildContext context, Map<String, dynamic> bid) {
    final status = _bidStatus(bid);
    final jobStatus = _jobStatus(bid);
    final offeredAt = _offeredAt(bid);
    final canWithdraw = status == 'pending' && jobStatus == 'offered';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.work_outline_rounded,
                  size: 20,
                  color: _statusColor(status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _serviceType(bid),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _clientName(bid),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(status),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 14, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                offeredAt != null
                    ? '${offeredAt.month}/${offeredAt.day}/${offeredAt.year} ${offeredAt.hour}:${offeredAt.minute.toString().padLeft(2, '0')}'
                    : 'Unknown time',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const Spacer(),
              if (canWithdraw)
                TextButton.icon(
                  onPressed: () => _withdraw(bid['id'] as String),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Withdraw'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
