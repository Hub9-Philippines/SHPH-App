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
    );
  }

  ServiceListing _apiToServiceListing(ShphServiceListing listing) {
    final row = ApiRowMapper.serviceListingToRow(listing);
    return _rowToServiceListing(row);
  }

  Future<List<ServiceListing>> fetchRecommendedServices({int limit = 10}) async {
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
}
