import '/api/shph_api_client.dart';

/// Address endpoints (`/api/profiles/addresses/*`).
class ShphAddressesApi {
  ShphAddressesApi._();

  static final ShphAddressesApi instance = ShphAddressesApi._();
  final _client = ShphApiClient.instance;

  /// GET /api/addresses/ - list user addresses
  Future<List<Map<String, dynamic>>> listAddresses() async {
    final response = await _client.get<dynamic>('/api/profiles/addresses/');
    final data = response.data;
    final rows = data is List ? data : (data is Map ? data['results'] : null);
    return (rows as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  /// POST /api/addresses/ - create an address
  Future<Map<String, dynamic>> createAddress(
      Map<String, dynamic> payload) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/profiles/addresses/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// GET /api/addresses/{id}/ - get address by ID
  Future<Map<String, dynamic>> getAddress(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/profiles/addresses/$id/',
    );
    return response.data ?? {};
  }

  /// PATCH /api/addresses/{id}/ - update an address
  Future<Map<String, dynamic>> updateAddress(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/profiles/addresses/$id/',
      data: payload,
    );
    return response.data ?? {};
  }

  /// DELETE /api/addresses/{id}/ - delete an address
  Future<void> deleteAddress(int id) async {
    await _client.delete('/api/profiles/addresses/$id/');
  }

  Future<void> setDefaultAddress(int id) async {
    await _client.post('/api/profiles/addresses/$id/set-default/');
  }
}
