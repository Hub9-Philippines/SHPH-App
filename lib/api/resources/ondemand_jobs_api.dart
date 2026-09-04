import '/api/shph_api_client.dart';

/// SHPH on-demand job endpoints (`/api/services/on-demand/*`).
///
/// Matches SHPH API.yaml field shapes: `OnDemandJobRequest` and
/// `OnDemandJobCreateResponse`.
class ShphOnDemandJobsApi {
  ShphOnDemandJobsApi._();

  static final ShphOnDemandJobsApi instance = ShphOnDemandJobsApi._();
  final _client = ShphApiClient.instance;

  /// Broadcast an on-demand job request to nearby providers via WebSocket.
  /// Returns the server `OnDemandJobCreateResponse` ({job_id, status,
  /// provider_count, estimated_fee_min/max, expires_at}).
  Future<Map<String, dynamic>> createJob(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// Poll the status of an on-demand job (searching / accepted / expired /
  /// cancelled). Includes booking details when the job is accepted.
  Future<Map<String, dynamic>> getJobStatus(String jobId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/',
    );
    return response.data ?? {};
  }

  /// Client expands the search radius of an active searching job.
  Future<Map<String, dynamic>> expandRadius(
    String jobId,
    int radiusKm,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/expand-radius/',
      data: {'radius_km': radiusKm},
    );
    return response.data ?? {};
  }

  /// Estimated fee range + nearest-provider distance for a category near a
  /// location. Path: GET /services/on-demand/estimate/
  ///   ?category_id=X&lat=Y&lng=Z&radius=4
  Future<Map<String, dynamic>> estimate({
    required int categoryId,
    required double latitude,
    required double longitude,
    int radiusKm = 4,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/on-demand/estimate/',
      queryParameters: {
        'category_id': categoryId,
        'lat': latitude,
        'lng': longitude,
        'radius': radiusKm,
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getClientJobs() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/client/jobs/',
    );
    return response.data ?? {};
  }

  Future<void> cancelJob(String jobId) async {
    await _client.post('/api/services/on-demand/$jobId/cancel/');
  }
}
