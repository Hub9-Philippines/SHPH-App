import '/api/models/wallet_transaction.dart';
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

  /// POST alternative documented for retrieving the current wallet.
  Future<Map<String, dynamic>> getWalletViaPost() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> createTopUpIntent({
    required double amount,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/topup/create-intent/',
      data: {'amount': amount},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> confirmTopUp({
    required String intentId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/topup/confirm/',
      data: {'intent_id': intentId},
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

  /// GET /api/wallet/transactions/ — typed list
  Future<List<WalletTransaction>> listWalletTransactions() async {
    final response = await _client.get<List<dynamic>>(
      '/api/wallet/transactions/',
    );
    final data = response.data ?? [];
    return data
        .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> payBookingWithWallet(String bookingId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/wallet/pay-booking/$bookingId/',
    );
    return response.data ?? {};
  }
}
