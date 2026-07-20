import '/api/shph_api_client.dart';

class ShphLocationsApi {
  ShphLocationsApi._();

  static final ShphLocationsApi instance = ShphLocationsApi._();
  final _client = ShphApiClient.instance;

  Future<List<Map<String, dynamic>>> listRegions() => _list(
        '/api/locations/regions/',
      );

  Future<List<Map<String, dynamic>>> listProvinces({String? regionCode}) =>
      _list(
        '/api/locations/provinces/',
        queryParameters: {if (regionCode != null) 'region': regionCode},
      );

  Future<List<Map<String, dynamic>>> listCities(
    String? provinceCode, {
    String? regionCode,
  }) =>
      _list(
        '/api/locations/cities/',
        queryParameters: {
          if (provinceCode != null) 'province': provinceCode,
          if (regionCode != null) 'region': regionCode,
        },
      );

  Future<List<Map<String, dynamic>>> listBarangays(String cityCode) => _list(
        '/api/locations/barangays/',
        queryParameters: {'city': cityCode},
      );

  Future<List<Map<String, dynamic>>> _list(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.get<List<dynamic>>(
      path,
      queryParameters: queryParameters,
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }
}
