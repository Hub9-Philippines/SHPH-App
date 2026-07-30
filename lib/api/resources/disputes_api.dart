import '/api/shph_api_client.dart';

class ShphDisputesApi {
  ShphDisputesApi._();

  static final ShphDisputesApi instance = ShphDisputesApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> listDisputes() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/list/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getDispute(String disputeId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/$disputeId/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getDisputeByBooking(String bookingId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/booking/$bookingId/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> createDispute(
      Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/',
      data: payload,
    );
    return response.data ?? {};
  }
}
