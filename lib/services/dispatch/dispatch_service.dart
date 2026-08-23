import '/api/resources/ondemand_jobs_api.dart';
import '/auth/base_auth_user_provider.dart';
import '/services/logging_service.dart';

import 'dispatch_models.dart';

class DispatchService {
  DispatchService._();
  static final DispatchService instance = DispatchService._();

  final _jobsApi = ShphOnDemandJobsApi.instance;

  String? get _currentUserId => currentUser?.uid;

  Future<String> createJob({
    required String serviceType,
    required double latitude,
    required double longitude,
    String? bookingId,
    DateTime? requestedTime,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw StateError('User must be logged in to create a job request.');
    }

    final payload = {
      'client_id': userId,
      'service_type': serviceType,
      'location_lat': latitude,
      'location_lng': longitude,
      'requested_time': (requestedTime ?? DateTime.now()).toIso8601String(),
      'status': 'searching',
      if (bookingId != null) 'booking_id': bookingId,
    };

    try {
      final response = await _jobsApi.createJob(payload);
      return (response['id'] ?? response['job_id'] ?? '').toString();
    } catch (e) {
      LoggingService.error(
        'Failed to create job request: $e',
        tag: 'DispatchService',
      );
      rethrow;
    }
  }

  Future<bool> cancelJob(String jobId) async {
    try {
      await _jobsApi.cancelJob(jobId);
      return true;
    } catch (e) {
      LoggingService.error(
        'Failed to cancel job: $e',
        tag: 'DispatchService',
      );
      return false;
    }
  }

  Stream<ClientJobView?> watchClientJob(String jobId) async* {
    while (true) {
      final job = await getJobById(jobId);
      yield job == null ? null : _buildClientView(job, jobId);
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  ClientJobView _buildClientView(DispatchJobRequest job, String jobId) {
    final providerId = job.assignedProviderId;
    return ClientJobView(
      job: job,
      offer: providerId == null
          ? null
          : DispatchOffer(
              id: jobId,
              jobId: jobId,
              providerId: providerId,
              status: OfferStatus.accepted,
              offeredAt: DateTime.now(),
            ),
      providerProfile: null,
    );
  }

  Stream<List<ProviderOfferView>> watchProviderOffers() async* {
    while (true) {
      try {
        final jobs = await _jobsApi.getClientJobs();
        final views = <ProviderOfferView>[];
        final list = jobs['results'] as List? ?? jobs['jobs'] as List?;
        if (list != null) {
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              views.add(ProviderOfferView(
                offer: DispatchOffer(
                  id: item['id']?.toString() ?? '',
                  jobId: item['id']?.toString() ?? '',
                  providerId: _currentUserId ?? '',
                  status: OfferStatus.pending,
                  offeredAt: DateTime.now(),
                ),
                job: DispatchJobRequest.fromJson(item),
                clientDisplayName: item['client_name'] as String?,
              ));
            }
          }
        }
        yield views;
      } catch (e) {
        LoggingService.error(
          'Failed to watch provider offers: $e',
          tag: 'DispatchService',
        );
        yield const [];
      }
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  Future<bool> acceptOffer(String jobId) => completeJob(jobId);

  Future<bool> rejectOffer(String jobId) => cancelJob(jobId);

  Future<bool> completeJob(String jobId) async {
    try {
      final data = await _jobsApi.getJobStatus(jobId);
      return data.isNotEmpty;
    } catch (e) {
      LoggingService.error(
        'Failed to complete job: $e',
        tag: 'DispatchService',
      );
      return false;
    }
  }

  Future<DispatchJobRequest?> getJobById(String jobId) async {
    try {
      final response = await _jobsApi.getJobStatus(jobId);
      if (response.isEmpty) {
        return null;
      }
      return DispatchJobRequest.fromJson(response);
    } catch (e) {
      LoggingService.error(
        'Failed to fetch job: $e',
        tag: 'DispatchService',
      );
      return null;
    }
  }

  Future<DispatchOffer?> getOffer(String jobId, String providerId) async {
    final job = await getJobById(jobId);
    if (job == null) {
      return null;
    }
    return DispatchOffer(
      id: jobId,
      jobId: jobId,
      providerId: providerId,
      status: OfferStatus.pending,
      offeredAt: DateTime.now(),
    );
  }
}
