import '/api/bridges/api_row_mapper.dart';
import '/api/resources/services_api.dart';
import '/backend/supabase/database/tables/service_listings.dart';
import '/services/logging_service.dart';

class SearchService {
  SearchService._();
  static final SearchService instance = SearchService._();
  final _api = ShphServicesApi.instance;

  Future<List<ServiceListingsRow>> searchServices(String query) =>
      _list(search: query);

  Future<List<ServiceListingsRow>> searchByCategory(String name) async =>
      (await _list()).where((row) => row.categoryName == name).toList();

  Future<List<ServiceListingsRow>> getAllServices() => _list();

  Future<List<ServiceListingsRow>> _list({String? search}) async {
    try {
      final page = await _api.listListings(search: search);
      return page.results.map(ApiRowMapper.serviceListingToRow).toList();
    } catch (e) {
      LoggingService.error('Service search failed: $e', tag: 'SearchService');
      return [];
    }
  }
}
