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
    this.arrivedAt,
    this.startedAt,
    this.clientAddress,
    this.serviceLat,
    this.serviceLng,
    this.serviceListing,
    this.clientProfile,
  });

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

  /// Timestamp when the provider marked themselves as arrived (status →
  /// arrived). Null until then.
  final String? arrivedAt;

  /// Timestamp when work actually began (status → in_progress).
  final String? startedAt;

  /// Server-derived service address (from the client's saved profile
  /// addresses). Released by the API once the job is taken; may be null.
  final String? clientAddress;
  final double? serviceLat;
  final double? serviceLng;
  final Map<String, dynamic>? serviceListing;
  final Map<String, dynamic>? clientProfile;

  factory ShphBooking.fromJson(Map<String, dynamic> json) {
    final rawListing = json['listing'] ?? json['service_id'];
    int listingInt = 0;
    if (rawListing is int) {
      listingInt = rawListing;
    } else if (rawListing != null) {
      listingInt = int.tryParse(rawListing.toString()) ?? rawListing.toString().hashCode.abs();
    }

    final rawClient = json['client_id'] ?? json['client'];
    int? clientInt;
    if (rawClient is int) {
      clientInt = rawClient;
    } else if (rawClient != null) {
      clientInt = int.tryParse(rawClient.toString()) ?? rawClient.toString().hashCode.abs();
    }

    final rawProv = json['provider_id'] ?? json['provider'];
    int? provInt;
    if (rawProv is int) {
      provInt = rawProv;
    } else if (rawProv != null) {
      provInt = int.tryParse(rawProv.toString()) ?? rawProv.toString().hashCode.abs();
    }

    return ShphBooking(
      id: json['id']?.toString() ?? '',
      listing: listingInt,
      status: json['status'] as String? ?? 'pending',
      listingTitle: json['listing_title'] as String?,
      providerName: json['provider_name'] as String?,
      providerPhoto: json['provider_photo'] as String?,
      clientId: clientInt,
      providerId: provInt,
      scheduledDate: json['scheduled_date'] as String?,
      scheduledTime: json['scheduled_time'] as String?,
      scheduledAt: json['scheduled_at'] as String?,
      notes: json['notes'] as String?,
      agreedPrice: _toDouble(json['agreed_price']),
      totalPrice: _toDouble(json['total_price']),
      createdAt: json['created_at']?.toString(),
      arrivedAt: json['arrived_at']?.toString(),
      startedAt: json['started_at']?.toString(),
      clientAddress: json['client_address'] as String?,
      serviceLat: _toDouble(json['service_lat']),
      serviceLng: _toDouble(json['service_lng']),
      serviceListing: json['service_listings'] is Map<String, dynamic>
          ? json['service_listings'] as Map<String, dynamic>
          : json['service_listing'] is Map<String, dynamic>
              ? json['service_listing'] as Map<String, dynamic>
              : null,
      clientProfile: json['profiles'] is Map<String, dynamic>
          ? json['profiles'] as Map<String, dynamic>
          : json['client_profile'] is Map<String, dynamic>
              ? json['client_profile'] as Map<String, dynamic>
              : null,
    );
  }

  /// Create payload for POST /api/services/bookings/.
  ///
  /// The deployed serializer requires `scheduled_at` (the working web client
  /// always sends it and reads its field errors), so all three schedule keys
  /// derive from the single [scheduledAt] value. `total_price` is readOnly
  /// server-side and must NOT be sent. `status` is included so non-default
  /// flows (e.g. `inquiry` bookings that back pre-booking chat threads) can
  /// set it, matching the web client's `services.createBooking({ status })`.
  Map<String, dynamic> toCreateJson({
    required DateTime scheduledAt,
    String? notes,
  }) {
    return {
      'listing': listing,
      'status': status,
      'scheduled_at': scheduledAt.toIso8601String(),
      'scheduled_date':
          '${scheduledAt.year.toString().padLeft(4, '0')}-${scheduledAt.month.toString().padLeft(2, '0')}-${scheduledAt.day.toString().padLeft(2, '0')}',
      'scheduled_time':
          '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}:00',
      if (notes != null) 'notes': notes,
    };
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
