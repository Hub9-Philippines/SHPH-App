import 'package:dio/dio.dart';
import '/api/models/category.dart';
import '/api/models/paginated_response.dart';
import '/api/models/service_listing.dart';
import '/api/shph_api_client.dart';

/// Services endpoints from SHPH API.yaml (`/api/services/*`).
class ShphServicesApi {
  ShphServicesApi._();

  static final ShphServicesApi instance = ShphServicesApi._();
  final _client = ShphApiClient.instance;

  Future<PaginatedResponse<ShphCategory>> listCategories({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/categories/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphCategory.fromJson,
    );
  }

  Future<PaginatedResponse<ShphServiceListing>> listListings({
    String? search,
    String? ordering,
    int? page,
    int? pageSize,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/listings/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (ordering != null) 'ordering': ordering,
        if (page != null) 'page': page,
        if (pageSize != null) 'page_size': pageSize,
      },
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphServiceListing.fromJson,
    );
  }

  Future<ShphServiceListing> getListing(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/listings/$id/',
    );
    return ShphServiceListing.fromJson(response.data ?? {});
  }

  Future<PaginatedResponse<ShphServiceListing>> listMyListings({
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/listings/mine/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphServiceListing.fromJson,
    );
  }

  Future<ShphServiceListing> createListing(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/listings/',
      data: payload,
    );
    return ShphServiceListing.fromJson(response.data ?? {});
  }

  Future<ShphServiceListing> updateListing(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/services/listings/$id/',
      data: payload,
    );
    return ShphServiceListing.fromJson(response.data ?? {});
  }

  /// GET /api/services/categories/{parentId}/subcategories/ - get subcategories
  Future<List<Map<String, dynamic>>> listSubcategories(int parentId) async {
    final response = await _client.get<List<dynamic>>(
      '/api/services/categories/$parentId/subcategories/',
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// GET, POST /api/services/availability/ - list or create availability slots
  Future<List<Map<String, dynamic>>> listAvailability({int? providerId}) async {
    final response = await _client.get<List<dynamic>>(
      '/api/services/availability/',
      queryParameters: {if (providerId != null) 'provider_id': providerId},
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// POST /api/services/availability/ - create availability
  Future<Map<String, dynamic>> createAvailability(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/availability/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// PUT /api/services/availability/{id}/ - update availability
  Future<Map<String, dynamic>> updateAvailability(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/api/services/availability/$id/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// DELETE /api/services/availability/{id}/ - delete availability
  Future<void> deleteAvailability(int id) async {
    await _client.delete('/api/services/availability/$id/');
  }

  /// GET /api/services/availability/slots/ - get available time slots
  Future<List<Map<String, dynamic>>> getTimeSlots({
    required int listingId,
    required String date,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/api/services/availability/slots/',
      queryParameters: {'listing_id': listingId, 'date': date},
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// POST /api/services/listings/{id}/images/ - upload listing image
  Future<Map<String, dynamic>> uploadListingImage(
    int listingId, {
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'image': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/listings/$listingId/images/',
      data: formData,
    );
    return response.data ?? {};
  }

  /// DELETE /api/services/listings/{id}/images/{imageId}/ - delete listing image
  Future<void> deleteListingImage(int listingId, int imageId) async {
    await _client.delete('/api/services/listings/$listingId/images/$imageId/');
  }

  /// POST /api/services/listings/{id}/images/reorder/ - reorder listing images
  Future<void> reorderListingImages(
    int listingId,
    List<int> imageIds,
  ) async {
    await _client.post(
      '/api/services/listings/$listingId/images/reorder/',
      data: {'image_ids': imageIds},
    );
  }

  /// POST /api/services/listings/{id}/thumbnail/ - set listing thumbnail
  Future<void> setListingThumbnail(int listingId, int imageId) async {
    await _client.post(
      '/api/services/listings/$listingId/thumbnail/',
      data: {'image_id': imageId},
    );
  }

  /// POST /api/services/listings/{id}/archive/ - archive a listing
  Future<void> archiveListing(int listingId) async {
    await _client.post('/api/services/listings/$listingId/archive/');
  }

  /// POST /api/services/listings/{id}/unarchive/ - unarchive a listing
  Future<void> unarchiveListing(int listingId) async {
    await _client.post('/api/services/listings/$listingId/unarchive/');
  }

  /// GET /api/services/eta/{token}/ - get ETA for a booking
  Future<Map<String, dynamic>> getEta(String token) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/eta/$token/',
    );
    return response.data ?? {};
  }

  /// POST /api/services/reviews/{id}/reply/ - reply to a review
  Future<Map<String, dynamic>> replyToReview(
    int reviewId, {
    required String reply,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/reviews/$reviewId/reply/',
      data: {'reply': reply},
    );
    return response.data ?? {};
  }

  /// GET /api/services/reviews/mine/ - get my reviews
  Future<List<Map<String, dynamic>>> listMyReviews({int? page}) async {
    final response = await _client.get<List<dynamic>>(
      '/api/services/reviews/mine/',
      queryParameters: {if (page != null) 'page': page},
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }
}
