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
    double? latitude,
    double? longitude,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/listings/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (ordering != null) 'ordering': ordering,
        if (page != null) 'page': page,
        if (pageSize != null) 'page_size': pageSize,
        // Backend computes distance_km when both are supplied.
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
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

  Future<Map<String, dynamic>> listSubcategories(int parentId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/categories/$parentId/subcategories/',
    );
    return response.data ?? {};
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

  Future<void> deleteListing(int id) async {
    await _client.delete('/api/services/listings/$id/');
  }

  Future<Map<String, dynamic>> archiveListing(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/listings/$id/archive/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> unarchiveListing(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/listings/$id/unarchive/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> uploadListingThumbnail(
    int id,
    String filePath,
  ) async {
    final formData = FormData.fromMap({
      'thumbnail': await MultipartFile.fromFile(filePath),
    });
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/listings/$id/upload-thumbnail/',
      data: formData,
    );
    return response.data ?? {};
  }
}
