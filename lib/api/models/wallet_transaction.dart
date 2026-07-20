/// Wallet transaction types matching the web backend `WalletTransaction.Type`.
enum WalletTransactionType {
  topup,
  payment,
  reversal,
  tip;

  static WalletTransactionType fromString(String? value) {
    switch (value) {
      case 'topup':
        return WalletTransactionType.topup;
      case 'payment':
        return WalletTransactionType.payment;
      case 'reversal':
        return WalletTransactionType.reversal;
      case 'tip':
        return WalletTransactionType.tip;
      default:
        return WalletTransactionType.topup;
    }
  }

  String get label {
    switch (this) {
      case WalletTransactionType.topup:
        return 'Top-up';
      case WalletTransactionType.payment:
        return 'Booking Payment';
      case WalletTransactionType.reversal:
        return 'Reversal';
      case WalletTransactionType.tip:
        return 'Tip';
    }
  }

  bool get isCredit =>
      this == WalletTransactionType.topup ||
      this == WalletTransactionType.reversal ||
      this == WalletTransactionType.tip;
}

/// Represents a single wallet ledger entry from the API.
class WalletTransaction {
  final int id;
  final WalletTransactionType type;
  final double amount;
  final double balanceAfter;
  final String? bookingId;
  final String description;
  final String createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.bookingId,
    required this.description,
    required this.createdAt,
  });

  /// Signed amount: + for credits, - for payments.
  String get signedAmount {
    final sign = type == WalletTransactionType.payment ? '-' : '+';
    return '$sign${amount.toStringAsFixed(2)}';
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as int? ?? 0,
      type: WalletTransactionType.fromString(json['type'] as String?),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      balanceAfter:
          double.tryParse(json['balance_after']?.toString() ?? '0') ?? 0,
      bookingId: json['booking']?.toString(),
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
