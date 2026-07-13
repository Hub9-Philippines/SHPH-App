import '/api/shph_api_client.dart';

/// Payout / earnings endpoints (`/api/payouts/*`).
class ShphPayoutsApi {
  ShphPayoutsApi._();

  static final ShphPayoutsApi instance = ShphPayoutsApi._();
  final _client = ShphApiClient.instance;

  /// GET /api/payouts/ - list my payout requests
  Future<List<Map<String, dynamic>>> listMyPayouts() async {
    final response = await _client.get<List<dynamic>>('/api/payouts/');
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// POST /api/payouts/ - request a new payout
  Future<Map<String, dynamic>> requestPayout(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/payouts/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// POST /api/payouts/{id}/cancel/ - cancel a pending payout request
  Future<void> cancelPayout(String id) async {
    await _client.post('/api/payouts/$id/cancel/');
  }

  /// GET /api/payouts/earnings/ - get earnings summary
  Future<Map<String, dynamic>> getEarningsSummary() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/payouts/earnings/',
    );
    return response.data ?? {};
  }
}
