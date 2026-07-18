class ShphBooking {
  const ShphBooking({
    required this.id,
    required this.listing,
    required this.status,
    this.listingTitle,
    this.providerName,
    this.providerPhoto,
    this.clientId,
    this.providerId,
    this.scheduledDate,
    this.scheduledTime,
    this.scheduledAt,
    this.notes,
    this.agreedPrice,
    this.totalPrice,
    this.createdAt,
    this.serviceListing,
    this.clientProfile,
  });

  factory ShphBooking.fromJson(Map<String, dynamic> json) => ShphBooking(
        id: json['id']?.toString() ?? '',
        listing: json['listing'] as int? ?? 0,
        status: json['status'] as String? ?? 'pending',
        listingTitle: json['listing_title'] as String?,
        providerName: json['provider_name'] as String?,
        providerPhoto: json['provider_photo'] as String?,
        clientId: json['client_id'] as int? ?? json['client'] as int?,
        providerId: json['provider_id'] as int?,
        scheduledDate: json['scheduled_date'] as String?,
        scheduledTime: json['scheduled_time'] as String?,
        scheduledAt: json['scheduled_at'] as String?,
        notes: json['notes'] as String?,
        agreedPrice: _toDouble(json['agreed_price']),
        totalPrice: _toDouble(json['total_price']),
        createdAt: json['created_at'] as String?,
        serviceListing: json['service_listings'] as Map<String, dynamic>? ??
            json['service_listing'] as Map<String, dynamic>?,
        clientProfile: json['profiles'] as Map<String, dynamic>? ??
            json['client_profile'] as Map<String, dynamic>?,
      );

  final String id;
  final int listing;
  final String status;
  final String? listingTitle;
  final String? providerName;
  final String? providerPhoto;
  final int? clientId;
  final int? providerId;
  final String? scheduledDate;
  final String? scheduledTime;
  final String? scheduledAt;
  final String? notes;
  final double? agreedPrice;
  final double? totalPrice;
  final String? createdAt;
  final Map<String, dynamic>? serviceListing;
  final Map<String, dynamic>? clientProfile;

  Map<String, dynamic> toCreateJson({
    required int listingId,
    String? scheduledDate,
    String? scheduledTime,
    String? notes,
    double? totalPrice,
  }) =>
      {
        'listing': listingId,
        if (scheduledDate != null) 'scheduled_date': scheduledDate,
        if (scheduledTime != null) 'scheduled_time': scheduledTime,
        if (notes != null) 'notes': notes,
        if (totalPrice != null) 'total_price': totalPrice,
      };

  static double? _toDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}
