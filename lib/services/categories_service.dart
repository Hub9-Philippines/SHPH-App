import '/api/bridges/api_row_mapper.dart';
import '/api/resources/services_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class CategoriesService {
  CategoriesService._();
  static final CategoriesService instance = CategoriesService._();

  final _supabase = Supabase.instance.client;
  final _servicesApi = ShphServicesApi.instance;

  Future<List<CategoriesRow>> getCategories() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _servicesApi.listCategories();
        return page.results.map(ApiRowMapper.categoryToRow).toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API getCategories failed, falling back to Supabase: $e',
          tag: 'CategoriesService',
        );
      }
    }

    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return response.map(CategoriesRow.new).toList();
    } catch (e) {
      LoggingService.error('Error fetching categories: $e',
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
    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _servicesApi.listListings();
        return page.results
            .where((listing) => listing.category == categoryId)
            .where((listing) => listing.status == 'active')
            .map(ApiRowMapper.serviceListingToRow)
            .toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API getServicesByCategory failed, falling back to Supabase: $e',
          tag: 'CategoriesService',
        );
      }
    }

    try {
      final response = await _supabase
          .from('service_listings')
          .select()
          .eq('category', categoryId)
          .eq('status', 'active')
          .eq('is_available', 'true')
          .order('created_at', ascending: false);

      return response.map(ServiceListingsRow.new).toList();
    } catch (e) {
      LoggingService.error('Error fetching services by category: $e',
          tag: 'CategoriesService');
      return [];
    }
  }
}
