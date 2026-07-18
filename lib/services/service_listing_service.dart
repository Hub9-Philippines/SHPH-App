import '/api/bridges/api_row_mapper.dart';
import '/api/models/service_listing.dart';
import '/api/resources/favorites_api.dart';
import '/api/resources/services_api.dart';
import '/backend/shph_db/database/tables/service_listings.dart';
import '/models/service_listing.dart';
import '/services/logging_service.dart';

class ServiceListingService {
  ServiceListingService._();

  static final ServiceListingService instance = ServiceListingService._();
  final _servicesApi = ShphServicesApi.instance;

  ServiceListing _rowToServiceListing(ServiceListingsRow row) => ServiceListing(
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
