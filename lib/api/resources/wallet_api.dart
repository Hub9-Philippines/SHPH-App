import '/api/shph_api_client.dart';

class ShphWalletApi {
  ShphWalletApi._();

  static final ShphWalletApi instance = ShphWalletApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getWallet() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/wallet/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> updateWallet(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/',
      data: payload,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> createTopUpIntent({
    required int amount,
    required String currency,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/topup/create-intent/',
      data: {'amount': amount, 'currency': currency},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> confirmTopUp({
    required String paymentIntentId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/topup/confirm/',
      data: {'payment_intent_id': paymentIntentId},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> listTransactions({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/wallet/transactions/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> payBookingWithWallet(String bookingId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/pay-booking/$bookingId/',
    );
    return response.data ?? {};
  }
}
