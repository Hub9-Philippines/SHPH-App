import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class SearchService {
  SearchService._();
  static final SearchService instance = SearchService._();

  final _supabase = Supabase.instance.client;

  // Search services by query
  Future<List<ServiceListingsRow>> searchServices(String query) async {
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

  // Search services by category
  Future<List<ServiceListingsRow>> searchByCategory(String categoryName) async {
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
      LoggingService.error('Error searching by category: $e', tag: 'SearchService');
      return [];
    }
  }

  // Get all active services
  Future<List<ServiceListingsRow>> getAllServices() async {
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
