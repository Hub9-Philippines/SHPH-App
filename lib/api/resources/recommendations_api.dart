import '/api/shph_api_client.dart';

/// Recommendation endpoints (`/api/recommendations/*`).
class ShphRecommendationsApi {
  ShphRecommendationsApi._();

  static final ShphRecommendationsApi instance = ShphRecommendationsApi._();
  final _client = ShphApiClient.instance;

  /// GET /api/recommendations/services/ - get recommended services
  Future<Map<String, dynamic>> listRecommendedServices({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/recommendations/services/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  /// GET /api/recommendations/providers/ - get recommended providers
  Future<Map<String, dynamic>> listRecommendedProviders({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/recommendations/providers/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  /// GET /api/recommendations/categories/ - get recommended categories
  Future<Map<String, dynamic>> listRecommendedCategories() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/recommendations/categories/',
    );
    return response.data ?? {};
  }
}
