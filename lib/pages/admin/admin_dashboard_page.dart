import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/models/analytics.dart';
import '/api/resources/admin_api.dart';
import '/theme/app_theme.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  static String routeName = 'AdminDashboard';
  static String routePath = '/admin-dashboard';

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  AdminStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final data = await ShphAdminApi.instance.getStats();
      if (mounted) {
        setState(() {
          _stats = AdminStats.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stats: $e')),
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
        title: Text('Admin Dashboard',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _buildStatsGrid(theme),
                  const SizedBox(height: 16),
                  _buildQuickActions(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsGrid(AppThemeData theme) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: [
          _buildStatCard(theme, 'Total Users', '${_stats?.totalUsers ?? 0}',
              Icons.people_outline, theme.primary),
          _buildStatCard(theme, 'Pending KYC', '${_stats?.pendingKyc ?? 0}',
              Icons.verified_user_outlined, theme.warning),
          _buildStatCard(theme, 'Open Disputes', '${_stats?.openDisputes ?? 0}',
              Icons.gavel_outlined, theme.error),
          _buildStatCard(
              theme,
              'Active Bookings',
              '${_stats?.activeBookings ?? 0}',
              Icons.book_online,
              theme.success),
          _buildStatCard(theme, 'Pending Payouts',
              '${_stats?.pendingPayouts ?? 0}', Icons.payment, theme.tertiary),
          _buildStatCard(
              theme,
              'Total Revenue',
              'PHP ${(_stats?.totalRevenue ?? 0).toStringAsFixed(0)}',
              Icons.account_balance_wallet_outlined,
              theme.secondary),
        ],
      );

  Widget _buildStatCard(
    AppThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: color, size: 24)]),
            const Spacer(),
            Text(value,
                style: theme.titleLarge.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label,
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
        ),
      );

  Widget _buildQuickActions(AppThemeData theme) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions',
                style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _buildActionItem(theme, 'KYC Queue', Icons.verified_user_outlined,
                () => context.pushNamed('AdminKycQueue')),
            _buildActionItem(theme, 'Manage Disputes', Icons.gavel_outlined,
                () => context.pushNamed('AdminDisputes')),
            _buildActionItem(theme, 'Payouts', Icons.payment_outlined,
                () => context.pushNamed('AdminPayouts')),
            _buildActionItem(theme, 'Users', Icons.people_outline,
                () => context.pushNamed('AdminUsers')),
            _buildActionItem(theme, 'Audit Logs', Icons.history,
                () => context.pushNamed('AdminAuditLogs')),
          ],
        ),
      );

  Widget _buildActionItem(
    AppThemeData theme,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: theme.primary),
        title: Text(label, style: theme.bodyMedium),
        trailing: Icon(Icons.chevron_right, color: theme.secondaryText),
        onTap: onTap,
      );
}
