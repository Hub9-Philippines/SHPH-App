import '/api/bridges/api_row_mapper.dart';
import '/api/resources/favorites_api.dart';
import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final _supabase = Supabase.instance.client;
  final _favoritesApi = ShphFavoritesApi.instance;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<bool> addToFavorites(int serviceListingId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _favoritesApi.addFavorite(serviceListingId);
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API addToFavorites failed, falling back to Supabase: $e',
          tag: 'FavoritesService',
        );
      }
    }

    try {
      final userId = _currentUserId;
      if (userId == null) return false;

      await _supabase.from('favorites').insert({
        'user_id': userId,
        'service_listing_id': serviceListingId,
      });

      return true;
    } catch (e) {
      LoggingService.error('Error adding to favorites: $e',
          tag: 'FavoritesService');
      return false;
    }
  }

  Future<bool> removeFromFavorites(int serviceListingId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        await _favoritesApi.removeFavorite(serviceListingId);
        return true;
      } catch (e) {
        LoggingService.error(
          'SHPH API removeFromFavorites failed, falling back to Supabase: $e',
          tag: 'FavoritesService',
        );
      }
    }

    try {
      final userId = _currentUserId;
      if (userId == null) return false;

      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('service_listing_id', serviceListingId);

      return true;
    } catch (e) {
      LoggingService.error('Error removing from favorites: $e',
          tag: 'FavoritesService');
      return false;
    }
  }

  Future<bool> isFavorite(int serviceListingId) async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final favorites = await _favoritesApi.listFavorites();
        return favorites.any((listing) => listing.id == serviceListingId);
      } catch (e) {
        LoggingService.error(
          'SHPH API isFavorite failed, falling back to Supabase: $e',
          tag: 'FavoritesService',
        );
      }
    }

    try {
      final userId = _currentUserId;
      if (userId == null) return false;

      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('service_listing_id', serviceListingId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      LoggingService.error('Error checking favorite status: $e',
          tag: 'FavoritesService');
      return false;
    }
  }

  Future<List<ServiceListingsRow>> getFavoriteServices() async {
    if (await ApiRowMapper.canUseApi()) {
      try {
        final favorites = await _favoritesApi.listFavorites();
        return favorites.map(ApiRowMapper.serviceListingToRow).toList();
      } catch (e) {
        LoggingService.error(
          'SHPH API getFavoriteServices failed, falling back to Supabase: $e',
          tag: 'FavoritesService',
        );
      }
    }

    try {
      final userId = _currentUserId;
      if (userId == null) return [];

      final response = await _supabase
          .from('favorites')
          .select('service_listings(*)')
          .eq('user_id', userId);

      final services = response
          .map((fav) => ServiceListingsRow(fav['service_listings']))
          .toList();

      return services;
    } catch (e) {
      LoggingService.error('Error fetching favorites: $e',
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
