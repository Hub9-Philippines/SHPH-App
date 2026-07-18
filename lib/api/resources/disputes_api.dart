import 'package:dio/dio.dart';

import '/api/shph_api_client.dart';

/// Disputes endpoints from SHPH API (`/api/disputes/*`).
class ShphDisputesApi {
  ShphDisputesApi._();

  static final ShphDisputesApi instance = ShphDisputesApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> createDispute({
    required String bookingId,
    required String reason,
    required String description,
    String? evidence,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/',
      data: {
        'booking': bookingId,
        'reason': reason,
        'description': description,
        if (evidence != null) 'evidence': evidence,
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> uploadEvidence(
    int disputeId,
    String filePath,
    String fileName,
  ) async {
    final formData = FormData.fromMap({
      'evidence': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/$disputeId/evidence/',
      data: formData,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getDispute(int disputeId) async {
    final response = await _client.get<Map<String, dynamic>>(
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

  Future<List<Map<String, dynamic>>> listDisputes() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/disputes/list/',
    );
    final data = response.data;
    if (data is List) {
      return (data! as List).whereType<Map<String, dynamic>>().toList();
    }
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    final disputes = data?['disputes'];
    if (disputes is List) {
      return disputes.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
