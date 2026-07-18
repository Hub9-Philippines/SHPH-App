import 'package:flutter/material.dart';

import '/api/resources/admin_api.dart';
import '/theme/app_theme.dart';

class AdminPayoutsPage extends StatefulWidget {
  const AdminPayoutsPage({super.key});

  static String routeName = 'AdminPayouts';
  static String routePath = '/admin-payouts';

  @override
  State<AdminPayoutsPage> createState() => _AdminPayoutsPageState();
}

class _AdminPayoutsPageState extends State<AdminPayoutsPage> {
  List<Map<String, dynamic>> _payouts = [];
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
          await ShphAdminApi.instance.listAdminPayouts(status: _statusFilter);
      if (mounted) {
        setState(() {
          _payouts = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load payouts: $e')),
        );
      }
    }
  }

  Future<void> _approve(int id) async {
    try {
      await ShphAdminApi.instance.approvePayout(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payout approved')),
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

  Future<void> _complete(int id) async {
    try {
      await ShphAdminApi.instance.completePayout(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payout completed')),
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

  Future<void> _reject(int id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Payout'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Rejection reason'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
    if (reason == null) {
      return;
    }
    try {
      await ShphAdminApi.instance.rejectPayout(id, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payout rejected')),
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

  Color _statusColor(String status, AppThemeData theme) {
    switch (status) {
      case 'completed':
        return theme.success;
      case 'approved':
        return theme.primary;
      case 'rejected':
        return theme.error;
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
        title: Text('Payouts',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _payouts.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: _payouts.length,
                    itemBuilder: (context, index) =>
                        _buildPayoutCard(theme, _payouts[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(AppThemeData theme) => Center(
        child: Text('No payouts',
            style: theme.bodyMedium.override(color: theme.secondaryText)),
      );

  Widget _buildPayoutCard(AppThemeData theme, Map<String, dynamic> payout) {
    final id = int.tryParse(payout['id']?.toString() ?? '') ?? 0;
    final amount = double.tryParse(payout['amount']?.toString() ?? '0') ?? 0;
    final status = payout['status'] as String? ?? 'pending';
    final providerName = payout['provider_name'] as String? ?? 'Unknown';
    final methodName = payout['payment_method_name'] as String? ?? 'N/A';

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
              Text('PHP ${amount.toStringAsFixed(2)}',
                  style:
                      theme.titleMedium.override(fontWeight: FontWeight.w700)),
              Text(status.toUpperCase(),
                  style: theme.labelSmall.override(
                    color: _statusColor(status, theme),
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Text('Provider: $providerName',
              style: theme.bodySmall.override(color: theme.secondaryText)),
          Text('Method: $methodName',
              style: theme.bodySmall.override(color: theme.secondaryText)),
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _reject(id),
                    style:
                        OutlinedButton.styleFrom(foregroundColor: theme.error),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _approve(id),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
          if (status == 'approved') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _complete(id),
                child: const Text('Mark Completed'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
