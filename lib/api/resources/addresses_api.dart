import '/api/shph_api_client.dart';

/// Addresses endpoints from SHPH API (`/api/profiles/addresses/*`).
class ShphAddressesApi {
  ShphAddressesApi._();

  static final ShphAddressesApi instance = ShphAddressesApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> updateAddress(
    int id, {
    required Map<String, dynamic> data,
  }) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/profiles/addresses/$id/',
      data: data,
    );
    return response.data ?? {};
  }
}
