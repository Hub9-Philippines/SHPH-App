import '/api/shph_api_client.dart';

/// Provider-specific endpoints from SHPH API.yaml (`/api/providers/*`).
class ShphProvidersApi {
  ShphProvidersApi._();

  static final ShphProvidersApi instance = ShphProvidersApi._();
  final _client = ShphApiClient.instance;

  /// GET /api/users/me/ - get the authenticated provider's profile.
  Future<Map<String, dynamic>> getMyProviderProfile() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/users/me/',
    );
    return response.data ?? {};
  }

  /// PATCH /api/users/me/update/ - update provider profile fields.
  Future<Map<String, dynamic>> updateMyProviderProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/users/me/update/',
      data: data,
    );
    return response.data ?? {};
  }

  /// GET /api/providers/{id}/ - get a public provider profile
  Future<Map<String, dynamic>> getProviderProfile(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/providers/$id/',
    );
    return response.data ?? {};
  }

  /// POST /api/recommendations/nearby/ - discover nearby providers.
  Future<Map<String, dynamic>> listProviders({
    String? search,
    String? category,
    int? page,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/recommendations/nearby/',
      data: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null) 'category': category,
        if (page != null) 'page': page,
      },
    );
    return response.data ?? {};
  }
}
