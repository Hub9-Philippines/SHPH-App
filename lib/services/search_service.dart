import '/api/bridges/api_row_mapper.dart';
import '/api/resources/services_api.dart';
import '/backend/supabase/database/tables/service_listings.dart';
import '/services/logging_service.dart';

class SearchService {
  SearchService._();
  static final SearchService instance = SearchService._();

  final _servicesApi = ShphServicesApi.instance;

  Future<List<ServiceListingsRow>> searchServices(String query) async {
    try {
      final page = await _servicesApi.listListings(search: query);
      return page.results.map(ApiRowMapper.serviceListingToRow).toList();
    } catch (e) {
      LoggingService.error('searchServices failed: $e', tag: 'SearchService');
      return [];
    }
  }

  Future<List<ServiceListingsRow>> searchByCategory(String categoryName) async {
    try {
      final page = await _servicesApi.listListings();
      return page.results
          .where((listing) => listing.categoryName == categoryName)
          .map(ApiRowMapper.serviceListingToRow)
          .toList();
    } catch (e) {
      LoggingService.error('searchByCategory failed: $e',
          tag: 'SearchService');
      return [];
    }
  }

  Future<List<ServiceListingsRow>> getAllServices() async {
    try {
      final page = await _servicesApi.listListings();
      return page.results.map(ApiRowMapper.serviceListingToRow).toList();
    } catch (e) {
      LoggingService.error('getAllServices failed: $e', tag: 'SearchService');
      return [];
    }
  }
}
