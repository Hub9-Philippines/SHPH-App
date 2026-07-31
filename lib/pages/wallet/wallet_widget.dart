import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/screen_header.dart';
import '/components/soft_card.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'wallet_model.dart';

export 'wallet_model.dart';

class WalletWidget extends StatefulWidget {
  const WalletWidget({super.key});

  static String routeName = 'Wallet';
  static String routePath = '/wallet';

  @override
  State<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  late WalletModel _model;

  @override
  void initState() {
    super.initState();
    _model = WalletModel();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    await _model.loadTransactions();
    safeSetState(() {});
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
      backgroundColor: theme.secondaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Wallet'),
            if (_model.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  _buildBalanceCard(context),
                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildTransactionsHeader(context),
                  const SizedBox(height: 12),
                  ..._model.transactions.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildTransactionItem(context, t),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppThemeData.radiusCard),
        boxShadow: AppThemeData.shadowLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Balance',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₱${_model.balance.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBalanceBadge(context, 'Earnings', _model.totalEarnings),
              const SizedBox(width: 16),
              _buildBalanceBadge(context, 'Spent', _model.totalSpent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceBadge(
      BuildContext context, String label, double amount) {
    final theme = AppTheme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₱${amount.toStringAsFixed(2)}',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = AppTheme.of(context);

    return Row(
      children: [
        Expanded(child: _buildActionButton(context, Icons.add_rounded, 'Top Up', () {})),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(context, Icons.send_rounded, 'Send', () {})),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(context, Icons.download_rounded, 'Withdraw', () {})),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: theme.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.bodySmall.override(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsHeader(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      children: [
        Text(
          'Transactions',
          style: theme.titleMedium.override(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const Spacer(),
        Text(
          'See all',
          style: theme.bodySmall.override(
            color: theme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, Map<String, dynamic> transaction) {
    final theme = AppTheme.of(context);
    final isCredit = transaction['type'] == 'credit';

    return SoftCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCredit
                  ? theme.success.withValues(alpha: 0.1)
                  : theme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppThemeData.radiusSm),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? theme.success : theme.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'] as String? ?? '',
                  style: theme.bodyMedium.override(
                    fontWeight: FontWeight.w500,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction['date'] as String? ?? '',
                  style: theme.bodySmall.override(color: theme.textTertiary),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}₱${(transaction['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
            style: theme.titleSmall.override(
              fontWeight: FontWeight.w600,
              color: isCredit ? theme.success : theme.error,
            ),
          ),
        ],
      ),
    );
  }
}
