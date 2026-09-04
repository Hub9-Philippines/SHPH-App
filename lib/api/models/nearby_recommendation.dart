import '/api/models/service_listing.dart';

/// A single nearby recommendation item returned by
/// POST /api/recommendations/nearby/ (SHPH API.yaml `NearbyRecommendation`).
class NearbyRecommendation {
  const NearbyRecommendation({
    required this.id,
    required this.listing,
    required this.distanceKm,
    required this.distanceScore,
  });

  final int id;

  /// Embedded listing summary. Reuses [ShphServiceListing] as the projection is
  /// a subset (`RecommendationListing`), so unknown fields simply stay null.
  final ShphServiceListing listing;

  /// Server-computed distance in km — never fabricated client-side.
  final double? distanceKm;
  final double? distanceScore;

  factory NearbyRecommendation.fromJson(Map<String, dynamic> json) {
    return NearbyRecommendation(
      id: json['id'] as int? ?? 0,
      listing: ShphServiceListing.fromJson(
        json['listing'] is Map<String, dynamic>
            ? json['listing'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
      distanceKm: _toDouble(json['distance_km']),
      distanceScore: _toDouble(json['distance_score']),
    );
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
