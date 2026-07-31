import '/api/bridges/api_row_mapper.dart';
import '/api/resources/services_api.dart';
import '/backend/supabase/database/tables/categories.dart';
import '/backend/supabase/database/tables/service_listings.dart';
import '/services/logging_service.dart';

class CategoriesService {
  CategoriesService._();
  static final CategoriesService instance = CategoriesService._();

  final _servicesApi = ShphServicesApi.instance;

  Future<List<CategoriesRow>> getCategories() async {
    try {
      final page = await _servicesApi.listCategories();
      return page.results.map(ApiRowMapper.categoryToRow).toList();
    } catch (e) {
      LoggingService.error('getCategories failed: $e',
          tag: 'CategoriesService');
      return [];
    }
  }

  Future<CategoriesRow?> getCategoryById(int categoryId) async {
    final categories = await getCategories();
    for (final category in categories) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
  }

  Future<List<ServiceListingsRow>> getServicesByCategory(int categoryId) async {
    try {
      final page = await _servicesApi.listListings();
      return page.results
          .where((listing) => listing.category == categoryId)
          .where((listing) => listing.status == 'active')
          .map(ApiRowMapper.serviceListingToRow)
          .toList();
    } catch (e) {
      LoggingService.error('getServicesByCategory failed: $e',
          tag: 'CategoriesService');
      return [];
    }
  }
}
