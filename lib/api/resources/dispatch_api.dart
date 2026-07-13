import '/api/shph_api_client.dart';

/// Dispatch / on-demand job endpoints (`/api/dispatch/*`).
class ShphDispatchApi {
  ShphDispatchApi._();

  static final ShphDispatchApi instance = ShphDispatchApi._();
  final _client = ShphApiClient.instance;

  /// POST /api/dispatch/jobs/ - create a new job request
  Future<Map<String, dynamic>> createJob(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/dispatch/jobs/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// GET /api/dispatch/jobs/{id}/ - get job by ID
  Future<Map<String, dynamic>> getJob(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/dispatch/jobs/$id/',
    );
    return response.data ?? {};
  }

  /// POST /api/dispatch/jobs/{id}/cancel/ - cancel a job
  Future<void> cancelJob(String id) async {
    await _client.post('/api/dispatch/jobs/$id/cancel/');
  }

  /// POST /api/dispatch/jobs/{id}/complete/ - mark job complete
  Future<void> completeJob(String id) async {
    await _client.post('/api/dispatch/jobs/$id/complete/');
  }

  /// GET /api/dispatch/offers/ - list offers (filter by provider_id, job_id)
  Future<List<Map<String, dynamic>>> listOffers({
    String? jobId,
    String? providerId,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/api/dispatch/offers/',
      queryParameters: {
        if (jobId != null) 'job_id': jobId,
        if (providerId != null) 'provider_id': providerId,
      },
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// POST /api/dispatch/offers/{id}/accept/ - accept a dispatch offer
  Future<void> acceptOffer(String id) async {
    await _client.post('/api/dispatch/offers/$id/accept/');
  }

  /// POST /api/dispatch/offers/{id}/reject/ - reject a dispatch offer
  Future<void> rejectOffer(String id) async {
    await _client.post('/api/dispatch/offers/$id/reject/');
  }
}
