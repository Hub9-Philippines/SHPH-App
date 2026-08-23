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
      latitude: row.latitude,
      longitude: row.longitude,
      distanceKm: row.distanceKm,
      isTimeMaterial: row.isTimeMaterial ?? false,
    );
  }

  ServiceListing _apiToServiceListing(ShphServiceListing listing) {
    final row = ApiRowMapper.serviceListingToRow(listing);
    return _rowToServiceListing(row);
  }

  Future<List<ServiceListing>> fetchRecommendedServices(
      {int limit = 10}) async {
    try {
      final page = await _servicesApi.listListings(
        ordering: '-rating',
        pageSize: limit,
      );
      return page.results.map(_apiToServiceListing).toList();
    } catch (e) {
      LoggingService.error('fetchRecommendedServices failed: $e',
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
    try {
      final pageResult = await _servicesApi.listListings(
        search: search,
        ordering: ordering,
        page: page,
        pageSize: pageSize,
      );
      return pageResult.results.map(_apiToServiceListing).toList();
    } catch (e) {
      LoggingService.error('fetchServiceListings failed: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }

  Future<ServiceListing?> fetchServiceListingById(int id) async {
    try {
      final listing = await _servicesApi.getListing(id);
      return _apiToServiceListing(listing);
    } catch (e) {
      LoggingService.error('fetchServiceListingById failed: $e',
          tag: 'ServiceListingService');
      return null;
    }
  }

  /// Top-rated listings for the Explore carousel. When [latitude] and
  /// [longitude] are supplied the backend computes `distance_km` per listing.
  /// Results arrive rating-ordered; listings without coordinates simply have
  /// a null distance.
  Future<List<ServiceListing>> fetchTopRatedNear({
    required double? latitude,
    required double? longitude,
    int limit = 10,
  }) async {
    try {
      final hasLocation = latitude != null && longitude != null;
      final pageResult = await _servicesApi.listListings(
        ordering: '-rating',
        pageSize: limit,
        latitude: hasLocation ? latitude : null,
        longitude: hasLocation ? longitude : null,
      );
      final listings = pageResult.results.map(_apiToServiceListing).toList();
      // Keep only rated listings; sort by rating desc, then distance asc when
      // known so the closest best-rated pros lead the carousel.
      double? ratingOf(ServiceListing l) => l.ratingValue;
      listings.sort((a, b) {
        final ra = ratingOf(a) ?? -1;
        final rb = ratingOf(b) ?? -1;
        if (ra != rb) return rb.compareTo(ra);
        final da = a.distanceKm ?? double.infinity;
        final db = b.distanceKm ?? double.infinity;
        return da.compareTo(db);
      });
      return listings;
    } catch (e) {
      LoggingService.error('fetchTopRatedNear failed: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }

  Future<List<ServiceListing>> fetchFavoriteServices() async {
    try {
      final favorites = await ShphFavoritesApi.instance.listFavorites();
      return favorites.map(_apiToServiceListing).toList();
    } catch (e) {
      LoggingService.error('fetchFavoriteServices failed: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }
}
