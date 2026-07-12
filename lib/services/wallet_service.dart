import 'package:supabase_flutter/supabase_flutter.dart';

import '/services/logging_service.dart';

class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  final _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<Map<String, dynamic>> getWallet() async {
    final userId = _currentUserId;
    if (userId == null) {
      return {'balance': 0.0, 'transactions': <Map<String, dynamic>>[]};
    }

    try {
      final wallet = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final transactions = await _supabase
          .from('wallet_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      final balance = (wallet?['balance'] as num?)?.toDouble() ?? 0.0;

      return {
        'balance': balance,
        'transactions': transactions.cast<Map<String, dynamic>>(),
      };
    } catch (e) {
      LoggingService.error('Error fetching wallet: $e', tag: 'WalletService');
      return {'balance': 0.0, 'transactions': <Map<String, dynamic>>[]};
    }
  }

  Future<bool> topUp({
    required double amount,
    String? referenceId,
    String? description,
  }) async {
    if (amount <= 0) return false;

    try {
      await _supabase.rpc('top_up_wallet', params: {
        'p_user_id': _currentUserId,
        'p_amount': amount,
        'p_description': description ?? 'Wallet top-up',
        'p_reference_id': referenceId,
      });
      return true;
    } catch (e) {
      LoggingService.error('Error topping up wallet: $e',
          tag: 'WalletService');
      return false;
    }
  }

  Future<bool> payFromWallet({
    required double amount,
    String? bookingId,
    String? description,
  }) async {
    if (amount <= 0) return false;

    try {
      await _supabase.rpc('pay_from_wallet', params: {
        'p_user_id': _currentUserId,
        'p_amount': amount,
        'p_booking_id': bookingId,
        'p_description': description ?? 'Booking payment',
      });
      return true;
    } catch (e) {
      LoggingService.error('Error paying from wallet: $e',
          tag: 'WalletService');
      return false;
    }
  }
}
