import '/api/bridges/api_row_mapper.dart';
import '/api/resources/favorites_api.dart';
import '/backend/shph_db/database/tables/reviews.dart';
import '/services/logging_service.dart';

class ReviewsService {
  ReviewsService._();
  static final ReviewsService instance = ReviewsService._();

  final _reviewsApi = ShphReviewsApi.instance;

  Future<Map<String, dynamic>?> addReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      return await _reviewsApi.createReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
    } catch (e) {
      LoggingService.error('addReview failed: $e', tag: 'ReviewsService');
      return null;
    }
  }

  Future<List<ReviewsRow>> getServiceReviews(int serviceListingId) async {
    try {
      final page = await _reviewsApi.listListingReviews(serviceListingId);
      return page.results
          .map((review) => ApiRowMapper.reviewToRow(
                review,
                serviceListingId: serviceListingId,
              ))
          .toList();
    } catch (e) {
      LoggingService.error('getServiceReviews failed: $e',
          tag: 'ReviewsService');
      return [];
    }
  }

  Future<List<ReviewsRow>> getUserReviews() async {
    try {
      final page = await _reviewsApi.listMyReviews();
      return page.results.map(ApiRowMapper.reviewToRow).toList();
    } catch (e) {
      LoggingService.error('getUserReviews failed: $e', tag: 'ReviewsService');
      return [];
    }
  }

  Future<bool> hasUserReviewed(int serviceListingId) async {
    try {
      final page = await _reviewsApi.listListingReviews(serviceListingId);
      final myReviews = await _reviewsApi.listMyReviews();
      final myReviewIds = myReviews.results.map((r) => r.id).toSet();
      return page.results.any((r) => myReviewIds.contains(r.id));
    } catch (e) {
      LoggingService.error('hasUserReviewed failed: $e', tag: 'ReviewsService');
      return false;
    }
  }

  Future<Map<String, dynamic>> getServiceRatingStats(
      int serviceListingId) async {
    try {
      final page = await _reviewsApi.listListingReviews(serviceListingId);
      if (page.results.isEmpty) {
        return {'average': 0.0, 'count': 0};
      }
      final ratings = page.results.map((review) => review.rating).toList();
      final average = ratings.reduce((a, b) => a + b) / ratings.length;
      return {'average': average, 'count': ratings.length};
    } catch (e) {
      LoggingService.error('getServiceRatingStats failed: $e',
          tag: 'ReviewsService');
      return {'average': 0.0, 'count': 0};
    }
  }
}
