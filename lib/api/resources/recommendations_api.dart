import '/api/models/nearby_recommendation.dart';
import '/api/shph_api_client.dart';

/// Recommendations endpoints from SHPH API.yaml (`/api/recommendations/*`).
class ShphRecommendationsApi {
  ShphRecommendationsApi._();

  static final ShphRecommendationsApi instance =
      ShphRecommendationsApi._();
  final _client = ShphApiClient.instance;

  /// POST /api/recommendations/nearby/ — server-side radius search for
  /// listings near [latitude]/[longitude]. Distances are computed by the
  /// backend (`distance_km`, `distance_score`), never fabricated client-side.
  Future<List<NearbyRecommendation>> nearby({
    double? lat,
    double? lng,
    double radius = 10.0,
    int limit = 10,
  }) async {
    final response = await _client.post<List<dynamic>>(
      '/api/recommendations/nearby/',
      data: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'radius': radius,
        'limit': limit,
      },
    );
    final list = response.data ?? const [];
    return list
        .map((item) => NearbyRecommendation.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : <String, dynamic>{},
            ))
        .where((item) => item.listing.id != 0)
        .toList();
  }
}
