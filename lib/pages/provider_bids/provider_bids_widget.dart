import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';
import 'provider_bids_model.dart';

export 'provider_bids_model.dart';

class ProviderBidsWidget extends StatefulWidget {
  const ProviderBidsWidget({super.key});

  static String routeName = 'ProviderBids';
  static String routePath = '/provider-bids';

  @override
  State<ProviderBidsWidget> createState() => _ProviderBidsWidgetState();
}

class _ProviderBidsWidgetState extends State<ProviderBidsWidget> {
  late ProviderBidsModel _model;
  bool _withdrawing = false;

  @override
  void initState() {
    super.initState();
    _model = ProviderBidsModel();
    _model.loadBids().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('My Bids', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.bids.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: () async {
                    await _model.loadBids();
                    safeSetState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _model.bids.length,
                    itemBuilder: (context, index) =>
                        _buildBidCard(context, _model.bids[index], theme),
                  ),
                ),
    );
  }

  Widget _buildEmpty(AppThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_rounded,
                size: 64, color: theme.textTertiary),
            const SizedBox(height: 16),
            Text('No bids yet',
                style: GoogleFonts.plusJakartaSans(
                    color: theme.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('When you place bids on job requests, they will appear here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    color: theme.secondaryText, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildBidCard(
      BuildContext context, Map<String, dynamic> bid, AppThemeData theme) {
    final status = bid['status']?.toString() ?? 'pending';
    final price = (bid['total_price'] as num?)?.toDouble() ?? 0.0;
    final category = bid['category_name']?.toString() ??
        bid['category']?.toString() ??
        'General';
    final description = bid['description']?.toString() ?? '';
    final distance = bid['distance_km']?.toString();
    final eta = bid['eta_minutes']?.toString();
    final bidId = bid['id']?.toString() ?? '';
    final isPending = status == 'pending';

    final statusColor = switch (status) {
      'pending' => theme.warning,
      'accepted' => theme.success,
      'rejected' => theme.error,
      'withdrawn' => theme.textTertiary,
      _ => theme.secondaryText,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status[0].toUpperCase() + status.substring(1),
                      style: GoogleFonts.plusJakartaSans(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                Text(category,
                    style: GoogleFonts.plusJakartaSans(
                        color: theme.secondaryText, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text('â‚±${price.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                    color: theme.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                      color: theme.primaryText, fontSize: 13)),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (distance != null) ...[
                  Icon(Icons.near_me_rounded,
                      size: 14, color: theme.textTertiary),
                  const SizedBox(width: 4),
                  Text('$distance km',
                      style: GoogleFonts.plusJakartaSans(
                          color: theme.textTertiary, fontSize: 11)),
                  const SizedBox(width: 12),
                ],
                if (eta != null) ...[
                  Icon(Icons.timer_rounded,
                      size: 14, color: theme.textTertiary),
                  const SizedBox(width: 4),
                  Text('$eta min',
                      style: GoogleFonts.plusJakartaSans(
                          color: theme.textTertiary, fontSize: 11)),
                ],
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: _withdrawing
                      ? null
                      : () => _withdrawBid(bidId),
                  icon: _withdrawing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.cancel_outlined,
                          size: 16, color: theme.error),
                  label: Text('Withdraw',
                      style: GoogleFonts.plusJakartaSans(
                          color: theme.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.error.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _withdrawBid(String bidId) async {
    _withdrawing = true;
    safeSetState(() {});
    await _model.withdrawBid(bidId);
    _withdrawing = false;
    safeSetState(() {});
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }
}
