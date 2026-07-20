import '/api/models/on_demand_bid.dart';
import '/api/models/on_demand_job.dart';
import '/api/resources/on_demand_api.dart';
import '/services/logging_service.dart';

/// Service wrapper for the SHPH on-demand booking/bidding API.
///
/// Keeps the API layer thin and surfaces simple success/failure helpers
/// for the Flutter UI layer.
class OnDemandService {
  OnDemandService._();
  static final OnDemandService instance = OnDemandService._();

  final _api = ShphOnDemandApi.instance;

  /// Request a fee estimate before broadcasting a job.
  Future<Map<String, dynamic>> estimateFee({
    required int categoryId,
    required double lat,
    required double lng,
    int radiusKm = 4,
  }) async {
    try {
      return await _api.getFeeEstimate(
        categoryId: categoryId,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      );
    } catch (e) {
      LoggingService.error('On-demand fee estimate failed: $e',
          tag: 'OnDemandService');
      rethrow;
    }
  }

  /// Client creates and broadcasts an on-demand job.
  Future<ShphOnDemandJob?> createJob(ShphOnDemandJob draft) async {
    try {
      return await _api.createJob(draft);
    } catch (e) {
      LoggingService.error('On-demand job creation failed: $e',
          tag: 'OnDemandService');
      return null;
    }
  }

  /// Poll the current status of a job.
  Future<ShphOnDemandJob?> getJobStatus(int jobId) async {
    try {
      return await _api.getJobStatus(jobId);
    } catch (e) {
      LoggingService.error('On-demand job status failed: $e',
          tag: 'OnDemandService');
      return null;
    }
  }

  /// Client lists bids on their job.
  Future<List<ShphOnDemandBid>> listJobBids(int jobId) async {
    try {
      return await _api.listJobBids(jobId);
    } catch (e) {
      LoggingService.error('On-demand job bids failed: $e',
          tag: 'OnDemandService');
      return [];
    }
  }

  /// Provider expresses interest in a pending job.
  Future<Map<String, dynamic>?> acceptJob(int jobId) async {
    try {
      return await _api.acceptJob(jobId);
    } catch (e) {
      LoggingService.error('On-demand job accept failed: $e',
          tag: 'OnDemandService');
      return null;
    }
  }

  /// Provider withdraws their bid.
  Future<Map<String, dynamic>?> withdrawBid(int jobId, int bidId) async {
    try {
      return await _api.withdrawBid(jobId, bidId);
    } catch (e) {
      LoggingService.error('On-demand bid withdraw failed: $e',
          tag: 'OnDemandService');
      return null;
    }
  }

  /// Client selects a provider bid.
  Future<Map<String, dynamic>?> selectBid(int jobId, int bidId) async {
    try {
      return await _api.selectBid(jobId, bidId);
    } catch (e) {
      LoggingService.error('On-demand bid selection failed: $e',
          tag: 'OnDemandService');
      return null;
    }
  }

  /// Client cancels the job.
  Future<Map<String, dynamic>?> cancelJob(int jobId) async {
    try {
      return await _api.cancelJob(jobId);
    } catch (e) {
      LoggingService.error('On-demand job cancel failed: $e',
          tag: 'OnDemandService');
      return null;
    }
  }

  /// Client previews the cancellation fee.
  Future<Map<String, dynamic>?> cancelQuote(int jobId) async {
    try {
      return await _api.cancelQuote(jobId);
    } catch (e) {
      LoggingService.error('On-demand cancel quote failed: $e',
          tag: 'OnDemandService');
      return null;
    }
  }

  /// Client expands the provider search radius.
  Future<Map<String, dynamic>?> expandRadius(
    int jobId, {
    required int newRadiusKm,
  }) async {
    try {
      return await _api.expandRadius(jobId, newRadiusKm: newRadiusKm);
    } catch (e) {
      LoggingService.error('On-demand radius expand failed: $e',
          tag: 'OnDemandService');
      return null;
    }
  }

  /// Provider sees jobs they can bid on nearby.
  Future<List<ShphOnDemandJob>> listPendingJobs({int? page}) async {
    try {
      final response = await _api.listPendingJobs(page: page);
      return response.results;
    } catch (e) {
      LoggingService.error('On-demand pending jobs failed: $e',
          tag: 'OnDemandService');
      return [];
    }
  }

  /// Provider sees their own bids/history.
  Future<List<ShphOnDemandBid>> listProviderBids({int? page}) async {
    try {
      final response = await _api.listProviderBids(page: page);
      return response.results;
    } catch (e) {
      LoggingService.error('On-demand provider bids failed: $e',
          tag: 'OnDemandService');
      return [];
    }
  }

  /// Client sees their on-demand job history.
  Future<List<ShphOnDemandJob>> listClientJobs({int? page}) async {
    try {
      final response = await _api.listClientJobs(page: page);
      return response.results;
    } catch (e) {
      LoggingService.error('On-demand client jobs failed: $e',
          tag: 'OnDemandService');
      return [];
    }
  }
}
