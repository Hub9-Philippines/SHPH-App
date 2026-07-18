import '/api/shph_api_client.dart';

/// Provider endpoints from SHPH API (`/api/providers/*`).
class ShphProviderApi {
  ShphProviderApi._();

  static final ShphProviderApi instance = ShphProviderApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getProfile(int providerId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/providers/$providerId/',
    );
    return response.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getListings(int providerId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/providers/$providerId/listings/',
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    if (data is List) {
      return (data! as List).whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getIncentives() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/providers/me/incentives/',
    );
    return response.data ?? {};
  }
}
