/// Web-equivalent model for SHPH on-demand bids.
///
/// Mirrors the Django `OnDemandBid` serializer exposed by
/// `/api/services/on-demand/*` endpoints.
class ShphOnDemandBid {
  const ShphOnDemandBid({
    required this.id,
    required this.job,
    required this.provider,
    this.listing,
    this.distanceKm,
    this.etaMinutes,
    this.agreedPrice,
    this.totalPrice,
    this.pricing,
    this.voucherDiscount,
    this.status = ShphOnDemandBidStatus.pending,
    this.createdAt,
    this.withdrawnAt,
  });

  final int id;
  final int job;
  final ShphOnDemandBidProvider provider;
  final ShphOnDemandBidListing? listing;
  final double? distanceKm;
  final int? etaMinutes;
  final double? agreedPrice;
  final double? totalPrice;
  final ShphOnDemandBidPricing? pricing;
  final double? voucherDiscount;
  final ShphOnDemandBidStatus status;
  final DateTime? createdAt;
  final DateTime? withdrawnAt;

  factory ShphOnDemandBid.fromJson(Map<String, dynamic> json) {
    return ShphOnDemandBid(
      id: json['id'] as int? ?? 0,
      job: json['job'] as int? ?? 0,
      provider: ShphOnDemandBidProvider.fromJson(
        json['provider'] as Map<String, dynamic>? ?? {},
      ),
      listing: json['listing'] != null
          ? ShphOnDemandBidListing.fromJson(
              json['listing'] as Map<String, dynamic>,
            )
          : null,
      distanceKm: _toDouble(json['distance_km']),
      etaMinutes: json['eta_minutes'] as int?,
      agreedPrice: _toDouble(json['agreed_price']),
      totalPrice: _toDouble(json['total_price']),
      pricing: json['pricing'] != null
          ? ShphOnDemandBidPricing.fromJson(
              json['pricing'] as Map<String, dynamic>,
            )
          : null,
      voucherDiscount: _toDouble(json['voucher_discount']),
      status: ShphOnDemandBidStatus.fromJson(json['status'] as String?),
      createdAt: _toDateTime(json['created_at']),
      withdrawnAt: _toDateTime(json['withdrawn_at']),
    );
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

class ShphOnDemandBidProvider {
  const ShphOnDemandBidProvider({
    required this.id,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.rating,
    this.completedJobs,
  });

  final int id;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final double? rating;
  final int? completedJobs;

  factory ShphOnDemandBidProvider.fromJson(Map<String, dynamic> json) {
    return ShphOnDemandBidProvider(
      id: json['id'] as int? ?? 0,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      completedJobs: json['completed_jobs'] as int?,
    );
  }
}

class ShphOnDemandBidListing {
  const ShphOnDemandBidListing({
    required this.id,
    this.title,
    this.basePrice,
    this.priceUnit,
  });

  final int id;
  final String? title;
  final double? basePrice;
  final String? priceUnit;

  factory ShphOnDemandBidListing.fromJson(Map<String, dynamic> json) {
    return ShphOnDemandBidListing(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String?,
      basePrice: json['base_price'] != null
          ? (json['base_price'] as num).toDouble()
          : null,
      priceUnit: json['price_unit'] as String?,
    );
  }
}

class ShphOnDemandBidPricing {
  const ShphOnDemandBidPricing({
    this.hourlyFee,
    this.travelFee,
    this.agreedPrice,
    this.platformFee,
    this.vat,
    this.voucherDiscount,
    this.total,
  });

  final double? hourlyFee;
  final double? travelFee;
  final double? agreedPrice;
  final double? platformFee;
  final double? vat;
  final double? voucherDiscount;
  final double? total;

  factory ShphOnDemandBidPricing.fromJson(Map<String, dynamic> json) {
    double? parse(Object? value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return ShphOnDemandBidPricing(
      hourlyFee: parse(json['hourly_fee']),
      travelFee: parse(json['travel_fee']),
      agreedPrice: parse(json['agreed_price']),
      platformFee: parse(json['platform_fee']),
      vat: parse(json['vat']),
      voucherDiscount: parse(json['voucher_discount']),
      total: parse(json['total']),
    );
  }
}

enum ShphOnDemandBidStatus {
  pending,
  selected,
  rejected,
  expired;

  static ShphOnDemandBidStatus fromJson(String? value) {
    switch (value) {
      case 'selected':
        return ShphOnDemandBidStatus.selected;
      case 'rejected':
        return ShphOnDemandBidStatus.rejected;
      case 'expired':
        return ShphOnDemandBidStatus.expired;
      case 'pending':
      default:
        return ShphOnDemandBidStatus.pending;
    }
  }

  String get apiValue => name;
}
