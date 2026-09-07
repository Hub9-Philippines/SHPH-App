import '/api/resources/providers_api.dart';
import '/services/logging_service.dart';

class ProviderProfileService {
  ProviderProfileService._();
  static final ProviderProfileService instance = ProviderProfileService._();

  final _api = ShphProvidersApi.instance;

  Future<Map<String, dynamic>?> getProvider(dynamic id) async {
    try {
      return await _api.getProviderProfile(id);
    } catch (e) {
      LoggingService.error('Error fetching provider: $e',
          tag: 'ProviderProfileService');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getProviderListings(
    dynamic providerId,
  ) async {
    try {
      final page = await _api.listProviderListings(providerId);
      return page.results
          .map((l) => {
                'id': l.id,
                'title': l.title,
                'thumbnail': l.thumbnail,
                'basePrice': l.basePrice,
                'priceUnit': l.priceUnit,
                'rating': l.rating,
                'reviewCount': l.reviewCount,
                'categoryName': l.categoryName,
                'city': l.city,
                'province': l.province,
              })
          .toList();
    } catch (e) {
      LoggingService.error('Error fetching provider listings: $e',
          tag: 'ProviderProfileService');
      return [];
    }
  }

  /// Provider reviews are no longer served from a per-provider endpoint — the old
  /// `/api/services/listings/provider/{id}/reviews/` route doesn't exist in the
  /// deployed backend (it 404s). Reviews for a provider are now loaded on the
  /// dedicated reviews page by merging per-listing public reviews from the
  /// provider's top listings.
}
