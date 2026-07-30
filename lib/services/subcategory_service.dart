import '/api/resources/services_api.dart';
import '/services/logging_service.dart';

class SubcategoryService {
  SubcategoryService._();
  static final SubcategoryService instance = SubcategoryService._();

  final _api = ShphServicesApi.instance;

  Future<List<Map<String, dynamic>>> getSubcategories(int parentId) async {
    try {
      final resp = await _api.listSubcategories(parentId);
      final results = resp['results'];
      if (results is List) {
        return results.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggingService.error('Error fetching subcategories: $e',
          tag: 'SubcategoryService');
      return [];
    }
  }
}
