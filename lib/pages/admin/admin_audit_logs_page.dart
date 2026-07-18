import 'package:flutter/material.dart';

import '/api/resources/admin_api.dart';
import '/theme/app_theme.dart';

class AdminAuditLogsPage extends StatefulWidget {
  const AdminAuditLogsPage({super.key});

  static String routeName = 'AdminAuditLogs';
  static String routePath = '/admin-audit-logs';

  @override
  State<AdminAuditLogsPage> createState() => _AdminAuditLogsPageState();
}

class _AdminAuditLogsPageState extends State<AdminAuditLogsPage> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ShphAdminApi.instance.getAuditRecent();
      if (mounted) {
        setState(() {
          _logs = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load audit logs: $e')),
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
        title: Text('Audit Logs',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) =>
                        _buildLogItem(theme, _logs[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(AppThemeData theme) => Center(
        child: Text('No audit logs',
            style: theme.bodyMedium.override(color: theme.secondaryText)),
      );

  Widget _buildLogItem(AppThemeData theme, Map<String, dynamic> log) {
    final action = log['action'] as String? ?? 'Unknown';
    final actor = log['actor_name'] as String? ?? 'System';
    final timestamp = log['created_at'] as String? ?? '';
    final target = log['target'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action,
                    style:
                        theme.bodyMedium.override(fontWeight: FontWeight.w700)),
                Text('by $actor',
                    style:
                        theme.bodySmall.override(color: theme.secondaryText)),
                if (target != null) ...[
                  const SizedBox(height: 2),
                  Text('Target: $target',
                      style:
                          theme.bodySmall.override(color: theme.secondaryText)),
                ],
                if (timestamp.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(timestamp,
                      style: theme.labelSmall
                          .override(color: theme.secondaryText)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
