import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/resources/admin_api.dart';
import '/index.dart';
import '/theme/app_theme.dart';

class AdminKycQueuePage extends StatefulWidget {
  const AdminKycQueuePage({super.key});

  static String routeName = 'AdminKycQueue';
  static String routePath = '/admin-kyc-queue';

  @override
  State<AdminKycQueuePage> createState() => _AdminKycQueuePageState();
}

class _AdminKycQueuePageState extends State<AdminKycQueuePage> {
  List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = true;
  String _statusFilter = 'pending';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ShphAdminApi.instance.listKyc(status: _statusFilter);
      if (mounted) {
        setState(() {
          _submissions = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load KYC queue: $e')),
        );
      }
    }
  }

  Future<void> _approve(int id) async {
    try {
      await ShphAdminApi.instance.approveKyc(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC approved')),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: $e')),
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
          title: const Text('Reject KYC'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Rejection Reason',
              hintText: 'e.g. ID not clear',
            ),
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
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
    if (reason == null || reason.isEmpty) {
      return;
    }

    try {
      await ShphAdminApi.instance.rejectKyc(id, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC rejected')),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('KYC Queue',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterBar(theme),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _submissions.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                          itemCount: _submissions.length,
                          itemBuilder: (context, index) =>
                              _buildSubmissionCard(theme, _submissions[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(AppThemeData theme) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: ['pending', 'approved', 'rejected']
              .map((status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label:
                          Text(status[0].toUpperCase() + status.substring(1)),
                      selected: _statusFilter == status,
                      onSelected: (_) {
                        setState(() => _statusFilter = status);
                        _loadData();
                      },
                    ),
                  ))
              .toList(),
        ),
      );

  Widget _buildEmptyState(AppThemeData theme) => Center(
        child: Text('No $_statusFilter submissions',
            style: theme.bodyMedium.override(color: theme.secondaryText)),
      );

  Widget _buildSubmissionCard(AppThemeData theme, Map<String, dynamic> sub) {
    final id = int.tryParse(sub['id']?.toString() ?? '') ?? 0;
    final name = sub['user_name'] as String? ??
        sub['display_name'] as String? ??
        'Unknown';
    final email = sub['user_email'] as String? ?? '';
    final status = sub['status'] as String? ?? 'pending';
    final idType = sub['id_type'] as String? ?? 'N/A';
    final submittedAt = sub['created_at'] as String?;

    return GestureDetector(
      onTap: () => context.pushNamed(
        AdminKycDetailPage.routeName,
        pathParameters: {'id': id.toString()},
      ),
      child: Container(
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
                  child: Text(name,
                      style:
                          theme.titleSmall.override(fontWeight: FontWeight.w700)),
                ),
                Text(status.toUpperCase(),
                    style: theme.labelSmall.override(
                      color: status == 'approved'
                          ? theme.success
                          : status == 'rejected'
                              ? theme.error
                              : theme.warning,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(email,
                  style: theme.bodySmall.override(color: theme.secondaryText)),
            ],
            const SizedBox(height: 8),
            Text('ID Type: $idType',
                style: theme.bodySmall.override(color: theme.secondaryText)),
            if (submittedAt != null) ...[
              const SizedBox(height: 4),
              Text('Submitted: $submittedAt',
                  style: theme.bodySmall.override(color: theme.secondaryText)),
            ],
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.pushNamed(
                  AdminKycDetailPage.routeName,
                  pathParameters: {'id': id.toString()},
                ),
                child: Text('View Details',
                    style: TextStyle(color: theme.primary, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
