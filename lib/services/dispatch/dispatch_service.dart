import 'dart:async';

import '/api/shph_token_storage.dart';
import '/services/bookings_service.dart';
import '/services/logging_service.dart';
import 'dispatch_models.dart';

/// Service that previously coordinated a realtime dispatch engine.
///
/// The SHPH backend does not have `job_requests`/`dispatch_offers` tables or
/// realtime streams, so the dispatch-specific methods are now stubbed to keep
/// the app compiling. Booking-related operations delegate to
/// [BookingsService] where possible.
class DispatchService {
  DispatchService._();
  static final DispatchService instance = DispatchService._();

  Future<String?> get _currentUserId async {
    final id = await ShphTokenStorage.getCurrentUserId();
    return id?.toString();
  }

  Future<String> createJob({
    required String serviceType,
    required double latitude,
    required double longitude,
    String? bookingId,
    DateTime? requestedTime,
  }) async {
    final userId = await _currentUserId;
    if (userId == null) {
      throw StateError('User must be logged in to create a job request.');
    }

    LoggingService.warning(
      'Dispatch engine is not available in the SHPH backend; '
      'returning a mock job id for booking $bookingId',
      tag: 'DispatchService',
    );

    // Return a stable mock id so callers do not crash.
    return bookingId ?? 'dispatch-job-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<bool> cancelJob(String jobId) async {
    LoggingService.warning(
      'Dispatch cancel not available in the SHPH backend; jobId=$jobId',
      tag: 'DispatchService',
    );
    return false;
  }

  Stream<ClientJobView?> watchClientJob(String jobId) {
    LoggingService.debug(
      'Realtime dispatch watch not available in the SHPH backend; '
      'jobId=$jobId',
      tag: 'DispatchService',
    );
    return const Stream.empty();
  }

  Stream<List<ProviderOfferView>> watchProviderOffers() {
    LoggingService.debug(
      'Realtime provider offers not available in the SHPH backend',
      tag: 'DispatchService',
    );
    return const Stream.empty();
  }

  Future<bool> acceptOffer(String jobId) async {
    LoggingService.warning(
      'Dispatch offer acceptance not available in the SHPH backend; '
      'jobId=$jobId',
      tag: 'DispatchService',
    );
    return false;
  }

  Future<bool> rejectOffer(String jobId) async {
    LoggingService.warning(
      'Dispatch offer rejection not available in the SHPH backend; '
      'jobId=$jobId',
      tag: 'DispatchService',
    );
    return false;
  }

  Future<bool> completeJob(String jobId) async {
    LoggingService.warning(
      'Dispatch complete not available in the SHPH backend; jobId=$jobId',
      tag: 'DispatchService',
    );
    return false;
  }

  Future<DispatchJobRequest?> getJobById(String jobId) async {
    LoggingService.warning(
      'Dispatch job lookup not available in the SHPH backend; jobId=$jobId',
      tag: 'DispatchService',
    );
    return null;
  }

  Future<DispatchOffer?> getOffer(String jobId, String providerId) async {
    LoggingService.warning(
      'Dispatch offer lookup not available in the SHPH backend; '
      'jobId=$jobId providerId=$providerId',
      tag: 'DispatchService',
    );
    return null;
  }

  /// Fetches all job requests created by the current client user.
  Future<List<Map<String, dynamic>>> getClientJobs() async {
    LoggingService.warning(
      'Dispatch client jobs not available in the SHPH backend',
      tag: 'DispatchService',
    );
    return [];
  }

  /// Fetches all bids (dispatch offers) made by the current provider user.
  Future<List<Map<String, dynamic>>> getProviderBids() async {
    LoggingService.warning(
      'Dispatch provider bids not available in the SHPH backend',
      tag: 'DispatchService',
    );
    return [];
  }
}
