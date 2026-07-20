import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/models/on_demand_bid.dart';
import '/api/models/on_demand_job.dart';
import '/services/logging_service.dart';
import '/services/on_demand_service.dart';
import '/theme/app_theme.dart';

/// Client screen to list their on-demand jobs and view/select bids.
///
/// Mirrors the web `ClientOnDemandJobsPage.vue`.
class ClientOnDemandJobsScreen extends StatefulWidget {
  const ClientOnDemandJobsScreen({super.key});

  static const String routeName = 'ClientOnDemandJobs';
  static const String routePath = '/on-demand/client-jobs';

  @override
  State<ClientOnDemandJobsScreen> createState() =>
      _ClientOnDemandJobsScreenState();
}

class _ClientOnDemandJobsScreenState extends State<ClientOnDemandJobsScreen> {
  bool _loading = true;
  List<ShphOnDemandJob> _jobs = [];
  ShphOnDemandJob? _selectedJob;
  List<ShphOnDemandBid> _bids = [];
  bool _loadingBids = false;
  bool _selecting = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _loading = true);
    try {
      final jobs = await OnDemandService.instance.listClientJobs();
      setState(() {
        _jobs = jobs;
        _loading = false;
      });
    } catch (e) {
      LoggingService.error('Failed to load client jobs: $e',
          tag: 'ClientOnDemandJobs');
      setState(() => _loading = false);
    }
  }

  Future<void> _loadBids(ShphOnDemandJob job) async {
    setState(() {
      _selectedJob = job;
      _loadingBids = true;
      _bids = [];
    });
    try {
      final bids = await OnDemandService.instance.listJobBids(job.id);
      setState(() {
        _bids = bids;
        _loadingBids = false;
      });
    } catch (e) {
      LoggingService.error('Failed to load bids: $e', tag: 'ClientOnDemandJobs');
      setState(() => _loadingBids = false);
    }
  }

  Future<void> _selectBid(ShphOnDemandBid bid) async {
    if (_selectedJob == null) return;
    setState(() => _selecting = true);
    try {
      final result = await OnDemandService.instance
          .selectBid(_selectedJob!.id, bid.id);
      if (result != null) {
        _showMessage('Provider selected. Booking created.');
        await _loadJobs();
        setState(() {
          _selectedJob = null;
          _bids = [];
        });
      } else {
        _showMessage('Failed to select provider.');
      }
    } catch (e) {
      LoggingService.error('Select bid failed: $e', tag: 'ClientOnDemandJobs');
      _showMessage('Failed to select provider.');
    } finally {
      setState(() => _selecting = false);
    }
  }

  Future<void> _cancelJob(ShphOnDemandJob job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel job?'),
        content: const Text('This will cancel the on-demand job request.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final result = await OnDemandService.instance.cancelJob(job.id);
      if (result != null) {
        _showMessage('Job cancelled.');
        await _loadJobs();
      } else {
        _showMessage('Failed to cancel job.');
      }
    } catch (e) {
      LoggingService.error('Cancel job failed: $e', tag: 'ClientOnDemandJobs');
      _showMessage('Failed to cancel job.');
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
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        title: Text(
          'My On-Demand Jobs',
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryText),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.primaryText),
            onPressed: _loadJobs,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _jobs.isEmpty
              ? _buildEmptyState(theme)
              : _buildJobList(theme),
    );
  }

  Widget _buildEmptyState(AppThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined,
              size: 64, color: theme.secondaryText),
          const SizedBox(height: 16),
          Text(
            'No on-demand jobs yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Post a job and nearby providers will bid.',
            style: GoogleFonts.poppins(color: theme.secondaryText),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/on-demand/booking'),
            child: Text(
              'Post a job',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList(AppThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _jobs.length,
            itemBuilder: (context, index) {
              final job = _jobs[index];
              return _JobCard(
                job: job,
                isSelected: _selectedJob?.id == job.id,
                onTap: () => _loadBids(job),
                onCancel: () => _cancelJob(job),
              );
            },
          ),
        ),
        if (_selectedJob != null)
          Expanded(
            child: _BidPanel(
              bids: _bids,
              loading: _loadingBids,
              selecting: _selecting,
              onSelect: _selectBid,
              onClose: () => setState(() {
                _selectedJob = null;
                _bids = [];
              }),
            ),
          ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.isSelected,
    this.onTap,
    this.onCancel,
  });

  final ShphOnDemandJob job;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Card(
      color: isSelected ? theme.secondaryBackground : theme.primaryBackground,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isSelected ? 2 : 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          job.categoryName ?? 'On-Demand Job #${job.id}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              job.description ?? 'No description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: theme.secondaryText),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatusChip(status: job.status.apiValue),
                const SizedBox(width: 8),
                if (job.estimatedFeeMin != null &&
                    job.estimatedFeeMax != null)
                  Text(
                    '₱${job.estimatedFeeMin!.toStringAsFixed(0)} - ₱${job.estimatedFeeMax!.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: theme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: job.status == ShphOnDemandJobStatus.searching
            ? IconButton(
                icon: Icon(Icons.cancel_outlined, color: theme.error),
                onPressed: onCancel,
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color _color(BuildContext context) {
    final theme = AppTheme.of(context);
    switch (status) {
      case 'accepted':
      case 'scheduled':
        return theme.success;
      case 'expired':
      case 'cancelled':
        return theme.error;
      case 'searching':
      default:
        return theme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: _color(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BidPanel extends StatelessWidget {
  const _BidPanel({
    required this.bids,
    required this.loading,
    required this.selecting,
    required this.onSelect,
    required this.onClose,
  });

  final List<ShphOnDemandBid> bids;
  final bool loading;
  final bool selecting;
  final ValueChanged<ShphOnDemandBid> onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      color: theme.secondaryBackground,
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Bids',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
          ),
          if (loading)
            const Expanded(
                child: Center(child: CircularProgressIndicator())),
          if (!loading && bids.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No bids yet. Pull down to refresh.',
                  style: GoogleFonts.poppins(color: theme.secondaryText),
                ),
              ),
            ),
          if (!loading && bids.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: bids.length,
                itemBuilder: (context, index) {
                  final bid = bids[index];
                  return _BidCard(
                    bid: bid,
                    selecting: selecting,
                    onSelect: () => onSelect(bid),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _BidCard extends StatelessWidget {
  const _BidCard({
    required this.bid,
    required this.selecting,
    required this.onSelect,
  });

  final ShphOnDemandBid bid;
  final bool selecting;
  final VoidCallback onSelect;

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
                CircleAvatar(
                  backgroundImage: bid.provider.photoUrl?.isNotEmpty == true
                      ? NetworkImage(bid.provider.photoUrl!)
                      : null,
                  child: bid.provider.photoUrl?.isNotEmpty != true
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid.provider.displayName ?? 'Provider',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText,
                        ),
                      ),
                      if (bid.provider.rating != null)
                        Text(
                          '${bid.provider.rating} ★',
                          style:
                              GoogleFonts.poppins(color: theme.secondaryText),
                        ),
                    ],
                  ),
                ),
                Text(
                  '₱${bid.totalPrice?.toStringAsFixed(0) ?? '-'}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selecting ? null : onSelect,
                child: selecting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Select provider',
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
