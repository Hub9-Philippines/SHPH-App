import '/api/models/paginated_response.dart';
import '/api/models/review.dart';
import '/api/models/service_listing.dart';
import '/api/shph_api_client.dart';

class ShphProvidersApi {
  ShphProvidersApi._();

  static final ShphProvidersApi instance = ShphProvidersApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getProvider(dynamic id) async {
    final response =
        await _client.get<Map<String, dynamic>>('/api/users/$id/');
    return response.data ?? {};
  }

  /// Public provider profile from the Providers API. Returns
  /// `ProviderProfileResponse` fields: id, display_name, photo_url, bio,
  /// kyc_verified, total_completed_bookings, avg_rating, member_since.
  Future<Map<String, dynamic>> getProviderProfile(dynamic providerId) async {
    final response = await _client
        .get<Map<String, dynamic>>('/api/providers/$providerId/');
    return response.data ?? {};
  }

  Future<PaginatedResponse<ShphServiceListing>> listProviderListings(
    dynamic providerId, {
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/providers/$providerId/listings/',
      queryParameters: {
        if (page != null) 'page': page,
      },
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphServiceListing.fromJson,
    );
  }

  Future<PaginatedResponse<ShphReview>> listProviderReviews(
    dynamic providerId, {
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/services/listings/provider/$providerId/reviews/',
      queryParameters: {if (page != null) 'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data ?? {},
      ShphReview.fromJson,
    );
  }
}
