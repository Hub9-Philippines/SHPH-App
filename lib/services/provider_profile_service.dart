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

  Future<List<Map<String, dynamic>>> getProviderReviews(
    dynamic providerId,
  ) async {
    try {
      final page = await _api.listProviderReviews(providerId);
      return page.results
          .map((r) => {
                'id': r.id,
                'rating': r.rating,
                'comment': r.comment,
                'reviewerName': r.reviewerName,
                'reviewerPhoto': r.reviewerPhoto,
                'createdAt': r.createdAt,
              })
          .toList();
    } catch (e) {
      LoggingService.error('Error fetching provider reviews: $e',
          tag: 'ProviderProfileService');
      return [];
    }
  }
}
