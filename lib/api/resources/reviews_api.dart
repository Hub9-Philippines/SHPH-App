import '/api/shph_api_client.dart';

/// Reviews endpoints from SHPH API (`/api/services/reviews/*`).
class ShphReviewsApi {
  ShphReviewsApi._();

  static final ShphReviewsApi instance = ShphReviewsApi._();
  final _client = ShphApiClient.instance;

  Future<List<Map<String, dynamic>>> getListingReviews(int listingId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/listings/$listingId/reviews/',
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    if (data is List) {
      return (data! as List).whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMine() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/reviews/mine/',
    );
    final data = response.data;
    final results = data?['results'];
    if (results is List) {
      return results.whereType<Map<String, dynamic>>().toList();
    }
    if (data is List) {
      return (data! as List).whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> replyReview(
    int reviewId,
    String providerReply,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/services/reviews/$reviewId/reply/',
      data: {'provider_reply': providerReply},
    );
    return response.data ?? {};
  }
}
