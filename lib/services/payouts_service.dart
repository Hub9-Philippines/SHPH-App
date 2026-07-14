import '/api/resources/payouts_api.dart';
import '/services/logging_service.dart';

class PayoutsService {
  PayoutsService._();
  static final PayoutsService instance = PayoutsService._();
  final _api = ShphPayoutsApi.instance;

  Future<List<Map<String, dynamic>>> getPayoutRequests() async {
    try {
      return await _api.listMyPayouts();
    } catch (e) {
      LoggingService.error('Payout fetch failed: $e', tag: 'PayoutsService');
      return [];
    }
  }

  Future<bool> requestPayout({
    required double amount,
    String? paymentMethodId,
    String? note,
  }) async =>
      _run(() => _api.requestPayout({
            'amount': amount,
            if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
            if (note != null) 'note': note,
          }));

  Future<bool> cancelPayoutRequest(String id) =>
      _run(() => _api.cancelPayout(id));

  Future<bool> _run(Future<Object?> Function() operation) async {
    try {
      await operation();
      return true;
    } catch (e) {
      LoggingService.error('Payout operation failed: $e',
          tag: 'PayoutsService');
      return false;
    }
  }
}
