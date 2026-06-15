class ServiceListing {

  ServiceListing({
    required this.id,
    required this.title, this.category,
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
  });

  factory ServiceListing.fromJson(Map<String, dynamic> json) => ServiceListing(
      id: json['id'] as int,
      category: json['category'] as int?,
      categoryName: json['category_name'] as String?,
      provider: json['provider'] as int?,
      providerName: json['provider_name'] as String?,
      providerPhoto: json['provider_photo'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      basePrice: (json['base_price'] as num?)?.toDouble(),
      priceUnit: json['price_unit'] as String?,
      status: json['status'] as String?,
      isAvailable: json['is_available'] as String?,
      rating: json['rating'] as String?,
      thumbnail: json['thumbnail'] as String?,
      reviewCount: json['review_count'] as int?,
    );
  final int id;
  final int? category;
  final String? categoryName;
  final int? provider;
  final String? providerName;
  final String? providerPhoto;
  final String title;
  final String? description;
  final double? basePrice;
  final String? priceUnit;
  final String? status;
  final String? isAvailable;
  final String? rating;
  final String? thumbnail;
  final int? reviewCount;

  double? get ratingValue {
    if (rating == null) {
      return null;
    }
    return double.tryParse(rating!);
  }

  String get formattedPrice {
    if (basePrice == null) {
      return '';
    }
    return '₱${basePrice!.toStringAsFixed(0)}';
  }
}
