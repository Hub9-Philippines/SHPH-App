import '/api/resources/wallet_api.dart';
import '/services/logging_service.dart';

class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  final _walletApi = ShphWalletApi.instance;

  Future<Map<String, dynamic>> getWallet() async {
    try {
      return await _walletApi.getWallet();
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
      final intent = await _walletApi.createTopUpIntent(
        amount: amount,
      );
      final intentId = intent['intent_id'] as String?;
      if (intentId != null) {
        await _walletApi.confirmTopUp(intentId: intentId);
      }
      return true;
    } catch (e) {
      LoggingService.error('Error topping up wallet: $e', tag: 'WalletService');
      return false;
    }
  }

  Future<bool> payFromWallet({
    required double amount,
    String? bookingId,
    String? description,
  }) async {
    if (amount <= 0 || bookingId == null) return false;
    try {
      await _walletApi.payBookingWithWallet(bookingId);
      return true;
    } catch (e) {
      LoggingService.error('Error paying from wallet: $e', tag: 'WalletService');
      return false;
    }
  }
}
