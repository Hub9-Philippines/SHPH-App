import 'package:supabase_flutter/supabase_flutter.dart';

import '/services/logging_service.dart';

class PayoutsService {
  PayoutsService._();
  static final PayoutsService instance = PayoutsService._();

  final _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> getPayoutRequests() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final result = await _supabase
          .from('payouts')
          .select('''
            id,
            amount,
            status,
            requested_at,
            approved_at,
            completed_at,
            rejected_at,
            rejection_reason,
            note,
            payment_methods(id, type, label, details)
          ''')
          .eq('provider_id', userId)
          .order('requested_at', ascending: false);

      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      LoggingService.error('Error fetching payouts: $e', tag: 'PayoutsService');
      return [];
    }
  }

  Future<bool> requestPayout({
    required double amount,
    String? paymentMethodId,
    String? note,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      await _supabase.from('payouts').insert({
        'provider_id': userId,
        'amount': amount,
        'payment_method_id': paymentMethodId,
        'note': note,
        'status': 'pending',
      });
      return true;
    } catch (e) {
      LoggingService.error('Error requesting payout: $e',
          tag: 'PayoutsService');
      return false;
    }
  }

  Future<bool> cancelPayoutRequest(String payoutId) async {
    try {
      await _supabase
          .from('payouts')
          .update({'status': 'rejected', 'rejected_at': DateTime.now().toIso8601String(), 'rejection_reason': 'Cancelled by provider'})
          .eq('id', payoutId);
      return true;
    } catch (e) {
      LoggingService.error('Error cancelling payout: $e',
          tag: 'PayoutsService');
      return false;
    }
  }
}
