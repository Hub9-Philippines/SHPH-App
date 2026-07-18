import 'dart:io';

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

  Future<Map<String, dynamic>> uploadListingImage(
    int listingId,
    File file,
  ) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/listings/$listingId/images/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data ?? {};
  }

  /// GET `/api/services/categories/<parentId>/subcategories/`.
  Future<PaginatedResponse<ShphCategory>> listSubcategories(
    int parentId, {
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/categories/$parentId/subcategories/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphCategory.fromJson,
    );
  }

  /// GET `/api/services/listings/?category=<id>` — listings filtered by category.
  ///
  /// Used by CategoryDetailPage. The backend exposes category filtering as a
  /// query parameter on the standard listings endpoint (no dedicated
  /// category-detail endpoint exists).
  Future<PaginatedResponse<ShphServiceListing>> listListingsByCategory(
    int categoryId, {
    double? lat,
    double? lng,
    int? radiusKm,
    String? ordering,
    int? page,
    int? pageSize,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/listings/',
      queryParameters: {
        'category': categoryId,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (radiusKm != null) 'radius_km': radiusKm,
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

  /// POST `/api/services/bookings/<pk>/share-eta/` — create a public ETA share link.
  Future<Map<String, dynamic>> shareEta(String bookingId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/bookings/$bookingId/share-eta/',
    );
    return response.data ?? {};
  }

  /// GET `/api/services/eta/<token>/` — public ETA lookup (no auth required).
  ///
  /// Used by EtaTrackingPage. The token is a UUID issued by `shareEta`.
  Future<Map<String, dynamic>> getPublicEta(String token) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/eta/$token/',
    );
    return response.data ?? {};
  }

  /// POST `/api/services/availability/` — list/create availability slots.
  Future<List<Map<String, dynamic>>> listAvailability() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/availability/',
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  /// POST `/api/services/availability/` — create a new availability slot.
  Future<Map<String, dynamic>> createAvailabilitySlot(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/availability/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// PATCH `/api/services/availability/<pk>/` — update an availability slot.
  Future<Map<String, dynamic>> updateAvailabilitySlot(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/services/availability/$id/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// DELETE `/api/services/availability/<pk>/` — delete an availability slot.
  Future<void> deleteAvailabilitySlot(int id) async {
    await _client.delete('/api/services/availability/$id/');
  }

  /// POST `/api/services/listings/<id>/archive/` — archive a listing.
  Future<Map<String, dynamic>> archiveListing(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/listings/$id/archive/',
    );
    return response.data ?? {};
  }

  /// DELETE `/api/services/listings/<id>/` — delete a listing.
  Future<void> deleteListing(int id) async {
    await _client.delete('/api/services/listings/$id/');
  }
}
