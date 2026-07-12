import '/api/bridges/api_row_mapper.dart';
import '/api/resources/favorites_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class ReviewsService {
  ReviewsService._();
  static final ReviewsService instance = ReviewsService._();

  final _supabase = Supabase.instance.client;
  final _reviewsApi = ShphReviewsApi.instance;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<ReviewsRow?> addReview({
    required int serviceListingId,
    required int rating,
    String? comment,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return null;

      final review = await _supabase.from('reviews').insert({
        'user_id': userId,
        'service_listing_id': serviceListingId,
        'rating': rating,
        'comment': comment,
      }).select().single();

      return ReviewsRow(review);
    } catch (e) {
      LoggingService.error('Error adding review: $e', tag: 'ReviewsService');
      return null;
    }
  }

  Future<List<ReviewsRow>> getServiceReviews(int serviceListingId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _reviewsApi.listListingReviews(serviceListingId);
        return page.results
            .map((review) => ApiRowMapper.reviewToRow(
                  review,
                  serviceListingId: serviceListingId,
                ))
            .toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API getServiceReviews failed, falling back to Supabase: $e',
          tag: 'ReviewsService',
        );
      }
    }

    try {
      final response = await _supabase
          .from('reviews')
          .select('*, profiles(*)')
          .eq('service_listing_id', serviceListingId)
          .order('created_at', ascending: false);

      return response.map(ReviewsRow.new).toList();
    } catch (e) {
      LoggingService.error('Error fetching reviews: $e', tag: 'ReviewsService');
      return [];
    }
  }

  Future<List<ReviewsRow>> getUserReviews() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return [];

      final response = await _supabase
          .from('reviews')
          .select('*, service_listings(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map(ReviewsRow.new).toList();
    } catch (e) {
      LoggingService.error('Error fetching user reviews: $e',
          tag: 'ReviewsService');
      return [];
    }
  }

  Future<bool> updateReview(String reviewId,
      {int? rating, String? comment}) async {
    try {
      final updates = <String, dynamic>{};
      if (rating != null) updates['rating'] = rating;
      if (comment != null) updates['comment'] = comment;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('reviews').update(updates).eq('id', reviewId);
      return true;
    } catch (e) {
      LoggingService.error('Error updating review: $e', tag: 'ReviewsService');
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _supabase.from('reviews').delete().eq('id', reviewId);
      return true;
    } catch (e) {
      LoggingService.error('Error deleting review: $e', tag: 'ReviewsService');
      return false;
    }
  }

  Future<bool> respondToReview(String reviewId, String reply) async {
    try {
      await _supabase.from('reviews').update({
        'provider_reply': reply,
        'provider_reply_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);
      return true;
    } catch (e) {
      LoggingService.error('Error responding to review: $e',
          tag: 'ReviewsService');
      return false;
    }
  }

  Future<bool> hasUserReviewed(int serviceListingId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return false;

      final response = await _supabase
          .from('reviews')
          .select()
          .eq('user_id', userId)
          .eq('service_listing_id', serviceListingId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      LoggingService.error('Error checking review status: $e',
          tag: 'ReviewsService');
      return false;
    }
  }

  Future<Map<String, dynamic>> getServiceRatingStats(
      int serviceListingId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final page = await _reviewsApi.listListingReviews(serviceListingId);
        if (page.results.isEmpty) {
          return {'average': 0.0, 'count': 0};
        }
        final ratings = page.results.map((review) => review.rating).toList();
        final average = ratings.reduce((a, b) => a + b) / ratings.length;
        return {'average': average, 'count': ratings.length};
      } catch (e) {
        LoggingService.error(
          'SHPH API getServiceRatingStats failed, falling back to Supabase: $e',
          tag: 'ReviewsService',
        );
      }
    }

    try {
      final response = await _supabase
          .from('reviews')
          .select('rating')
          .eq('service_listing_id', serviceListingId);

      if (response.isEmpty) {
        return {'average': 0.0, 'count': 0};
      }

      final ratings = response.map((r) => r['rating'] as int).toList();
      final average = ratings.reduce((a, b) => a + b) / ratings.length;

      return {'average': average, 'count': ratings.length};
    } catch (e) {
      LoggingService.error('Error fetching rating stats: $e',
          tag: 'ReviewsService');
      return {'average': 0.0, 'count': 0};
    }
  }
}
