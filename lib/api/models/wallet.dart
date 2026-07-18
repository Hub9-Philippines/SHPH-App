import '/utils/formatters.dart';

/// Wallet transaction model.
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.createdAt,
    this.balanceAfter,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id']?.toString() ?? '',
        type: json['type'] as String? ?? 'unknown',
        amount: Formatters.parseAmount(json['amount']),
        description: json['description'] as String? ?? '',
        createdAt: json['created_at'] as String?,
        balanceAfter: Formatters.parseAmount(json['balance_after']),
      );

  final String id;
  final String type;
  final double amount;
  final String description;
  final String? createdAt;
  final double? balanceAfter;

  bool get isCredit => amount > 0;
  bool get isDebit => amount < 0;
}

/// Wallet balance model.
class WalletBalance {
  const WalletBalance({
    required this.balance,
    this.currency = 'PHP',
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
        balance: Formatters.parseAmount(json['balance']),
        currency: json['currency'] as String? ?? 'PHP',
      );

  final double balance;
  final String currency;
}
