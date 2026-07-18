import 'package:flutter/material.dart';

import '/api/resources/admin_api.dart';
import '/theme/app_theme.dart';

class AdminDisputesPage extends StatefulWidget {
  const AdminDisputesPage({super.key});

  static String routeName = 'AdminDisputes';
  static String routePath = '/admin-disputes';

  @override
  State<AdminDisputesPage> createState() => _AdminDisputesPageState();
}

class _AdminDisputesPageState extends State<AdminDisputesPage> {
  List<Map<String, dynamic>> _disputes = [];
  bool _isLoading = true;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data =
          await ShphAdminApi.instance.listAdminDisputes(status: _statusFilter);
      if (mounted) {
        setState(() {
          _disputes = data;
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

  Future<void> _markUnderReview(int id) async {
    try {
      await ShphAdminApi.instance.reviewDispute(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as under review')),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _resolveDispute(int id) async {
    final notes = await _showNotesDialog('Resolve Dispute', 'Resolution notes');
    if (notes == null) {
      return;
    }
    try {
      await ShphAdminApi.instance.resolveDispute(id, notes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispute resolved')),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _closeDispute(int id) async {
    final notes = await _showNotesDialog('Close Dispute', 'Closing notes');
    if (notes == null) {
      return;
    }
    try {
      await ShphAdminApi.instance.closeDispute(id, notes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispute closed')),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<String?> _showNotesDialog(String title, String hint) =>
      showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: hint),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(controller.text.trim()),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );

  Color _statusColor(String status, AppThemeData theme) {
    switch (status) {
      case 'resolved':
        return theme.success;
      case 'under_review':
        return theme.warning;
      case 'closed':
        return theme.secondaryText;
      default:
        return theme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Manage Disputes',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _disputes.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
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
        child: Text('No disputes found',
            style: theme.bodyMedium.override(color: theme.secondaryText)),
      );

  Widget _buildDisputeCard(AppThemeData theme, Map<String, dynamic> dispute) {
    final id = int.tryParse(dispute['id']?.toString() ?? '') ?? 0;
    final reason = dispute['reason'] as String? ?? 'Unknown';
    final description = dispute['description'] as String? ?? '';
    final status = dispute['status'] as String? ?? 'open';
    final clientName = dispute['client_name'] as String? ?? 'N/A';
    final providerName = dispute['provider_name'] as String? ?? 'N/A';

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
                child: Text(reason,
                    style:
                        theme.titleSmall.override(fontWeight: FontWeight.w700)),
              ),
              Text(
                status.replaceAll('_', ' ').toUpperCase(),
                style: theme.labelSmall.override(
                  color: _statusColor(status, theme),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: theme.bodyMedium.override(color: theme.secondaryText)),
          const SizedBox(height: 8),
          Text('Client: $clientName  |  Provider: $providerName',
              style: theme.bodySmall.override(color: theme.secondaryText)),
          if (status == 'open') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _markUnderReview(id),
                child: const Text('Mark Under Review'),
              ),
            ),
          ],
          if (status == 'under_review') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resolveDispute(id),
                    child: const Text('Resolve'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _closeDispute(id),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
