import '/backend/supabase/supabase.dart';
import '/services/logging_service.dart';

class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final _supabase = Supabase.instance.client;

  // Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // Add service to favorites
  Future<bool> addToFavorites(int serviceListingId) async {
    try {
      final userId = _currentUserId;
      if (userId == null)
        return false;

      await _supabase.from('favorites').insert({
        'user_id': userId,
        'service_listing_id': serviceListingId,
      });

      return true;
    } catch (e) {
      LoggingService.error('Error adding to favorites: $e', tag: 'FavoritesService');
      return false;
    }
  }

  // Remove service from favorites
  Future<bool> removeFromFavorites(int serviceListingId) async {
    try {
      final userId = _currentUserId;
      if (userId == null)
        return false;

      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('service_listing_id', serviceListingId);

      return true;
    } catch (e) {
      LoggingService.error('Error removing from favorites: $e', tag: 'FavoritesService');
      return false;
    }
  }

  // Check if service is in favorites
  Future<bool> isFavorite(int serviceListingId) async {
    try {
      final userId = _currentUserId;
      if (userId == null)
        return false;

      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('service_listing_id', serviceListingId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      LoggingService.error('Error checking favorite status: $e', tag: 'FavoritesService');
      return false;
    }
  }

  // Get all favorite services for current user
  Future<List<ServiceListingsRow>> getFavoriteServices() async {
    try {
      final userId = _currentUserId;
      if (userId == null)
        return [];

      final response = await _supabase
          .from('favorites')
          .select('service_listings(*)')
          .eq('user_id', userId);

      final services = response
          .map((fav) => ServiceListingsRow(fav['service_listings']))
          .toList();

      return services;
    } catch (e) {
      LoggingService.error('Error fetching favorites: $e', tag: 'FavoritesService');
      return [];
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(int serviceListingId) async {
    final isFav = await isFavorite(serviceListingId);
    if (isFav) {
      return removeFromFavorites(serviceListingId);
    } else {
      return addToFavorites(serviceListingId);
    }
  }
}
