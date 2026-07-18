import 'package:flutter/material.dart';

import '/api/models/dispute.dart';
import '/api/resources/disputes_api.dart';
import '/theme/app_theme.dart';

class DisputesPage extends StatefulWidget {
  const DisputesPage({super.key});

  static String routeName = 'DisputesPage';
  static String routePath = '/disputes-page';

  @override
  State<DisputesPage> createState() => _DisputesPageState();
}

class _DisputesPageState extends State<DisputesPage> {
  List<Dispute> _disputes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    setState(() => _isLoading = true);
    try {
      final data = await ShphDisputesApi.instance.listDisputes();
      if (mounted) {
        setState(() {
          _disputes = data.map(Dispute.fromJson).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load disputes: $e')),
        );
      }
    }
  }

  Color _statusColor(String status, AppThemeData theme) {
    switch (status) {
      case 'resolved':
      case 'closed':
        return theme.success;
      case 'under_review':
        return theme.warning;
      case 'open':
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
        title: Text('Disputes',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _disputes.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadDisputes,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: _disputes.length,
                    itemBuilder: (context, index) =>
                        _buildDisputeCard(theme, _disputes[index]),
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
            Text('No disputes',
                style: theme.bodyMedium.override(color: theme.secondaryText)),
          ],
        ),
      );

  Widget _buildDisputeCard(AppThemeData theme, Dispute dispute) => Container(
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
                  child: Text(dispute.reason,
                      style: theme.titleSmall
                          .override(fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(dispute.status, theme)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dispute.status.replaceAll('_', ' ').toUpperCase(),
                    style: theme.labelSmall.override(
                      color: _statusColor(dispute.status, theme),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(dispute.description,
                style: theme.bodyMedium.override(color: theme.secondaryText)),
            if (dispute.serviceName != null) ...[
              const SizedBox(height: 8),
              Text('Service: ${dispute.serviceName}',
                  style: theme.bodySmall.override(color: theme.secondaryText)),
            ],
            if (dispute.createdAt != null) ...[
              const SizedBox(height: 4),
              Text('Filed: ${dispute.createdAt}',
                  style: theme.bodySmall.override(color: theme.secondaryText)),
            ],
          ],
        ),
      );
}
