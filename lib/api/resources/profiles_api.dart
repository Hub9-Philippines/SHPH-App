import '/api/models/address.dart';
import '/api/models/paginated_response.dart';
import '/api/shph_api_client.dart';

/// Profiles endpoints from SHPH API.yaml (`/api/profiles/*`).
class ShphProfilesApi {
  ShphProfilesApi._();

  static final ShphProfilesApi instance = ShphProfilesApi._();
  final _client = ShphApiClient.instance;

  Future<PaginatedResponse<ShphAddress>> listAddresses({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/profiles/addresses/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphAddress.fromJson,
    );
  }

  Future<ShphAddress> getAddress(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/profiles/addresses/$id/',
    );
    return ShphAddress.fromJson(response.data ?? {});
  }

  Future<ShphAddress> createAddress(Map<String, dynamic> data) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/profiles/addresses/',
      data: data,
    );
    return ShphAddress.fromJson(response.data ?? {});
  }

  Future<ShphAddress> updateAddress(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/profiles/addresses/$id/',
      data: data,
    );
    return ShphAddress.fromJson(response.data ?? {});
  }

  Future<void> deleteAddress(int id) async {
    await _client.delete('/api/profiles/addresses/$id/');
  }

  Future<ShphAddress> setDefaultAddress(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/profiles/addresses/$id/set-default/',
    );
    return ShphAddress.fromJson(response.data ?? {});
  }
}
