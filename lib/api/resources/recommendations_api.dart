import '/api/shph_api_client.dart';

/// Recommendation endpoints (`/api/recommendations/*`).
class ShphRecommendationsApi {
  ShphRecommendationsApi._();

  static final ShphRecommendationsApi instance = ShphRecommendationsApi._();
  final _client = ShphApiClient.instance;

  /// POST /api/recommendations/get-personalized/ - recommended services.
  Future<Map<String, dynamic>> listRecommendedServices({int? page}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/recommendations/get-personalized/',
      data: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  /// POST /api/recommendations/nearby/ - nearby/provider recommendations.
  Future<Map<String, dynamic>> listRecommendedProviders({int? page}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/recommendations/nearby/',
      data: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  /// POST /api/recommendations/content-based/ - category/content recommendations.
  Future<Map<String, dynamic>> listRecommendedCategories() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/recommendations/content-based/',
      data: const {},
    );
    return response.data ?? {};
  }
}
