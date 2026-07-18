import '/api/bridges/api_row_mapper.dart';
import '/api/resources/favorites_api.dart';
import '/backend/shph_db/database/tables/service_listings.dart';
import '/services/logging_service.dart';

class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final _favoritesApi = ShphFavoritesApi.instance;

  Future<bool> addToFavorites(int serviceListingId) async {
    try {
      await _favoritesApi.addFavorite(serviceListingId);
      return true;
    } catch (e) {
      LoggingService.error('addToFavorites failed: $e',
          tag: 'FavoritesService');
      return false;
    }
  }

  Future<bool> removeFromFavorites(int serviceListingId) async {
    try {
      await _favoritesApi.removeFavorite(serviceListingId);
      return true;
    } catch (e) {
      LoggingService.error('removeFromFavorites failed: $e',
          tag: 'FavoritesService');
      return false;
    }
  }

  Future<bool> isFavorite(int serviceListingId) async {
    try {
      final favorites = await _favoritesApi.listFavorites();
      return favorites.any((listing) => listing.id == serviceListingId);
    } catch (e) {
      LoggingService.error('isFavorite failed: $e', tag: 'FavoritesService');
      return false;
    }
  }

  Future<List<ServiceListingsRow>> getFavoriteServices() async {
    try {
      final favorites = await _favoritesApi.listFavorites();
      return favorites.map(ApiRowMapper.serviceListingToRow).toList();
    } catch (e) {
      LoggingService.error('getFavoriteServices failed: $e',
          tag: 'FavoritesService');
      return [];
    }
  }

  Future<bool> toggleFavorite(int serviceListingId) async {
    final isFav = await isFavorite(serviceListingId);
    if (isFav) {
      return removeFromFavorites(serviceListingId);
    }
    return addToFavorites(serviceListingId);
  }
}
