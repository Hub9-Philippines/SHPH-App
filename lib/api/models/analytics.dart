import '/utils/formatters.dart';

/// Provider analytics model.
class ProviderAnalytics {
  const ProviderAnalytics({
    required this.totalEarnings,
    required this.completedJobs,
    required this.averageRating,
    required this.responseTime,
    this.acceptanceRate = 0.0,
    this.onTimeCompletion = 0.0,
    this.customerSatisfaction = 0.0,
    this.earningsChart = const [],
    this.monthlyBreakdown = const [],
    this.topServices = const [],
    this.recentFeedback = const [],
    this.bookingInsights = const {},
  });

  factory ProviderAnalytics.fromJson(Map<String, dynamic> json) =>
      ProviderAnalytics(
        totalEarnings: Formatters.parseAmount(json['total_earnings']),
        completedJobs: json['completed_jobs'] as int? ?? 0,
        averageRating: Formatters.parseAmount(json['average_rating']),
        responseTime: json['response_time'] as String? ?? 'N/A',
        acceptanceRate: Formatters.parseAmount(json['acceptance_rate']),
        onTimeCompletion: Formatters.parseAmount(json['on_time_completion']),
        customerSatisfaction:
            Formatters.parseAmount(json['customer_satisfaction']),
        earningsChart: Formatters.parseMapList(json['earnings_chart']),
        monthlyBreakdown: Formatters.parseMapList(json['monthly_breakdown']),
        topServices: Formatters.parseMapList(json['top_services']),
        recentFeedback: Formatters.parseMapList(json['recent_feedback']),
        bookingInsights:
            json['booking_insights'] as Map<String, dynamic>? ?? {},
      );

  final double totalEarnings;
  final int completedJobs;
  final double averageRating;
  final String responseTime;
  final double acceptanceRate;
  final double onTimeCompletion;
  final double customerSatisfaction;
  final List<Map<String, dynamic>> earningsChart;
  final List<Map<String, dynamic>> monthlyBreakdown;
  final List<Map<String, dynamic>> topServices;
  final List<Map<String, dynamic>> recentFeedback;
  final Map<String, dynamic> bookingInsights;
}

/// Admin dashboard stats model.
class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.pendingKyc,
    required this.openDisputes,
    required this.activeBookings,
    required this.pendingPayouts,
    this.totalRevenue = 0.0,
    this.onDemandJobs = const {},
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
        totalUsers: json['total_users'] as int? ?? 0,
        pendingKyc: json['pending_kyc'] as int? ?? 0,
        openDisputes: json['open_disputes'] as int? ?? 0,
        activeBookings: json['active_bookings'] as int? ?? 0,
        pendingPayouts: json['pending_payouts'] as int? ?? 0,
        totalRevenue: Formatters.parseAmount(json['total_revenue']),
        onDemandJobs: json['on_demand_jobs'] as Map<String, dynamic>? ?? {},
      );

  final int totalUsers;
  final int pendingKyc;
  final int openDisputes;
  final int activeBookings;
  final int pendingPayouts;
  final double totalRevenue;
  final Map<String, dynamic> onDemandJobs;
}
