import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class CategoriesService {
  CategoriesService._();
  static final CategoriesService instance = CategoriesService._();

  final _supabase = Supabase.instance.client;

  // Get all active categories
  Future<List<CategoriesRow>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return response.map(CategoriesRow.new).toList();
    } catch (e) {
      LoggingService.error('Error fetching categories: $e', tag: 'CategoriesService');
      return [];
    }
  }

  // Get category by ID
  Future<CategoriesRow?> getCategoryById(int categoryId) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('id', categoryId)
          .maybeSingle();

      if (response == null)
        return null;
      return CategoriesRow(response);
    } catch (e) {
      LoggingService.error('Error fetching category: $e', tag: 'CategoriesService');
      return null;
    }
  }

  // Get services by category
  Future<List<ServiceListingsRow>> getServicesByCategory(int categoryId) async {
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
      LoggingService.error('Error fetching services by category: $e', tag: 'CategoriesService');
      return [];
    }
  }
}
