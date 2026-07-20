import '/api/bridges/api_row_mapper.dart';
import '/api/resources/services_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class SearchService {
  SearchService._();
  static final SearchService instance = SearchService._();

  final _supabase = Supabase.instance.client;
  final _servicesApi = ShphServicesApi.instance;

  Future<List<ServiceListingsRow>> searchServices(String query) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _servicesApi.listListings(search: query);
        return page.results.map(ApiRowMapper.serviceListingToRow).toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API searchServices failed, falling back to Supabase: $e',
          tag: 'SearchService',
        );
      }
    }

    try {
      final response = await _supabase
          .from('service_listings')
          .select('*, categories(*)')
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .eq('status', 'active')
          .eq('is_available', 'true')
          .order('created_at', ascending: false);

      return response.map(ServiceListingsRow.new).toList();
    } catch (e) {
      LoggingService.error('Error searching services: $e', tag: 'SearchService');
      return [];
    }
  }

  Future<List<ServiceListingsRow>> searchByCategory(String categoryName) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _servicesApi.listListings();
        return page.results
            .where((listing) => listing.categoryName == categoryName)
            .map(ApiRowMapper.serviceListingToRow)
            .toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API searchByCategory failed, falling back to Supabase: $e',
          tag: 'SearchService',
        );
      }
    }

    try {
      final response = await _supabase
          .from('service_listings')
          .select('*, categories(*)')
          .eq('category_name', categoryName)
          .eq('status', 'active')
          .eq('is_available', 'true')
          .order('created_at', ascending: false);

      return response.map(ServiceListingsRow.new).toList();
    } catch (e) {
      LoggingService.error('Error searching by category: $e',
          tag: 'SearchService');
      return [];
    }
  }

  Future<List<ServiceListingsRow>> getAllServices() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _servicesApi.listListings();
        return page.results.map(ApiRowMapper.serviceListingToRow).toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API getAllServices failed, falling back to Supabase: $e',
          tag: 'SearchService',
        );
      }
    }

    try {
      final response = await _supabase
          .from('service_listings')
          .select('*, categories(*)')
          .eq('status', 'active')
          .eq('is_available', 'true')
          .order('created_at', ascending: false);

      return response.map(ServiceListingsRow.new).toList();
    } catch (e) {
      LoggingService.error('Error fetching services: $e', tag: 'SearchService');
      return [];
    }
  }
}
