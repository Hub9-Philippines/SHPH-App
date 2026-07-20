import 'dart:io';

import '/api/bridges/api_row_mapper.dart';
import '/api/models/service_listing.dart';
import '/api/resources/favorites_api.dart';
import '/api/resources/services_api.dart';
import '/models/service_listing.dart';
import '/services/logging_service.dart';

class ServiceListingService {
  ServiceListingService._();
  static final ServiceListingService instance = ServiceListingService._();
  final _api = ShphServicesApi.instance;

  ServiceListing _map(ShphServiceListing listing) {
    final row = ApiRowMapper.serviceListingToRow(listing);
    return ServiceListing(
      id: row.id,
      category: row.category,
      categoryName: row.categoryName,
      provider: row.provider,
      providerName: row.providerName,
      providerPhoto: row.providerPhoto,
      title: row.title,
      description: row.description,
      basePrice: row.basePrice,
      priceUnit: row.priceUnit,
      status: row.status,
      isAvailable: row.isAvailable,
      rating: row.rating,
      thumbnail: row.thumbnail,
      reviewCount: row.reviewCount,
      isTimeMaterial: row.isTimeMaterial ?? false,
    );
  }

  Future<List<ServiceListing>> fetchRecommendedServices({int limit = 10}) =>
      fetchServiceListings(ordering: '-rating', pageSize: limit);

  Future<List<ServiceListing>> fetchServiceListings({
    String? search,
    String? ordering,
    int? page,
    int? pageSize,
  }) async {
    try {
      final result = await _api.listListings(
        search: search,
        ordering: ordering,
        page: page,
        pageSize: pageSize,
      );
      return result.results.map(_map).toList();
    } catch (e) {
      LoggingService.error('API listing fetch failed: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }

  Future<ServiceListing?> fetchServiceListingById(int id) async {
    try {
      return _map(await _api.getListing(id));
    } catch (e) {
      LoggingService.error('API listing detail failed: $e',
          tag: 'ServiceListingService');
      return null;
    }
  }

  Future<List<ServiceListing>> fetchFavoriteServices() async {
    try {
      return (await ShphFavoritesApi.instance.listFavorites())
          .map(_map)
          .toList();
    } catch (e) {
      LoggingService.error('API favorites failed: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }

  Future<List<ServiceListing>> fetchMyListings() async {
    try {
      return (await _api.listMyListings()).results.map(_map).toList();
    } catch (e) {
      LoggingService.error('API own listings failed: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }

  Future<ServiceListing?> updateListing({
    required int id,
    String? title,
    int? category,
    String? description,
    double? basePrice,
    bool? isAvailable,
  }) async {
    try {
      final data = <String, dynamic>{
        if (title != null) 'title': title,
        if (category != null) 'category': category,
        if (description != null) 'description': description,
        if (basePrice != null) 'base_price': basePrice,
        if (isAvailable != null) 'status': isAvailable ? 'active' : 'draft',
      };
      return _map(await _api.updateListing(id, data));
    } catch (e) {
      LoggingService.error('API listing update failed: $e',
          tag: 'ServiceListingService');
      return null;
    }
  }

  Future<bool> deleteListing(int id) async {
    try {
      await _api.updateListing(id, {'status': 'deleted'});
      return true;
    } catch (e) {
      LoggingService.error('API listing delete failed: $e',
          tag: 'ServiceListingService');
      return false;
    }
  }

  Future<ServiceListing?> archiveListing(int id) async {
    try {
      await _api.archiveListing(id);
      return fetchServiceListingById(id);
    } catch (e) {
      LoggingService.error('API listing archive failed: $e',
          tag: 'ServiceListingService');
      return null;
    }
  }

  Future<ServiceListing?> unarchiveListing(int id) async {
    try {
      await _api.unarchiveListing(id);
      return fetchServiceListingById(id);
    } catch (e) {
      LoggingService.error('API listing unarchive failed: $e',
          tag: 'ServiceListingService');
      return null;
    }
  }

  Future<String?> uploadListingImageFile(int listingId, File imageFile) async {
    try {
      final result = await uploadListingImage(
        listingId,
        fileBytes: await imageFile.readAsBytes(),
        fileName: imageFile.uri.pathSegments.last,
      );
      return (result['image_url'] ?? result['url'] ?? result['image'])
          ?.toString();
    } catch (e) {
      LoggingService.error('API image upload failed: $e',
          tag: 'ServiceListingService');
      return null;
    }
  }

  Future<List<String>> fetchListingImages(int listingId) async {
    try {
      final listing = (await _api.getListing(listingId)).toJson();
      final images = listing['images'];
      if (images is! List) return [];
      return images
          .map((item) {
            if (item is Map)
              return (item['image_url'] ?? item['url'] ?? item['image'])
                  ?.toString();
            return item?.toString();
          })
          .whereType<String>()
          .toList();
    } catch (e) {
      LoggingService.error('API images fetch failed: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }

  Future<bool> deleteListingImage(int imageId) async {
    LoggingService.error('Deleting an image requires its listing ID.',
        tag: 'ServiceListingService');
    return false;
  }

  Future<Map<String, dynamic>> createServiceListing(
          Map<String, dynamic> payload) async =>
      (await _api.createListing(payload)).toJson();

  Future<Map<String, dynamic>> uploadListingImage(
    int listingId, {
    required List<int> fileBytes,
    required String fileName,
  }) =>
      _api.uploadListingImage(listingId,
          fileBytes: fileBytes, fileName: fileName);

  Future<void> deleteListingImageById(int listingId, int imageId) =>
      _api.deleteListingImage(listingId, imageId);

  Future<List<Map<String, dynamic>>> listSubcategories(int categoryId) =>
      _api.listSubcategories(categoryId);
}
