import '/utils/formatters.dart';

/// Earnings summary model for providers.
class EarningsSummary {
  const EarningsSummary({
    required this.totalEarnings,
    required this.availableBalance,
    required this.pendingBalance,
    required this.completedJobs,
    this.thisMonth = 0.0,
    this.thisWeek = 0.0,
    this.averageRating = 0.0,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) =>
      EarningsSummary(
        totalEarnings: Formatters.parseAmount(json['total_earnings']),
        availableBalance: Formatters.parseAmount(json['available_balance']),
        pendingBalance: Formatters.parseAmount(json['pending_balance']),
        completedJobs: json['completed_jobs'] as int? ?? 0,
        thisMonth: Formatters.parseAmount(json['this_month']),
        thisWeek: Formatters.parseAmount(json['this_week']),
        averageRating: Formatters.parseAmount(json['average_rating']),
      );

  final double totalEarnings;
  final double availableBalance;
  final double pendingBalance;
  final int completedJobs;
  final double thisMonth;
  final double thisWeek;
  final double averageRating;
}

/// Earnings transaction model.
class EarningsTransaction {
  const EarningsTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    this.createdAt,
    this.bookingId,
    this.status,
  });

  factory EarningsTransaction.fromJson(Map<String, dynamic> json) =>
      EarningsTransaction(
        id: json['id']?.toString() ?? '',
        amount: Formatters.parseAmount(json['amount']),
        type: json['type'] as String? ?? 'earning',
        description: json['description'] as String? ?? '',
        createdAt: json['created_at'] as String?,
        bookingId: json['booking_id']?.toString(),
        status: json['status'] as String?,
      );

  final String id;
  final double amount;
  final String type;
  final String description;
  final String? createdAt;
  final String? bookingId;
  final String? status;
}

/// Payout request model.
class PayoutRequest {
  const PayoutRequest({
    required this.id,
    required this.amount,
    required this.status,
    this.createdAt,
    this.processedAt,
    this.paymentMethodName,
    this.providerName,
  });

  factory PayoutRequest.fromJson(Map<String, dynamic> json) => PayoutRequest(
        id: json['id']?.toString() ?? '',
        amount: Formatters.parseAmount(json['amount']),
        status: json['status'] as String? ?? 'pending',
        createdAt: json['created_at'] as String?,
        processedAt: json['processed_at'] as String?,
        paymentMethodName: json['payment_method_name'] as String?,
        providerName: json['provider_name'] as String?,
      );

  final String id;
  final double amount;
  final String status;
  final String? createdAt;
  final String? processedAt;
  final String? paymentMethodName;
  final String? providerName;
}
