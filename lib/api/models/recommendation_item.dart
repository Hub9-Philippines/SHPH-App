import '/api/models/service_listing.dart';

/// A single personalized recommendation item returned by
/// POST /api/recommendations/user/ (SHPH API.yaml `RecommendationItem`).
class RecommendationItem {
  const RecommendationItem({
    this.serviceId,
    required this.listing,
    this.score,
    this.reason,
  });

  final int? serviceId;

  /// Embedded listing summary. Reuses [ShphServiceListing] as the projection is
  /// a subset (`RecommendationListing`), so unknown fields simply stay null.
  final ShphServiceListing listing;
  final double? score;
  final String? reason;

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      serviceId: json['serviceId'] as int? ?? json['service_id'] as int?,
      listing: ShphServiceListing.fromJson(
        json['listing'] is Map<String, dynamic>
            ? json['listing'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
      score: _toDouble(json['score']),
      reason: json['reason'] as String?,
    );
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}