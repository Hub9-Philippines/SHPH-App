import 'package:flutter/material.dart';

import '/api/models/wallet.dart';
import '/api/resources/wallet_api.dart';
import '/theme/app_theme.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  static String routeName = 'Wallet';
  static String routePath = '/wallet';

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  WalletBalance _balance = const WalletBalance(balance: 0);
  List<WalletTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final balanceData = await ShphWalletApi.instance.getBalance();
      final txData = await ShphWalletApi.instance.getTransactions();
      if (mounted) {
        setState(() {
          _balance = WalletBalance.fromJson(balanceData);
          _transactions = txData.map(WalletTransaction.fromJson).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load wallet: $e')),
        );
      }
    }
  }

  Future<void> _handleTopUp() async {
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => const _TopUpDialog(),
    );
    if (amount == null || amount <= 0) {
      return;
    }

    try {
      final intent = await ShphWalletApi.instance.topUpCreateIntent(amount);
      final intentId = intent['id'] as String?;
      if (intentId != null) {
        await ShphWalletApi.instance.topUpConfirm(intentId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Top-up of PHP ${amount.toStringAsFixed(2)} initiated')),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Top-up failed: $e')),
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
        title: Text('Wallet',
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
                  _buildBalanceCard(theme),
                  const SizedBox(height: 16),
                  _buildTopUpButton(theme),
                  const SizedBox(height: 24),
                  _buildTransactionsHeader(theme),
                  const SizedBox(height: 12),
                  ..._transactions
                      .map((tx) => _buildTransactionItem(theme, tx)),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard(AppThemeData theme) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primary, theme.primary.withValues(alpha: 0.8)],
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
              'PHP ${_balance.balance.toStringAsFixed(2)}',
              style: theme.displaySmall.override(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(_balance.currency,
                style: theme.bodySmall.override(color: Colors.white60)),
          ],
        ),
      );

  Widget _buildTopUpButton(AppThemeData theme) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _handleTopUp,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Top Up Wallet'),
        ),
      );

  Widget _buildTransactionsHeader(AppThemeData theme) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Transaction History',
              style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        ],
      );

  Widget _buildTransactionItem(AppThemeData theme, WalletTransaction tx) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (tx.isCredit ? theme.success : theme.error)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: tx.isCredit ? theme.success : theme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
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
              '${tx.isCredit ? '+' : '-'}PHP ${tx.amount.abs().toStringAsFixed(2)}',
              style: theme.bodyMedium.override(
                fontWeight: FontWeight.w700,
                color: tx.isCredit ? theme.success : theme.error,
              ),
            ),
          ],
        ),
      );
}

class _TopUpDialog extends StatefulWidget {
  const _TopUpDialog();

  @override
  State<_TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends State<_TopUpDialog> {
  final _controller = TextEditingController();
  final _amounts = [100.0, 200.0, 500.0, 1000.0];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return AlertDialog(
      title: Text('Top Up Wallet', style: theme.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (PHP)',
              prefixText: 'PHP ',
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _amounts
                .map((amount) => ActionChip(
                      label: Text('PHP ${amount.toStringAsFixed(0)}'),
                      onPressed: () {
                        _controller.text = amount.toStringAsFixed(2);
                      },
                    ))
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_controller.text);
            Navigator.of(context).pop(amount);
          },
          child: const Text('Top Up'),
        ),
      ],
    );
  }
}
