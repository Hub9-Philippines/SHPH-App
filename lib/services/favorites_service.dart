import '/api/bridges/api_row_mapper.dart';
import '/api/resources/favorites_api.dart';
import '/backend/supabase/database/tables/service_listings.dart';
import '/services/logging_service.dart';

class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final _api = ShphFavoritesApi.instance;

  Future<bool> addToFavorites(int listingId) =>
      _run(() => _api.addFavorite(listingId));

  Future<bool> removeFromFavorites(int listingId) =>
      _run(() => _api.removeFavorite(listingId));

  Future<bool> isFavorite(int listingId) async {
    try {
      return (await _api.getAllFavorites()).any((item) => item.id == listingId);
    } catch (e) {
      LoggingService.error('Error checking favorite: $e',
          tag: 'FavoritesService');
      return false;
    }
  }

  Future<List<ServiceListingsRow>> getFavoriteServices() async {
    try {
      final favorites = await _api.getAllFavorites();
      return favorites.map(ApiRowMapper.serviceListingToRow).toList();
    } catch (e) {
      LoggingService.error('Error fetching favorites: $e',
          tag: 'FavoritesService');
      return [];
    }
  }

  Future<bool> toggleFavorite(int listingId) async =>
      await isFavorite(listingId)
          ? removeFromFavorites(listingId)
          : addToFavorites(listingId);

  Future<bool> _run(Future<void> Function() operation) async {
    try {
      await operation();
      return true;
    } catch (e) {
      LoggingService.error('Favorite operation failed: $e',
          tag: 'FavoritesService');
      return false;
    }
  }
}
