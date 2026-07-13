import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/api/bridges/api_row_mapper.dart';
import '/api/models/service_listing.dart';
import '/api/resources/favorites_api.dart';
import '/api/resources/services_api.dart';
import '/backend/supabase/database/tables/service_listings.dart';
import '/models/service_listing.dart';
import '/services/logging_service.dart';

class ServiceListingService {
  ServiceListingService._();

  static final ServiceListingService instance = ServiceListingService._();
  final _servicesApi = ShphServicesApi.instance;

  ServiceListing _rowToServiceListing(ServiceListingsRow row) {
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

  ServiceListing _apiToServiceListing(ShphServiceListing listing) {
    final row = ApiRowMapper.serviceListingToRow(listing);
    return _rowToServiceListing(row);
  }

  Future<List<ServiceListing>> fetchRecommendedServices(
      {int limit = 10}) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _servicesApi.listListings(
          ordering: '-rating',
          pageSize: limit,
        );
        return page.results.map(_apiToServiceListing).toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API fetchRecommendedServices failed, falling back to Supabase: $e',
          tag: 'ServiceListingService',
        );
      }
    }

    try {
      final services = await ServiceListingsTable().queryRows(
        queryFn: (q) => q
            .order('rating', ascending: false)
            .order('review_count', ascending: false)
            .limit(limit),
      );

      return services.map(_rowToServiceListing).toList();
    } catch (e) {
      LoggingService.error('Error fetching recommended services: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }

  Future<List<ServiceListing>> fetchServiceListings({
    String? search,
    String? ordering,
    int? page,
    int? pageSize,
  }) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final pageResult = await _servicesApi.listListings(
          search: search,
          ordering: ordering,
          page: page,
          pageSize: pageSize,
        );
        return pageResult.results.map(_apiToServiceListing).toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API fetchServiceListings failed, falling back to Supabase: $e',
          tag: 'ServiceListingService',
        );
      }
    }

    try {
      final services = await ServiceListingsTable().queryRows(
        queryFn: (q) {
          var query = q as dynamic;

          if (search != null && search.isNotEmpty) {
            query = query.ilike('title', '%$search%');
          }

          if (ordering != null) {
            final isAscending = !ordering.startsWith('-');
            final field = isAscending ? ordering : ordering.substring(1);
            query = query.order(field, ascending: isAscending);
          }

          return query;
        },
        limit: pageSize,
      );

      return services.map(_rowToServiceListing).toList();
    } catch (e) {
      LoggingService.error('Error fetching service listings: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }

  Future<ServiceListing?> fetchServiceListingById(int id) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final listing = await _servicesApi.getListing(id);
        return _apiToServiceListing(listing);
      } catch (e) {
        LoggingService.error(
          'SHPH API fetchServiceListingById failed, falling back to Supabase: $e',
          tag: 'ServiceListingService',
        );
      }
    }

    try {
      final services = await ServiceListingsTable().querySingleRow(
        queryFn: (q) => q.eq('id', id),
      );

      if (services.isNotEmpty) {
        return _rowToServiceListing(services.first);
      }
      return null;
    } catch (e) {
      LoggingService.error('Error fetching service listing: $e',
          tag: 'ServiceListingService');
      return null;
    }
  }

  Future<List<ServiceListing>> fetchFavoriteServices() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final favorites = await ShphFavoritesApi.instance.listFavorites();
        return favorites.map(_apiToServiceListing).toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API fetchFavoriteServices failed: $e',
          tag: 'ServiceListingService',
        );
      }
    }

    return [];
  }

  Future<List<ServiceListing>> fetchMyListings() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _servicesApi.listMyListings();
        return page.results.map(_apiToServiceListing).toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API fetchMyListings failed, falling back to Supabase: $e',
          tag: 'ServiceListingService',
        );
      }
    }

    try {
      final services = await ServiceListingsTable().queryRows(
        queryFn: (q) => q
            .eq('provider', userId)
            .order('created_at', ascending: false),
      );
      return services.map(_rowToServiceListing).toList();
    } catch (e) {
      LoggingService.error('Error fetching my listings: $e',
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
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (category != null) updates['category'] = category;
    if (description != null) updates['description'] = description;
    if (basePrice != null) updates['base_price'] = basePrice;
    if (isAvailable != null) {
      updates['status'] = isAvailable ? 'active' : 'draft';
    }
    updates['updated_at'] = DateTime.now().toIso8601String();

    if (await ApiRowMapper.canUseApi()) {
      try {
        final updated = await _servicesApi.updateListing(id, updates);
        return _apiToServiceListing(updated);
      } catch (e) {
        LoggingService.error(
          'SHPH API updateListing failed, falling back to Supabase: $e',
          tag: 'ServiceListingService',
        );
      }
    }

    try {
      await Supabase.instance.client
          .from('service_listings')
          .update(updates)
          .eq('id', id);
      return await fetchServiceListingById(id);
    } catch (e) {
      LoggingService.error('Error updating listing: $e',
          tag: 'ServiceListingService');
      return null;
    }
  }

  Future<bool> deleteListing(int id) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _servicesApi.updateListing(id, {'status': 'deleted'});
        LoggingService.info('Listing deleted via API: $id', tag: 'ServiceListingService');
        return true;
      } catch (e) {
        LoggingService.error('SHPH API deleteListing failed, falling back: $e', tag: 'ServiceListingService');
      }
    }

    try {
      await Supabase.instance.client
          .from('service_listings')
          .delete()
          .eq('id', id);
      LoggingService.info('Listing deleted: $id', tag: 'ServiceListingService');
      return true;
    } catch (e) {
      LoggingService.error('Error deleting listing: $e', tag: 'ServiceListingService');
      return false;
    }
  }

  Future<ServiceListing?> archiveListing(int id) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _servicesApi.archiveListing(id);
        return await fetchServiceListingById(id);
      } catch (e) {
        LoggingService.error('SHPH API archiveListing failed, falling back: $e', tag: 'ServiceListingService');
      }
    }
    return await updateListing(id: id, isAvailable: false);
  }

  Future<ServiceListing?> unarchiveListing(int id) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _servicesApi.unarchiveListing(id);
        return await fetchServiceListingById(id);
      } catch (e) {
        LoggingService.error('SHPH API unarchiveListing failed, falling back: $e', tag: 'ServiceListingService');
      }
    }
    return await updateListing(id: id, isAvailable: true);
  }

  Future<String?> uploadListingImageFile(int listingId, File imageFile) async {
    try {
      final fileName =
          '$listingId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'service-images/$fileName';

      await Supabase.instance.client.storage
          .from('services')
          .upload(filePath, imageFile);

      final url = Supabase.instance.client.storage
          .from('services')
          .getPublicUrl(filePath);

      await Supabase.instance.client
          .from('service_listing_images')
          .insert({
            'listing_id': listingId,
            'image_url': url,
            'created_at': DateTime.now().toIso8601String(),
          });

      return url;
    } catch (e) {
      LoggingService.error('Error uploading listing image: $e',
          tag: 'ServiceListingService');
      return null;
    }
  }

  Future<List<String>> fetchListingImages(int listingId) async {
    try {
      final response = await Supabase.instance.client
          .from('service_listing_images')
          .select('image_url')
          .eq('listing_id', listingId)
          .order('sort_order', ascending: true);

      return (response as List).map((e) => e['image_url'] as String).toList();
    } catch (e) {
      LoggingService.error('Error fetching listing images: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }

  Future<bool> deleteListingImage(int imageId) async {
    try {
      await Supabase.instance.client
          .from('service_listing_images')
          .delete()
          .eq('id', imageId);
      return true;
    } catch (e) {
      LoggingService.error('Error deleting listing image: $e',
          tag: 'ServiceListingService');
      return false;
    }
  }

  // ── API-based methods ─────────────────────────────────────────

  Future<Map<String, dynamic>> createServiceListing(
      Map<String, dynamic> payload) async {
    final listing = await ShphServicesApi.instance.createListing(payload);
    return listing.toJson();
  }

  Future<Map<String, dynamic>> uploadListingImage(
    int listingId, {
    required List<int> fileBytes,
    required String fileName,
  }) async {
    return ShphServicesApi.instance.uploadListingImage(
      listingId,
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }

  Future<void> deleteListingImageById(int listingId, int imageId) async {
    await ShphServicesApi.instance.deleteListingImage(listingId, imageId);
  }

  Future<List<Map<String, dynamic>>> listSubcategories(int categoryId) async {
    return ShphServicesApi.instance.listSubcategories(categoryId);
  }
}
