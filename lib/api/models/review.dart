class ShphReview {
  const ShphReview({
    required this.id,
    required this.rating,
    this.booking,
    this.reviewer,
    this.reviewerName,
    this.reviewerPhoto,
    this.comment,
    this.createdAt,
    this.serviceListingId,
  });

  final int id;
  final int rating;
  final String? booking;
  final int? reviewer;
  final String? reviewerName;
  final String? reviewerPhoto;
  final String? comment;
  final String? createdAt;
  final int? serviceListingId;

  factory ShphReview.fromJson(Map<String, dynamic> json) {
    return ShphReview(
      id: json['id'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      booking: json['booking']?.toString(),
      reviewer: json['reviewer'] as int?,
      reviewerName: json['reviewer_name'] as String?,
      reviewerPhoto: json['reviewer_photo'] as String?,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String?,
      serviceListingId: json['service_listing_id'] as int?,
    );
  }
}
