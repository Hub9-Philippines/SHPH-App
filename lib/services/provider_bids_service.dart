import 'package:supabase_flutter/supabase_flutter.dart';

import '/services/logging_service.dart';

class ProviderBidsService {
  ProviderBidsService._();
  static final ProviderBidsService instance = ProviderBidsService._();

  final _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> getProviderBids() async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      final offers = await _supabase
          .from('dispatch_offers')
          .select('''
            id,
            job_id,
            provider_id,
            status,
            offered_at,
            responded_at,
            job_requests(
              id,
              service_type,
              status,
              requested_time,
              created_at,
              client_id,
              profiles!job_requests_client_id_fkey(display_name, first_name, last_name)
            )
          ''')
          .eq('provider_id', userId)
          .order('offered_at', ascending: false);

      return offers.cast<Map<String, dynamic>>();
    } catch (e) {
      LoggingService.error('Error fetching provider bids: $e',
          tag: 'ProviderBidsService');
      return [];
    }
  }

  Future<bool> withdrawBid(String offerId) async {
    try {
      await _supabase
          .from('dispatch_offers')
          .update({
            'status': 'rejected',
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', offerId);
      return true;
    } catch (e) {
      LoggingService.error('Error withdrawing bid: $e',
          tag: 'ProviderBidsService');
      return false;
    }
  }
}
