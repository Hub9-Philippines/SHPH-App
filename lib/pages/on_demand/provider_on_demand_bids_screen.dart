import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/models/on_demand_bid.dart';
import '/api/models/on_demand_job.dart';
import '/services/logging_service.dart';
import '/services/on_demand_service.dart';
import '/theme/app_theme.dart';

/// Provider screen to browse nearby pending on-demand jobs and manage bids.
///
/// Mirrors the web `ProviderBidsPage.vue`.
class ProviderOnDemandBidsScreen extends StatefulWidget {
  const ProviderOnDemandBidsScreen({super.key});

  static const String routeName = 'ProviderOnDemandBids';
  static const String routePath = '/on-demand/provider-bids';

  @override
  State<ProviderOnDemandBidsScreen> createState() =>
      _ProviderOnDemandBidsScreenState();
}

class _ProviderOnDemandBidsScreenState
    extends State<ProviderOnDemandBidsScreen> {
  bool _loadingPending = true;
  List<ShphOnDemandJob> _pendingJobs = [];

  bool _loadingMyBids = true;
  List<ShphOnDemandBid> _myBids = [];

  bool _bidding = false;
  int? _biddingJobId;

  @override
  void initState() {
    super.initState();
    _loadPendingJobs();
    _loadMyBids();
  }

  Future<void> _loadPendingJobs() async {
    setState(() => _loadingPending = true);
    try {
      final jobs = await OnDemandService.instance.listPendingJobs();
      setState(() {
        _pendingJobs = jobs;
        _loadingPending = false;
      });
    } catch (e) {
      LoggingService.error('Failed to load pending jobs: $e',
          tag: 'ProviderOnDemandBids');
      setState(() => _loadingPending = false);
    }
  }

  Future<void> _loadMyBids() async {
    setState(() => _loadingMyBids = true);
    try {
      final bids = await OnDemandService.instance.listProviderBids();
      setState(() {
        _myBids = bids;
        _loadingMyBids = false;
      });
    } catch (e) {
      LoggingService.error('Failed to load provider bids: $e',
          tag: 'ProviderOnDemandBids');
      setState(() => _loadingMyBids = false);
    }
  }

  Future<void> _acceptJob(ShphOnDemandJob job) async {
    setState(() {
      _bidding = true;
      _biddingJobId = job.id;
    });
    try {
      final result = await OnDemandService.instance.acceptJob(job.id);
      if (result != null) {
        _showMessage('Bid submitted successfully');
        await Future.wait([_loadPendingJobs(), _loadMyBids()]);
      } else {
        _showMessage('Failed to submit bid.');
      }
    } catch (e) {
      LoggingService.error('Bid failed: $e', tag: 'ProviderOnDemandBids');
      _showMessage('Failed to submit bid.');
    } finally {
      setState(() {
        _bidding = false;
        _biddingJobId = null;
      });
    }
  }

  Future<void> _withdrawBid(ShphOnDemandBid bid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw bid?'),
        content: const Text(
            'The client will no longer see your bid.'),
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

    try {
      final result =
          await OnDemandService.instance.withdrawBid(bid.job, bid.id);
      if (result != null) {
        _showMessage('Bid withdrawn');
        await _loadMyBids();
      } else {
        _showMessage('Failed to withdraw bid.');
      }
    } catch (e) {
      LoggingService.error('Withdraw failed: $e',
          tag: 'ProviderOnDemandBids');
      _showMessage('Failed to withdraw bid.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primaryBackground,
          elevation: 0,
          title: Text(
            'On-Demand Bids',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.primaryText),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            labelColor: theme.primary,
            unselectedLabelColor: theme.secondaryText,
            indicatorColor: theme.primary,
            tabs: const [
              Tab(text: 'Available Jobs'),
              Tab(text: 'My Bids'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: theme.primaryText),
              onPressed: () async {
                await _loadPendingJobs();
                await _loadMyBids();
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildPendingJobsTab(theme),
            _buildMyBidsTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingJobsTab(AppThemeData theme) {
    if (_loadingPending) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pendingJobs.isEmpty) {
      return Center(
        child: Text(
          'No nearby jobs right now',
          style: GoogleFonts.poppins(color: theme.secondaryText),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPendingJobs,
      child: ListView.builder(
        itemCount: _pendingJobs.length,
        itemBuilder: (context, index) {
          final job = _pendingJobs[index];
          return _PendingJobCard(
            job: job,
            bidding: _bidding && _biddingJobId == job.id,
            onBid: () => _acceptJob(job),
          );
        },
      ),
    );
  }

  Widget _buildMyBidsTab(AppThemeData theme) {
    if (_loadingMyBids) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_myBids.isEmpty) {
      return Center(
        child: Text(
          'You have not submitted any bids yet',
          style: GoogleFonts.poppins(color: theme.secondaryText),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadMyBids,
      child: ListView.builder(
        itemCount: _myBids.length,
        itemBuilder: (context, index) {
          final bid = _myBids[index];
          return _MyBidCard(
            bid: bid,
            onWithdraw: () => _withdrawBid(bid),
          );
        },
      ),
    );
  }
}

class _PendingJobCard extends StatelessWidget {
  const _PendingJobCard({
    required this.job,
    required this.bidding,
    required this.onBid,
  });

  final ShphOnDemandJob job;
  final bool bidding;
  final VoidCallback onBid;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.categoryName ?? 'On-Demand Job',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job.description ?? 'No description',
              style: GoogleFonts.poppins(color: theme.secondaryText),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: theme.primary),
                const SizedBox(width: 4),
                Text(
                  '${job.clientLat?.toStringAsFixed(3)}, ${job.clientLng?.toStringAsFixed(3)}',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: theme.secondaryText),
                ),
                const Spacer(),
                if (job.estimatedFeeMin != null && job.estimatedFeeMax != null)
                  Text(
                    '₱${job.estimatedFeeMin!.toStringAsFixed(0)} - ₱${job.estimatedFeeMax!.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: theme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bidding ? null : onBid,
                child: bidding
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Submit bid',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyBidCard extends StatelessWidget {
  const _MyBidCard({
    required this.bid,
    required this.onWithdraw,
  });

  final ShphOnDemandBid bid;
  final VoidCallback onWithdraw;

  Color _statusColor(AppThemeData theme) {
    switch (bid.status) {
      case ShphOnDemandBidStatus.selected:
        return theme.success;
      case ShphOnDemandBidStatus.rejected:
      case ShphOnDemandBidStatus.expired:
        return theme.error;
      case ShphOnDemandBidStatus.pending:
        return theme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bid.listing?.title ?? 'On-Demand Bid',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(theme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bid.status.name[0].toUpperCase() +
                        bid.status.name.substring(1),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _statusColor(theme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ₱${bid.totalPrice?.toStringAsFixed(2) ?? '-'}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.primary,
              ),
            ),
            if (bid.distanceKm != null)
              Text(
                '${bid.distanceKm!.toStringAsFixed(1)} km away',
                style: GoogleFonts.poppins(color: theme.secondaryText),
              ),
            if (bid.etaMinutes != null)
              Text(
                'ETA: ${bid.etaMinutes} min',
                style: GoogleFonts.poppins(color: theme.secondaryText),
              ),
            if (bid.status == ShphOnDemandBidStatus.pending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onWithdraw,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.error,
                  ),
                  child: Text(
                    'Withdraw bid',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
