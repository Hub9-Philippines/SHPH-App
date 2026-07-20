/// Web-equivalent models for SHPH on-demand jobs.
///
/// Mirrors the Django `OnDemandJob` serializer/fields exposed by
/// `/api/services/on-demand/*` endpoints.
class ShphOnDemandJob {
  const ShphOnDemandJob({
    required this.id,
    required this.category,
    this.categoryName,
    this.description,
    this.photoUrl,
    this.clientLat,
    this.clientLng,
    this.radiusKm = 4,
    this.estimatedFeeMin,
    this.estimatedFeeMax,
    this.status = ShphOnDemandJobStatus.searching,
    this.bookingId,
    this.expiresAt,
    this.createdAt,
    this.scheduledFor,
    this.voucherCode,
  });

  final int id;
  final int category;
  final String? categoryName;
  final String? description;
  final String? photoUrl;
  final double? clientLat;
  final double? clientLng;
  final int radiusKm;
  final double? estimatedFeeMin;
  final double? estimatedFeeMax;
  final ShphOnDemandJobStatus status;
  final int? bookingId;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? scheduledFor;
  final String? voucherCode;

  factory ShphOnDemandJob.fromJson(Map<String, dynamic> json) {
    return ShphOnDemandJob(
      id: json['id'] as int? ?? 0,
      category: json['category'] as int? ?? 0,
      categoryName: json['category_name'] as String?,
      description: json['description'] as String?,
      photoUrl: json['photo_url'] as String?,
      clientLat: _toDouble(json['client_lat']),
      clientLng: _toDouble(json['client_lng']),
      radiusKm: json['radius_km'] as int? ?? 4,
      estimatedFeeMin: _toDouble(json['estimated_fee_min']),
      estimatedFeeMax: _toDouble(json['estimated_fee_max']),
      status: ShphOnDemandJobStatus.fromJson(json['status'] as String?),
      bookingId: json['booking_id'] as int?,
      expiresAt: _toDateTime(json['expires_at']),
      createdAt: _toDateTime(json['created_at']),
      scheduledFor: _toDateTime(json['scheduled_for']),
      voucherCode: json['voucher_code'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'category': category,
      if (description != null) 'description': description,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (clientLat != null) 'client_lat': clientLat,
      if (clientLng != null) 'client_lng': clientLng,
      'radius_km': radiusKm,
      if (scheduledFor != null)
        'scheduled_for': scheduledFor!.toUtc().toIso8601String(),
      if (voucherCode != null) 'voucher_code': voucherCode,
    };
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

enum ShphOnDemandJobStatus {
  searching,
  accepted,
  expired,
  cancelled,
  scheduled;

  static ShphOnDemandJobStatus fromJson(String? value) {
    switch (value) {
      case 'accepted':
        return ShphOnDemandJobStatus.accepted;
      case 'expired':
        return ShphOnDemandJobStatus.expired;
      case 'cancelled':
        return ShphOnDemandJobStatus.cancelled;
      case 'scheduled':
        return ShphOnDemandJobStatus.scheduled;
      case 'searching':
      default:
        return ShphOnDemandJobStatus.searching;
    }
  }

  String get apiValue => name;
}
