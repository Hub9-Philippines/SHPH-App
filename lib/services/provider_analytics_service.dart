import '/api/resources/analytics_api.dart';
import '/services/logging_service.dart';

class ProviderAnalyticsService {
  ProviderAnalyticsService._();
  static final ProviderAnalyticsService instance =
      ProviderAnalyticsService._();

  final _analyticsApi = ShphAnalyticsApi.instance;

  Future<Map<String, dynamic>> getAnalytics({String period = 'month'}) async {
    try {
      return await _analyticsApi.getProviderAnalytics(period: period);
    } catch (e) {
      LoggingService.error('Failed to fetch analytics: $e',
          tag: 'ProviderAnalyticsService');
      return {};
    }
  }

  Future<Map<String, dynamic>> getRevenueBreakdown() async {
    try {
      return await _analyticsApi.getRevenueBreakdown();
    } catch (e) {
      LoggingService.error('Failed to fetch revenue breakdown: $e',
          tag: 'ProviderAnalyticsService');
      return {};
    }
  }

  Future<Map<String, dynamic>> getServiceMetrics(int serviceId) async {
    try {
      return await _analyticsApi.getServiceMetrics(serviceId);
    } catch (e) {
      LoggingService.error('Failed to fetch service metrics: $e',
          tag: 'ProviderAnalyticsService');
      return {};
    }
  }
}
