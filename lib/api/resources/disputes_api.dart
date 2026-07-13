import '/api/shph_api_client.dart';

/// Dispute endpoints (`/api/disputes/*`).
class ShphDisputesApi {
  ShphDisputesApi._();

  static final ShphDisputesApi instance = ShphDisputesApi._();
  final _client = ShphApiClient.instance;

  /// GET /api/disputes/ - list my disputes
  Future<List<Map<String, dynamic>>> listDisputes() async {
    final response = await _client.get<List<dynamic>>('/api/disputes/');
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// POST /api/disputes/ - create a dispute
  Future<Map<String, dynamic>> createDispute(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// GET /api/disputes/{id}/ - get dispute details
  Future<Map<String, dynamic>> getDispute(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/disputes/$id/',
    );
    return response.data ?? {};
  }

  /// POST /api/disputes/{id}/evidence/ - upload dispute evidence
  Future<Map<String, dynamic>> uploadEvidence(
    String disputeId, {
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/$disputeId/evidence/',
      data: payload,
    );
    return response.data ?? {};
  }
}
