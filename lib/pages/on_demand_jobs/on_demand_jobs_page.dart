import 'package:flutter/material.dart';

import '/services/dispatch/dispatch_service.dart';
import '/theme/app_theme.dart';

class OnDemandJobsPage extends StatefulWidget {
  const OnDemandJobsPage({super.key});

  static String routeName = 'OnDemandJobs';
  static String routePath = '/on-demand-jobs';

  @override
  State<OnDemandJobsPage> createState() => _OnDemandJobsPageState();
}

class _OnDemandJobsPageState extends State<OnDemandJobsPage> {
  List<Map<String, dynamic>> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final jobs = await DispatchService.instance.getClientJobs();
      if (mounted) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load jobs: $e')),
        );
      }
    }
  }

  Color _statusColor(String? status, AppThemeData theme) {
    switch (status) {
      case 'completed':
        return theme.success;
      case 'cancelled':
      case 'expired':
        return theme.error;
      case 'accepted':
      case 'assigned':
        return theme.primary;
      default:
        return theme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('My Job Requests',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jobs.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: _jobs.length,
                    itemBuilder: (context, index) =>
                        _buildJobCard(theme, _jobs[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(AppThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off_outlined, size: 64, color: theme.secondaryText),
            const SizedBox(height: 16),
            Text('No on-demand jobs yet',
                style: theme.bodyMedium.override(color: theme.secondaryText)),
          ],
        ),
      );

  Widget _buildJobCard(AppThemeData theme, Map<String, dynamic> job) {
    final status = job['status'] as String? ?? 'pending';
    final description = job['description'] as String? ?? '';
    final categoryName = job['category_name'] as String? ?? 'Unknown';
    final createdAt = job['created_at'] as String?;
    final bidCount = job['bid_count'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(categoryName,
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
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.gavel_outlined, size: 16, color: theme.secondaryText),
              const SizedBox(width: 4),
              Text('$bidCount bids',
                  style: theme.bodySmall.override(color: theme.secondaryText)),
              if (createdAt != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: theme.secondaryText),
                const SizedBox(width: 4),
                Text(createdAt,
                    style:
                        theme.bodySmall.override(color: theme.secondaryText)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
