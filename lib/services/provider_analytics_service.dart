import '/api/resources/analytics_api.dart';
import '/services/logging_service.dart';

class ProviderAnalyticsService {
  ProviderAnalyticsService._();
  static final ProviderAnalyticsService instance = ProviderAnalyticsService._();
  final _api = ShphAnalyticsApi.instance;

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final responses = await Future.wait([
        _api.getProviderAnalytics(),
        _api.getProviderBookingAnalytics(),
        _api.getProviderRevenueAnalytics(),
      ]);
      final data = <String, dynamic>{...responses[0]};
      final bookings = responses[1];
      final revenue = responses[2];
      data['booking_insights'] =
          bookings['booking_insights'] ?? bookings['insights'] ?? bookings;
      data['monthly_revenue'] = revenue['monthly_revenue'] ??
          revenue['results'] ??
          revenue['revenue'] ??
          <Map<String, dynamic>>[];
      return _normalize(data);
    } catch (e) {
      LoggingService.error('Analytics fetch failed: $e',
          tag: 'ProviderAnalyticsService');
      return _normalize(const {});
    }
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> data) => {
        'totalEarnings':
            (data['total_earnings'] ?? data['totalEarnings'] ?? 0) as num,
        'totalJobs': data['total_jobs'] ?? data['totalJobs'] ?? 0,
        'avgRating': (data['avg_rating'] ?? data['avgRating'] ?? 0) as num,
        'totalReviews': data['total_reviews'] ?? data['totalReviews'] ?? 0,
        'completionRate':
            (data['completion_rate'] ?? data['completionRate'] ?? 0) as num,
        'monthlyRevenue': data['monthly_revenue'] ??
            data['monthlyRevenue'] ??
            <Map<String, dynamic>>[],
        'bookingInsights': data['booking_insights'] ??
            <String, int>{'completed': 0, 'cancelled': 0, 'pending': 0},
        'performanceMetrics': data['performance_metrics'] ??
            <String, double>{'repeatClients': 0, 'avgJobValue': 0},
      };
}
