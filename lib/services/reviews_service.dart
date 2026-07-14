import '/api/bridges/api_row_mapper.dart';
import '/api/resources/bookings_api.dart';
import '/api/resources/favorites_api.dart';
import '/api/resources/services_api.dart';
import '/backend/supabase/database/tables/reviews.dart';
import '/services/logging_service.dart';

class ReviewsService {
  ReviewsService._();
  static final ReviewsService instance = ReviewsService._();
  final _reviewsApi = ShphReviewsApi.instance;
  final _servicesApi = ShphServicesApi.instance;

  Future<ReviewsRow?> addReview({
    required int serviceListingId,
    required int rating,
    String? comment,
  }) async {
    LoggingService.error(
      'Creating a review requires a booking ID; use reviewBooking instead.',
      tag: 'ReviewsService',
    );
    return null;
  }

  Future<ReviewsRow?> reviewBooking({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final data = await ShphBookingsApi.instance.reviewBooking(
        bookingId,
        rating: rating,
        comment: comment,
      );
      return ReviewsRow(data);
    } catch (e) {
      LoggingService.error('API review creation failed: $e',
          tag: 'ReviewsService');
      return null;
    }
  }

  Future<List<ReviewsRow>> getServiceReviews(int serviceListingId) async {
    try {
      final page = await _reviewsApi.listListingReviews(serviceListingId);
      return page.results
          .map((r) =>
              ApiRowMapper.reviewToRow(r, serviceListingId: serviceListingId))
          .toList();
    } catch (e) {
      LoggingService.error('API listing reviews failed: $e',
          tag: 'ReviewsService');
      return [];
    }
  }

  Future<List<ReviewsRow>> getUserReviews() async {
    try {
      return (await _servicesApi.listMyReviews()).map(ReviewsRow.new).toList();
    } catch (e) {
      LoggingService.error('API user reviews failed: $e',
          tag: 'ReviewsService');
      return [];
    }
  }

  Future<bool> updateReview(String reviewId,
      {int? rating, String? comment}) async {
    LoggingService.error('Review editing has no API endpoint.',
        tag: 'ReviewsService');
    return false;
  }

  Future<bool> deleteReview(String reviewId) async {
    LoggingService.error('Review deletion has no API endpoint.',
        tag: 'ReviewsService');
    return false;
  }

  Future<bool> respondToReview(String reviewId, String reply) async {
    try {
      await _servicesApi.replyToReview(int.parse(reviewId), reply: reply);
      return true;
    } catch (e) {
      LoggingService.error('API review reply failed: $e',
          tag: 'ReviewsService');
      return false;
    }
  }

  Future<bool> hasUserReviewed(int serviceListingId) async {
    final reviews = await getUserReviews();
    return reviews.any((r) => r.serviceListingId == serviceListingId);
  }

  Future<Map<String, dynamic>> getServiceRatingStats(
      int serviceListingId) async {
    final reviews = await getServiceReviews(serviceListingId);
    if (reviews.isEmpty) return {'average': 0.0, 'count': 0};
    final average =
        reviews.fold<int>(0, (sum, r) => sum + r.rating) / reviews.length;
    return {'average': average, 'count': reviews.length};
  }
}
