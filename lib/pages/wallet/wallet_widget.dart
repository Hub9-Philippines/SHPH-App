import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/shph_api.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';

class WalletWidget extends StatefulWidget {
  const WalletWidget({super.key});

  static String routeName = 'Wallet';
  static String routePath = '/wallet';

  @override
  State<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await ShphWalletApi.instance.getWallet();
      if (!mounted) return;

      List<Map<String, dynamic>> transactions = [];
      try {
        final txData = await ShphWalletApi.instance.listTransactions();
        if (txData['results'] is List) {
          transactions = (txData['results'] as List).cast<Map<String, dynamic>>();
        } else if (txData['transactions'] is List) {
          transactions = (txData['transactions'] as List).cast<Map<String, dynamic>>();
        }
      } catch (_) {
        if (data['recent_transactions'] is List) {
          transactions = (data['recent_transactions'] as List).cast<Map<String, dynamic>>();
        }
      }

      if (!mounted) return;
      setState(() {
        _balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      LoggingService.error('Wallet load error: $e', tag: 'Wallet');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _currency(double v) => 'PHP ${v.toStringAsFixed(2)}';

  Future<void> _handleTopUp() async {
    final controller = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Top Up Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the amount to add to your wallet.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixText: 'PHP ',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [100, 200, 500, 1000].map((preset) {
                return ActionChip(
                  label: Text('PHP $preset'),
                  onPressed: () => controller.text = preset.toString(),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(ctx, value);
              }
            },
            child: const Text('Top Up'),
          ),
        ],
      ),
    );

    if (amount == null || !mounted) return;

    try {
      final intent = await ShphWalletApi.instance.createTopUpIntent(
        amount: amount,
      );

      final clientKey = intent['client_key'] as String?;
      if (clientKey == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to initialize top-up.')),
          );
        }
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientKey,
          merchantDisplayName: 'SerbisyoHub',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final intentId = intent['intent_id'] as String?;
      if (intentId != null) {
        await ShphWalletApi.instance.confirmTopUp(
          intentId: intentId,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet topped up successfully!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Top-up failed: $e')),
        );
      }
    }
  }

  String _txTypeLabel(String type) {
    return switch (type) {
      'topup' => 'Top Up',
      'payment' => 'Payment',
      'reversal' => 'Reversal',
      'tip' => 'Tip',
      _ => type,
    };
  }

  Color _txTypeColor(String type) {
    return switch (type) {
      'topup' || 'reversal' || 'tip' => const Color(0xFF059669),
      'payment' => const Color(0xFFDC2626),
      _ => const Color(0xFF64748B),
    };
  }

  IconData _txTypeIcon(String type) {
    return switch (type) {
      'topup' => Icons.add_circle_outline_rounded,
      'payment' => Icons.shopping_bag_outlined,
      'reversal' => Icons.undo_rounded,
      'tip' => Icons.volunteer_activism_outlined,
      _ => Icons.receipt_long_outlined,
    };
  }

  DateTime? _parseDate(Map<String, dynamic> tx) {
    final raw = tx['created_at'] as String?;
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wallet', style: theme.titleMedium),
            Text(
              'Balance, top-ups & transactions',
              style: theme.bodySmall.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _buildBalanceCard(context),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 16),
                  _buildTransactionsSection(context),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Balance',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currency(_balance),
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded,
                  size: 18, color: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(width: 6),
              Text(
                'SHPH Wallet',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.add_circle_rounded,
            label: 'Top Up',
            color: const Color(0xFF059669),
            onTap: _handleTopUp,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.history_rounded,
            label: 'History',
            color: const Color(0xFF2563EB),
            onTap: () async {
              try {
                final txData = await ShphWalletApi.instance.listTransactions();
                if (!mounted) return;
                List<Map<String, dynamic>> txs = [];
                if (txData['results'] is List) {
                  txs = (txData['results'] as List).cast<Map<String, dynamic>>();
                } else if (txData['transactions'] is List) {
                  txs = (txData['transactions'] as List).cast<Map<String, dynamic>>();
                }
                setState(() => _transactions = txs);
              } catch (_) {}
              if (!mounted) return;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  builder: (_, scrollController) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.history, size: 24),
                            const SizedBox(width: 8),
                            const Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: _transactions.isEmpty
                            ? const Center(child: Text('No transactions yet'))
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: _transactions.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final tx = _transactions[index];
                                  final type = tx['type']?.toString() ?? 'Unknown';
                                  final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
                                  final desc = tx['description']?.toString() ?? tx['notes']?.toString() ?? '';
                                  final date = tx['created_at']?.toString() ?? tx['date']?.toString() ?? '';
                                  final isCredit = amount > 0;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isCredit ? Colors.green.shade100 : Colors.red.shade100,
                                      child: Icon(
                                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                        color: isCredit ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    title: Text(type, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text('$desc\n$date', maxLines: 2),
                                    trailing: Text(
                                      '${isCredit ? '+' : ''}PHP ${amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isCredit ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: theme.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Your last 50 wallet transactions',
            style: theme.bodySmall.copyWith(color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          if (_transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined,
                        size: 48, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Top up your wallet to get started',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._transactions.map((tx) => _buildTxItem(context, tx)),
        ],
      ),
    );
  }

  Widget _buildTxItem(BuildContext context, Map<String, dynamic> tx) {
    final type = tx['type'] as String? ?? 'adjustment';
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final description = tx['description'] as String? ?? _txTypeLabel(type);
    final date = _parseDate(tx);
    final isCredit = amount >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _txTypeColor(type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_txTypeIcon(type), size: 20, color: _txTypeColor(type)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _txTypeLabel(type),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (date != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : ''}${_currency(amount.abs())}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
