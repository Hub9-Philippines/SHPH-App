import '/api/bridges/api_row_mapper.dart';
import '/api/resources/services_api.dart';
import '/backend/supabase/database/tables/categories.dart';
import '/backend/supabase/database/tables/service_listings.dart';
import '/services/logging_service.dart';

class CategoriesService {
  CategoriesService._();
  static final CategoriesService instance = CategoriesService._();
  final _api = ShphServicesApi.instance;

  Future<List<CategoriesRow>> getCategories() async {
    try {
      final page = await _api.listCategories();
      return page.results.map(ApiRowMapper.categoryToRow).toList();
    } catch (e) {
      LoggingService.error('Category fetch failed: $e',
          tag: 'CategoriesService');
      return [];
    }
  }

  Future<CategoriesRow?> getCategoryById(int id) async {
    for (final category in await getCategories()) {
      if (category.id == id) return category;
    }
    return null;
  }

  Future<List<ServiceListingsRow>> getServicesByCategory(int id) async {
    try {
      final page = await _api.listListings();
      return page.results
          .where((item) => item.category == id && item.status == 'active')
          .map(ApiRowMapper.serviceListingToRow)
          .toList();
    } catch (e) {
      LoggingService.error('Category services failed: $e',
          tag: 'CategoriesService');
      return [];
    }
  }
}
