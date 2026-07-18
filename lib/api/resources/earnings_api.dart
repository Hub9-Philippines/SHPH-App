import '/api/shph_api_client.dart';

/// Earnings endpoints from SHPH API (`/api/earnings/*`).
class ShphEarningsApi {
  ShphEarningsApi._();

  static final ShphEarningsApi instance = ShphEarningsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getSummary() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/earnings/summary/',
    );
    return response.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getTransactions({
    int? page,
    int? pageSize,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/earnings/transactions/',
      queryParameters: {
        if (page != null) 'page': page,
        if (pageSize != null) 'page_size': pageSize,
      },
    );
    final data = response.data;
    if (data is List) {
      return (data! as List).whereType<Map<String, dynamic>>().toList();
    }
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> requestPayout(
    double amount,
    int paymentMethodId,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/earnings/payout/',
      data: {
        'amount': amount,
        'payment_method_id': paymentMethodId,
      },
    );
    return response.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getPayouts() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/earnings/payouts/',
    );
    final data = response.data;
    if (data is List) {
      return (data! as List).whereType<Map<String, dynamic>>().toList();
    }
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
