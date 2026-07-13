import '/api/shph_api_client.dart';

/// Provider-specific endpoints from SHPH API.yaml (`/api/providers/*`).
class ShphProvidersApi {
  ShphProvidersApi._();

  static final ShphProvidersApi instance = ShphProvidersApi._();
  final _client = ShphApiClient.instance;

  /// GET /api/providers/me/ - get own provider profile
  Future<Map<String, dynamic>> getMyProviderProfile() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/providers/me/',
    );
    return response.data ?? {};
  }

  /// PATCH /api/providers/me/ - update own provider profile
  Future<Map<String, dynamic>> updateMyProviderProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/providers/me/',
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

  /// GET /api/providers/ - list/search providers
  Future<Map<String, dynamic>> listProviders({
    String? search,
    String? category,
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/providers/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null) 'category': category,
        if (page != null) 'page': page,
      },
    );
    return response.data ?? {};
  }
}
