import 'package:flutter/material.dart';

import '/components/error_state.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'earnings_model.dart';

export 'earnings_model.dart';

class EarningsWidget extends StatefulWidget {
  const EarningsWidget({super.key});

  static String routeName = 'Earnings';
  static String routePath = '/earnings';

  @override
  State<EarningsWidget> createState() => _EarningsWidgetState();
}

class _EarningsWidgetState extends State<EarningsWidget> {
  late EarningsModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EarningsModel.new);
    _model.load().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: const Text('Earnings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.fetchError != null
              ? Center(
                  child: ErrorState(
                  message: _model.fetchError!,
                  onRetry: () => _model.load().then((_) => safeSetState(() {})),
                ))
              : RefreshIndicator(
                  onRefresh: () =>
                      _model.load().then((_) => safeSetState(() {})),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummaryGrid(theme),
                      const SizedBox(height: 16),
                      if (_model.payouts.isNotEmpty) ...[
                        Text('Payout Requests', style: theme.titleSmall),
                        const SizedBox(height: 8),
                        ..._model.payouts.map((p) => _buildPayoutItem(theme, p)),
                        const SizedBox(height: 16),
                      ],
                      Text('Recent Transactions', style: theme.titleSmall),
                      const SizedBox(height: 8),
                      if (_model.transactions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text('No transactions yet.',
                                style: theme.bodySmall),
                          ),
                        )
                      else
                        ..._model.transactions
                            .map((tx) => _buildTransactionItem(theme, tx)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryGrid(AppThemeData theme) {
    final items = [
      ('Total Earned', '\$${_fmt(_model.summary['total_earned'])}', theme.primary),
      ('This Month', '\$${_fmt(_model.summary['this_month'])}', theme.success),
      ('Pending', '\$${_fmt(_model.summary['pending'])}', theme.warning),
      ('Available', '\$${_fmt(_model.summary['available'])}', theme.success),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.$1, style: theme.bodySmall?.copyWith(color: theme.secondaryText)),
              const Spacer(),
              Text(item.$2,
                  style: theme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: item.$3,
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPayoutItem(AppThemeData theme, Map<String, dynamic> payout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.secondaryBackground,
      elevation: 0,
      child: ListTile(
        leading: Icon(Icons.account_balance_wallet, color: theme.primary),
        title: Text('Payout #${payout['id']}',
            style: theme.bodyMedium),
        subtitle: Text(payout['created_at']?.toString() ?? '',
            style: theme.bodySmall),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${_fmt(payout['amount'])}',
                style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _payoutStatusColor(
                        payout['status']?.toString() ?? '', theme)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                payout['status']?.toString() ?? '',
                style: theme.bodySmall?.copyWith(
                  color: _payoutStatusColor(
                      payout['status']?.toString() ?? '', theme),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _payoutStatusColor(String status, AppThemeData theme) => switch (status) {
        'pending' => theme.warning,
        'processing' => theme.primary,
        'completed' => theme.success,
        'failed' => theme.error,
        _ => theme.textTertiary,
      };

  Widget _buildTransactionItem(
      AppThemeData theme, Map<String, dynamic> tx) {
    final isPayout = tx['type'] == 'payout';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.secondaryBackground,
      elevation: 0,
      child: ListTile(
        leading: Icon(
          isPayout ? Icons.arrow_upward : Icons.arrow_downward,
          color: isPayout ? theme.error : theme.success,
        ),
        title: Text(tx['description']?.toString() ?? '',
            style: theme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(tx['created_at']?.toString() ?? '',
            style: theme.bodySmall),
        trailing: Text(
          '${isPayout ? '-' : '+'}\$${_fmt(tx['amount'])}',
          style: theme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isPayout ? theme.error : theme.success,
          ),
        ),
      ),
    );
  }

  String _fmt(dynamic val) {
    if (val == null) return '0';
    final n = val is num ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return n.toStringAsFixed(0);
  }
}
