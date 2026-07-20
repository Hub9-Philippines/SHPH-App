import '/api/shph_api_client.dart';

class ShphPaymentsApi {
  ShphPaymentsApi._();

  static final ShphPaymentsApi instance = ShphPaymentsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/payments/create-intent/',
      data: {'amount': amount, 'currency': currency},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required Map<String, dynamic> paymentDetails,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/payments/confirm/',
      data: {
        'payment_intent_id': paymentIntentId,
        ...paymentDetails,
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getBookingPayment(String bookingId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/payments/booking/$bookingId/',
    );
    return response.data ?? {};
  }

  Future<void> refundBookingPayment(String bookingId, {String? reason}) async {
    await _client.post(
      '/api/payments/booking/$bookingId/refund/',
      data: {if (reason != null) 'reason': reason},
    );
  }

  Future<void> tipBookingProvider(String bookingId,
      {required double amount}) async {
    await _client.post(
      '/api/payments/booking/$bookingId/tip/',
      data: {'amount': amount},
    );
  }

  Future<Map<String, dynamic>> validateVoucher(String code) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/payments/voucher/validate/',
      data: {'code': code},
    );
    return response.data ?? {};
  }
}
