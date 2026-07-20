import '/api/shph_api_client.dart';

/// Analytics endpoints (`/api/analytics/*`).
class ShphAnalyticsApi {
  ShphAnalyticsApi._();

  static final ShphAnalyticsApi instance = ShphAnalyticsApi._();
  final _client = ShphApiClient.instance;

  /// GET /api/analytics/provider/ - get provider analytics
  Future<Map<String, dynamic>> getProviderAnalytics() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/analytics/provider/',
    );
    return response.data ?? {};
  }

  /// GET /api/analytics/provider/bookings/ - get provider booking analytics
  Future<Map<String, dynamic>> getProviderBookingAnalytics() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/analytics/provider/bookings/',
    );
    return response.data ?? {};
  }

  /// GET /api/analytics/provider/revenue/ - get provider revenue analytics
  Future<Map<String, dynamic>> getProviderRevenueAnalytics() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/analytics/provider/revenue/',
    );
    return response.data ?? {};
  }
}
