import 'package:flutter/material.dart';

import '/services/dispatch/dispatch_service.dart';
import '/theme/app_theme.dart';

class ProviderBidsPage extends StatefulWidget {
  const ProviderBidsPage({super.key});

  static String routeName = 'ProviderBids';
  static String routePath = '/provider-bids';

  @override
  State<ProviderBidsPage> createState() => _ProviderBidsPageState();
}

class _ProviderBidsPageState extends State<ProviderBidsPage> {
  List<Map<String, dynamic>> _bids = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBids();
  }

  Future<void> _loadBids() async {
    setState(() => _isLoading = true);
    try {
      final bids = await _getProviderBids();
      if (mounted) {
        setState(() {
          _bids = bids;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bids: $e')),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getProviderBids() async =>
      DispatchService.instance.getProviderBids();

  Future<void> _withdrawBid(String jobId) async {
    final success = await DispatchService.instance.rejectOffer(jobId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid withdrawn')),
      );
      await _loadBids();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to withdraw bid')),
      );
    }
  }

  Color _statusColor(String status, AppThemeData theme) {
    switch (status) {
      case 'pending':
        return theme.warning;
      case 'selected':
        return theme.success;
      case 'rejected':
      case 'withdrawn':
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('My Bids',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bids.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadBids,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: _bids.length,
                    itemBuilder: (context, index) =>
                        _buildBidCard(theme, _bids[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(AppThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel_outlined, size: 64, color: theme.secondaryText),
            const SizedBox(height: 16),
            Text('No active bids',
                style: theme.bodyMedium.override(color: theme.secondaryText)),
            const SizedBox(height: 8),
            Text('Bid on on-demand jobs to see them here',
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
        ),
      );

  Widget _buildBidCard(AppThemeData theme, Map<String, dynamic> bid) {
    final status = bid['status'] as String? ?? 'pending';
    final jobId = bid['job_id']?.toString() ?? '';
    final amount = double.tryParse(bid['amount']?.toString() ?? '0') ?? 0;
    final description = bid['description'] as String? ?? '';
    final clientName = bid['client_name'] as String? ?? 'Client';
    final createdAt = bid['created_at'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(clientName,
                    style:
                        theme.titleSmall.override(fontWeight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status, theme).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: theme.labelSmall.override(
                    color: _statusColor(status, theme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description,
                style: theme.bodyMedium.override(color: theme.secondaryText)),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PHP ${amount.toStringAsFixed(2)}',
                  style:
                      theme.titleMedium.override(fontWeight: FontWeight.w700)),
              if (status == 'pending')
                TextButton(
                  onPressed: () => _withdrawBid(jobId),
                  style: TextButton.styleFrom(foregroundColor: theme.error),
                  child: const Text('Withdraw'),
                ),
            ],
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 4),
            Text('Bid placed: $createdAt',
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
        ],
      ),
    );
  }
}
