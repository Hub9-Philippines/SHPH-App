import 'package:flutter/material.dart';

import '/api/models/earnings.dart';
import '/api/resources/earnings_api.dart';
import '/theme/app_theme.dart';
import '/utils/formatters.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  static String routeName = 'EarningsPage';
  static String routePath = '/earnings-page';

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  EarningsSummary? _summary;
  List<EarningsTransaction> _transactions = [];
  List<PayoutRequest> _payouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final summaryData = await ShphEarningsApi.instance.getSummary();
      final txData = await ShphEarningsApi.instance.getTransactions();
      final payoutData = await ShphEarningsApi.instance.getPayouts();
      if (mounted) {
        setState(() {
          _summary = EarningsSummary.fromJson(summaryData);
          _transactions = txData.map(EarningsTransaction.fromJson).toList();
          _payouts = payoutData.map(PayoutRequest.fromJson).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load earnings: $e')),
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
        title: Text('Earnings',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _buildSummaryCard(theme),
                  const SizedBox(height: 16),
                  _buildStatsRow(theme),
                  const SizedBox(height: 16),
                  _buildPayoutsSection(theme),
                  const SizedBox(height: 16),
                  _buildTransactionsSection(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(AppThemeData theme) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.success, theme.success.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available Balance',
                style: theme.bodyMedium.override(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              Formatters.currency(_summary?.availableBalance ?? 0),
              style: theme.displaySmall.override(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Pending',
                    Formatters.currency(_summary?.pendingBalance ?? 0)),
                _buildSummaryItem(
                    'Total', Formatters.currency(_summary?.totalEarnings ?? 0)),
              ],
            ),
          ],
        ),
      );

  Widget _buildSummaryItem(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTheme.of(context)
                  .bodySmall
                  .override(color: Colors.white60)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTheme.of(context)
                  .titleSmall
                  .override(color: Colors.white)),
        ],
      );

  Widget _buildStatsRow(AppThemeData theme) => Row(
        children: [
          Expanded(
            child: _buildStatCard(
                theme,
                'This Month',
                Formatters.currency(_summary?.thisMonth ?? 0),
                Icons.calendar_today),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(theme, 'This Week',
                Formatters.currency(_summary?.thisWeek ?? 0), Icons.date_range),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(theme, 'Jobs',
                '${_summary?.completedJobs ?? 0}', Icons.work_outline),
          ),
        ],
      );

  Widget _buildStatCard(
    AppThemeData theme,
    String label,
    String value,
    IconData icon,
  ) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.primary, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: theme.titleSmall.override(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(label,
                style: theme.labelSmall.override(color: theme.secondaryText),
                textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _buildPayoutsSection(AppThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payout Requests',
              style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (_payouts.isEmpty)
            Text('No payout requests yet',
                style: theme.bodySmall.override(color: theme.secondaryText))
          else
            ..._payouts.map((p) => _buildPayoutItem(theme, p)),
        ],
      );

  Widget _buildPayoutItem(AppThemeData theme, PayoutRequest payout) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.currency(payout.amount),
                    style:
                        theme.bodyMedium.override(fontWeight: FontWeight.w700)),
                if (payout.paymentMethodName != null)
                  Text(payout.paymentMethodName!,
                      style:
                          theme.bodySmall.override(color: theme.secondaryText)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _payoutStatusColor(payout.status, theme)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                payout.status.toUpperCase(),
                style: theme.labelSmall.override(
                  color: _payoutStatusColor(payout.status, theme),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );

  Color _payoutStatusColor(String status, AppThemeData theme) {
    switch (status) {
      case 'approved':
      case 'completed':
        return theme.success;
      case 'rejected':
        return theme.error;
      default:
        return theme.warning;
    }
  }

  Widget _buildTransactionsSection(AppThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaction History',
              style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (_transactions.isEmpty)
            Text('No transactions yet',
                style: theme.bodySmall.override(color: theme.secondaryText))
          else
            ..._transactions.map((tx) => _buildTransactionItem(theme, tx)),
        ],
      );

  Widget _buildTransactionItem(AppThemeData theme, EarningsTransaction tx) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.description, style: theme.bodyMedium),
                  Text(tx.type,
                      style:
                          theme.bodySmall.override(color: theme.secondaryText)),
                ],
              ),
            ),
            Text(
              '+${Formatters.currency(tx.amount)}',
              style: theme.bodyMedium.override(
                fontWeight: FontWeight.w700,
                color: theme.success,
              ),
            ),
          ],
        ),
      );
}
