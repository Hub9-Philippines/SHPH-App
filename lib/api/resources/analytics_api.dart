import '/api/shph_api_client.dart';

class ShphAnalyticsApi {
  ShphAnalyticsApi._();

  static final ShphAnalyticsApi instance = ShphAnalyticsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getProviderAnalytics({
    String period = 'month',
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/analytics/provider/',
      queryParameters: {'period': period},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getRevenueBreakdown() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/analytics/revenue-breakdown/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getServiceMetrics(int serviceId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/analytics/services/$serviceId/metrics/',
    );
    return response.data ?? {};
  }
}
