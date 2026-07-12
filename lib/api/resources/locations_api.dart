import '/api/shph_api_client.dart';

class ShphLocationsApi {
  ShphLocationsApi._();

  static final ShphLocationsApi instance = ShphLocationsApi._();
  final _client = ShphApiClient.instance;

  Future<List<Map<String, dynamic>>> listProvinces() async {
    final response = await _client.get<List<dynamic>>(
      '/api/locations/provinces/',
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  Future<List<Map<String, dynamic>>> listCities(String provinceCode) async {
    final response = await _client.get<List<dynamic>>(
      '/api/locations/cities/',
      queryParameters: {'province': provinceCode},
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  Future<List<Map<String, dynamic>>> listBarangays(String cityCode) async {
    final response = await _client.get<List<dynamic>>(
      '/api/locations/barangays/',
      queryParameters: {'city': cityCode},
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().toList();
  }
}
