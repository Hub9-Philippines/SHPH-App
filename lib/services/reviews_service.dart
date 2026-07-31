import '/api/bridges/api_row_mapper.dart';
import '/api/resources/favorites_api.dart';
import '/backend/supabase/database/tables/reviews.dart';
import '/services/logging_service.dart';

class ReviewsService {
  ReviewsService._();
  static final ReviewsService instance = ReviewsService._();

  final _reviewsApi = ShphReviewsApi.instance;

  Future<ReviewsRow?> addReview({
    required int serviceListingId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _reviewsApi.listListingReviews(serviceListingId);
      return null;
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
    return [];
  }

  Future<bool> updateReview(String reviewId,
      {int? rating, String? comment}) async {
    return false;
  }

  Future<bool> deleteReview(String reviewId) async {
    return false;
  }

  Future<bool> hasUserReviewed(int serviceListingId) async {
    return false;
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
