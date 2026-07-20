import '/api/models/paginated_response.dart';
import '/api/models/review.dart';
import '/api/models/service_listing.dart';
import '/api/shph_api_client.dart';

/// Favorites endpoints from SHPH API.yaml (`/api/favorites/*`).
class ShphFavoritesApi {
  ShphFavoritesApi._();

  static final ShphFavoritesApi instance = ShphFavoritesApi._();
  final _client = ShphApiClient.instance;

  Future<void> addFavorite(int listingId) async {
    await _client.post(
      '/api/favorites/',
      data: {'listing_id': listingId},
    );
  }

  Future<void> removeFavorite(int listingId) async {
    await _client.delete('/api/favorites/$listingId/');
  }

  Future<List<ShphServiceListing>> listFavorites() async {
    final response = await _client.post<List<dynamic>>(
      '/api/favorites/list/',
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ShphServiceListing.fromJson)
        .toList();
  }

  @Deprecated('Use listFavorites() instead. GET /api/favorites/ returns all favorites.')
  Future<List<ShphServiceListing>> getAllFavorites({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/favorites/',
      queryParameters: {if (page != null) 'page': page},
    );
    final data = response.data ?? {};
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(ShphServiceListing.fromJson)
        .toList();
  }
}

/// Reviews endpoints from SHPH API.yaml (`/api/services/listings/{id}/reviews/`).
class ShphReviewsApi {
  ShphReviewsApi._();

  static final ShphReviewsApi instance = ShphReviewsApi._();
  final _client = ShphApiClient.instance;

  Future<PaginatedResponse<ShphReview>> listListingReviews(
    int listingId, {
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/listings/$listingId/reviews/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphReview.fromJson,
    );
  }
}
