import '/api/shph_api_client.dart';

/// Recommendations endpoints from SHPH API (`/api/recommendations/*`).
class ShphRecommendationsApi {
  ShphRecommendationsApi._();

  static final ShphRecommendationsApi instance = ShphRecommendationsApi._();
  final _client = ShphApiClient.instance;

  Future<void> trackInteraction({
    required int userId,
    required String type,
    int? serviceId,
    int? providerId,
    String? query,
    Map<String, dynamic>? context,
  }) async {
    await _client.post(
      '/api/recommendations/track-interaction/',
      data: {
        'user_id': userId,
        if (serviceId != null) 'service_id': serviceId,
        if (providerId != null) 'provider_id': providerId,
        'type': type,
        if (query != null) 'query': query,
        if (context != null) 'context': context,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getUserRecommendations({
    int? limit,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/recommendations/user/',
      data: {if (limit != null) 'limit': limit},
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

  Future<List<Map<String, dynamic>>> getTrendingServices({
    int? limit,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/recommendations/trending/',
      data: {if (limit != null) 'limit': limit},
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

  Future<List<Map<String, dynamic>>> getNearbyRecommendations({
    double? lat,
    double? lng,
    int? limit,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/recommendations/nearby/',
      data: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (limit != null) 'limit': limit,
      },
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
}
