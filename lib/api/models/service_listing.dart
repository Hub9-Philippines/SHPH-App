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

  factory ShphServiceListing.fromJson(Map<String, dynamic> json) {
    return ShphServiceListing(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      category: json['category'] as int?,
      categoryName: json['category_name'] as String?,
      provider: json['provider'] as int?,
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
    );
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
