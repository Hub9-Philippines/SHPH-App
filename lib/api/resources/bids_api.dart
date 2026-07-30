import '/api/shph_api_client.dart';

class ShphBidsApi {
  ShphBidsApi._();

  static final ShphBidsApi instance = ShphBidsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> listBids({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/bids/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> createBid(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/bids/',
      data: payload,
    );
    return response.data ?? {};
  }

  Future<void> withdrawBid(String bidId) async {
    await _client.post('/api/services/bids/$bidId/withdraw/');
  }
}
