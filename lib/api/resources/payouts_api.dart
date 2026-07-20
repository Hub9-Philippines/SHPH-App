import '/api/shph_api_client.dart';

/// Payout / earnings endpoints (`/api/earnings/*`).
class ShphPayoutsApi {
  ShphPayoutsApi._();

  static final ShphPayoutsApi instance = ShphPayoutsApi._();
  final _client = ShphApiClient.instance;

  /// GET /api/payouts/ - list my payout requests
  Future<List<Map<String, dynamic>>> listMyPayouts() async {
    final response = await _client.get<dynamic>('/api/earnings/payouts/');
    final data = response.data;
    final rows = data is List ? data : (data is Map ? data['results'] : null);
    return (rows as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  /// POST /api/payouts/ - request a new payout
  Future<Map<String, dynamic>> requestPayout(
      Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/earnings/payout/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// Cancellation is represented by the payout endpoint's action payload.
  Future<void> cancelPayout(String id) async {
    await _client.post('/api/earnings/payout/', data: {
      'payout_id': id,
      'action': 'cancel',
    });
  }

  /// GET /api/payouts/earnings/ - get earnings summary
  Future<Map<String, dynamic>> getEarningsSummary() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/earnings/summary/',
    );
    return response.data ?? {};
  }
}
