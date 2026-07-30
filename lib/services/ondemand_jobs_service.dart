import '/api/resources/ondemand_jobs_api.dart';
import '/services/logging_service.dart';

class OnDemandJobsService {
  OnDemandJobsService._();
  static final OnDemandJobsService instance = OnDemandJobsService._();

  final _api = ShphOnDemandJobsApi.instance;

  Future<List<Map<String, dynamic>>> getClientJobs() async {
    try {
      final resp = await _api.getClientJobs();
      final results = resp['results'] ?? resp['jobs'];
      if (results is List) {
        return results.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggingService.error('Error fetching client jobs: $e',
          tag: 'OnDemandJobsService');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createJob(Map<String, dynamic> payload) async {
    try {
      final resp = await _api.createJob(payload);
      return resp['id'] != null ? resp : null;
    } catch (e) {
      LoggingService.error('Error creating on-demand job: $e',
          tag: 'OnDemandJobsService');
      return null;
    }
  }

  Future<bool> cancelJob(String jobId) async {
    try {
      await _api.cancelJob(jobId);
      return true;
    } catch (e) {
      LoggingService.error('Error cancelling job: $e',
          tag: 'OnDemandJobsService');
      return false;
    }
  }
}
