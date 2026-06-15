import '/backend/supabase/database/tables/service_listings.dart';
import '/models/service_listing.dart';
import '/services/logging_service.dart';

class ServiceListingService {
  ServiceListingService._();

  static final ServiceListingService instance = ServiceListingService._();

  /// Convert ServiceListingsRow to ServiceListing
  ServiceListing _rowToServiceListing(ServiceListingsRow row) {
    final listing = ServiceListing(
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
    return listing;
  }

  /// Fetch recommended services sorted by rating and review count
  Future<List<ServiceListing>> fetchRecommendedServices(
      {int limit = 10}) async {
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

  /// Fetch service listings with optional search and ordering
  Future<List<ServiceListing>> fetchServiceListings({
    String? search,
    String? ordering,
    int? page,
    int? pageSize,
  }) async {
    try {
      final services = await ServiceListingsTable().queryRows(
        queryFn: (q) {
          // Build query with optional filters and ordering
          var query = q as dynamic;

          // Add search filter if provided
          if (search != null && search.isNotEmpty) {
            query = query.ilike('title', '%$search%');
          }

          // Add ordering if provided
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

  /// Fetch a single service listing by ID
  Future<ServiceListing?> fetchServiceListingById(int id) async {
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

  /// Fetch favorite services for the current user
  Future<List<ServiceListing>> fetchFavoriteServices() async {
    try {
      // This would typically query a favorites table
      // For now, return empty list as favorites feature needs database table
      // TODO: Implement favorites table and query
      return [];
    } catch (e) {
      LoggingService.error('Error fetching favorite services: $e',
          tag: 'ServiceListingService');
      return [];
    }
  }
}
