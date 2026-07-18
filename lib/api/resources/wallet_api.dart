import '/api/shph_api_client.dart';

/// Wallet endpoints from SHPH API (`/api/wallet/*`).
class ShphWalletApi {
  ShphWalletApi._();

  static final ShphWalletApi instance = ShphWalletApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getBalance() async {
    final response = await _client.get<Map<String, dynamic>>('/api/wallet/');
    return response.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/wallet/transactions/',
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

  Future<Map<String, dynamic>> topUpCreateIntent(double amount) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/topup/create-intent/',
      data: {'amount': amount},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> topUpConfirm(String intentId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/topup/confirm/',
      data: {'intent_id': intentId},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> payBooking(String bookingId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/pay-booking/$bookingId/',
    );
    return response.data ?? {};
  }
}
