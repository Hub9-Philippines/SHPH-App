import '/api/shph_api_client.dart';

/// Analytics endpoints from SHPH API (`/api/analytics/*`).
class ShphAnalyticsApi {
  ShphAnalyticsApi._();

  static final ShphAnalyticsApi instance = ShphAnalyticsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getProviderAnalytics({
    String period = '30d',
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/analytics/provider/',
      data: {'period': period},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getRevenueBreakdown() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/analytics/revenue/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getServiceMetrics(int serviceId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/analytics/services/$serviceId/',
    );
    return response.data ?? {};
  }

  Future<void> trackInteraction({
    required String eventType,
    int? listingId,
    String? query,
    Map<String, dynamic>? context,
  }) async {
    await _client.post(
      '/api/analytics/interactions/',
      data: {
        'event_type': eventType,
        if (listingId != null) 'listing_id': listingId,
        if (query != null) 'query': query,
        if (context != null) 'context': context,
      },
    );
  }
}
