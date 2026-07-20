import 'package:dio/dio.dart';

import '/api/models/on_demand_bid.dart';
import '/api/models/on_demand_job.dart';
import '/api/models/paginated_response.dart';
import '/api/shph_api_client.dart';

/// On-demand booking/bidding endpoints from SHPH web API.
///
/// Mirrors the Django views under `/api/services/on-demand/*`.
class ShphOnDemandApi {
  ShphOnDemandApi._();

  static final ShphOnDemandApi instance = ShphOnDemandApi._();
  final _client = ShphApiClient.instance;

  /// POST /api/services/on-demand/ — client broadcasts an on-demand job.
  Future<ShphOnDemandJob> createJob(ShphOnDemandJob job) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/',
      data: job.toCreateJson(),
    );
    return ShphOnDemandJob.fromJson(response.data ?? {});
  }

  /// GET /api/services/on-demand/estimate/ — preview fee estimate.
  Future<Map<String, dynamic>> getFeeEstimate({
    required int categoryId,
    required double lat,
    required double lng,
    int radiusKm = 4,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/on-demand/estimate/',
      queryParameters: {
        'category_id': categoryId,
        'lat': lat,
        'lng': lng,
        'radius': radiusKm,
      },
    );
    return response.data ?? {};
  }

  /// GET /api/services/on-demand/<id>/ — poll job status.
  Future<ShphOnDemandJob> getJobStatus(int jobId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/',
    );
    return ShphOnDemandJob.fromJson(response.data ?? {});
  }

  /// POST /api/services/on-demand/<id>/accept/ — provider expresses interest.
  Future<Map<String, dynamic>> acceptJob(int jobId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/accept/',
    );
    return response.data ?? {};
  }

  /// GET /api/services/on-demand/<id>/bids/ — client lists bids for a job.
  Future<List<ShphOnDemandBid>> listJobBids(int jobId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/bids/',
    );
    final data = response.data ?? {};
    final bids = data['bids'];
    if (bids is! List) return [];
    return bids
        .whereType<Map<String, dynamic>>()
        .map(ShphOnDemandBid.fromJson)
        .toList();
  }

  /// POST /api/services/on-demand/<id>/bids/<bid_id>/withdraw/ — provider withdraws a bid.
  Future<Map<String, dynamic>> withdrawBid(int jobId, int bidId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/bids/$bidId/withdraw/',
    );
    return response.data ?? {};
  }

  /// POST /api/services/on-demand/<id>/select/ — client picks a provider bid.
  Future<Map<String, dynamic>> selectBid(int jobId, int bidId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/select/',
      data: {'bid_id': bidId},
    );
    return response.data ?? {};
  }

  /// POST /api/services/on-demand/<id>/cancel-quote/ — preview cancellation fee.
  Future<Map<String, dynamic>> cancelQuote(int jobId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/cancel-quote/',
    );
    return response.data ?? {};
  }

  /// POST /api/services/on-demand/<id>/cancel/ — client cancels the job.
  Future<Map<String, dynamic>> cancelJob(int jobId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/cancel/',
    );
    return response.data ?? {};
  }

  /// POST /api/services/on-demand/<id>/expand-radius/ — widen provider search radius.
  Future<Map<String, dynamic>> expandRadius(
    int jobId, {
    required int newRadiusKm,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/$jobId/expand-radius/',
      data: {'radius_km': newRadiusKm},
    );
    return response.data ?? {};
  }

  /// POST /api/services/on-demand/upload-photo/ — upload job evidence/photo.
  Future<Map<String, dynamic>> uploadPhoto({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/on-demand/upload-photo/',
      data: formData,
    );
    return response.data ?? {};
  }

  /// GET /api/services/on-demand/provider/bids/ — provider's own bids.
  Future<PaginatedResponse<ShphOnDemandBid>> listProviderBids({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/on-demand/provider/bids/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphOnDemandBid.fromJson,
    );
  }

  /// GET /api/services/on-demand/client/jobs/ — client's on-demand jobs.
  Future<PaginatedResponse<ShphOnDemandJob>> listClientJobs({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/on-demand/client/jobs/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphOnDemandJob.fromJson,
    );
  }

  /// GET /api/services/on-demand/pending/ — provider sees nearby pending jobs.
  Future<PaginatedResponse<ShphOnDemandJob>> listPendingJobs({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/on-demand/pending/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphOnDemandJob.fromJson,
    );
  }
}
