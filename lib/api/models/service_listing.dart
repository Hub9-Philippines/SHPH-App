class ShphServiceListing {
  const ShphServiceListing({
    required this.id,
    required this.title,
    this.category,
    this.categoryName,
    this.provider,
    this.providerName,
    this.providerPhoto,
    this.description,
    this.basePrice,
    this.priceUnit,
    this.status,
    this.isAvailable,
    this.rating,
    this.thumbnail,
    this.reviewCount,
    this.createdAt,
    this.city,
    this.province,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isTimeMaterial = false,
  });

  final int id;
  final String title;
  final int? category;
  final String? categoryName;
  final int? provider;
  final String? providerName;
  final String? providerPhoto;
  final String? description;
  final double? basePrice;
  final String? priceUnit;
  final String? status;
  final String? isAvailable;
  final String? rating;
  final String? thumbnail;
  final int? reviewCount;
  final String? createdAt;
  final String? city;
  final String? province;

  /// Coarsened listing coordinates (public precision ~3 decimals). Null when
  /// the provider has no address on file.
  final double? latitude;
  final double? longitude;

  /// Server-computed distance in km; populated when the request carries
  /// lat/lng query params. Null otherwise — never fabricate client-side.
  final double? distanceKm;
  final bool isTimeMaterial;

  factory ShphServiceListing.fromJson(Map<String, dynamic> json) {
    return ShphServiceListing(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      category: json['category'] as int?,
      categoryName: json['category_name'] as String?,
      provider: json['provider'] as int? ?? json['provider_id'] as int?,
      providerName: json['provider_name'] as String?,
      providerPhoto: json['provider_photo'] as String?,
      description: json['description'] as String?,
      basePrice: _toDouble(json['base_price']),
      priceUnit: json['price_unit'] as String?,
      status: json['status'] as String?,
      isAvailable: json['is_available']?.toString(),
      rating: json['rating']?.toString(),
      thumbnail: json['thumbnail'] as String?,
      reviewCount: json['review_count'] as int?,
      createdAt: json['created_at'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      distanceKm: _toDouble(json['distance_km']),
      isTimeMaterial: json['is_time_material'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'category_name': categoryName,
        'provider': provider,
        'provider_name': providerName,
        'provider_photo': providerPhoto,
        'description': description,
        'base_price': basePrice,
        'price_unit': priceUnit,
        'status': status,
        'is_available': isAvailable,
        'rating': rating,
        'thumbnail': thumbnail,
        'review_count': reviewCount,
        'created_at': createdAt,
        'city': city,
        'province': province,
        'latitude': latitude,
        'longitude': longitude,
        'distance_km': distanceKm,
        'is_time_material': isTimeMaterial,
      };

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
