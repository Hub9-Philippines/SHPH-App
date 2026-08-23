import '/api/shph_api_client.dart';

class ShphOnDemandJobsApi {
  ShphOnDemandJobsApi._();

  static final ShphOnDemandJobsApi instance = ShphOnDemandJobsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getClientJobs() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/client/jobs/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> createJob(Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/',
      data: payload,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getJobStatus(String jobId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/',
    );
    return response.data ?? {};
  }

  Future<void> cancelJob(String jobId) async {
    await _client.post('/api/services/on-demand/$jobId/cancel/');
  }
}
