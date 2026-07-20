import 'package:flutter_stripe/flutter_stripe.dart';

import '/api/shph_api_client.dart';
import '/services/logging_service.dart';

enum PaymentProvider { stripe, maya }

enum PaymentStatus { success, cancelled, failed }

class PaymentResult {
  const PaymentResult({
    required this.status,
    this.transactionId,
    this.errorMessage,
  });

  final PaymentStatus status;
  final String? transactionId;
  final String? errorMessage;
}

class PaymentController {
  PaymentController._();
  static final PaymentController instance = PaymentController._();

  final _api = ShphApiClient.instance;

  String? _stripePublishableKey;
  String? get stripePublishableKey => _stripePublishableKey;

  Future<void> initializeStripe(String publishableKey) async {
    _stripePublishableKey = publishableKey;
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  Future<PaymentResult> processStripePayment({
    required double amount,
    required String currency,
    String? description,
    Map<String, String>? metadata,
  }) async {
    try {
      final clientSecret = await _fetchStripeClientSecret(
        amount: amount,
        currency: currency,
        description: description,
        metadata: metadata,
      );
      if (clientSecret == null) {
        return const PaymentResult(
          status: PaymentStatus.failed,
          errorMessage: 'Failed to obtain payment client secret',
        );
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'SerbisyoHub',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return PaymentResult(
        status: PaymentStatus.success,
        transactionId: _extractTransactionId(clientSecret),
      );
    } on StripeException catch (e) {
      final isCancel =
          e.error.localizedMessage?.toLowerCase().contains('cancel') == true ||
              e.error.code == FailureCode.Canceled;
      return PaymentResult(
        status: isCancel ? PaymentStatus.cancelled : PaymentStatus.failed,
        errorMessage: e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      LoggingService.error('Stripe payment error: $e',
          tag: 'PaymentController');
      return PaymentResult(
        status: PaymentStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<String?> _fetchStripeClientSecret({
    required double amount,
    required String currency,
    String? description,
    Map<String, String>? metadata,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/payments/create-intent/',
        data: {
          'amount': (amount * 100).round(),
          'currency': currency.toLowerCase(),
          'payment_method': 'card',
          if (description != null) 'description': description,
          if (metadata != null) 'metadata': metadata,
        },
      );
      final data = response.data ?? const <String, dynamic>{};
      return data['client_secret'] as String?;
    } catch (e) {
      LoggingService.error('Error fetching Stripe client secret: $e',
          tag: 'PaymentController');
      return null;
    }
  }

  Future<PaymentResult> processMayaPayment({
    required double amount,
    required String currency,
    String? description,
    Map<String, String>? metadata,
  }) async {
    try {
      final checkoutUrl = await _fetchMayaCheckoutUrl(
        amount: amount,
        currency: currency,
        description: description,
        metadata: metadata,
      );
      if (checkoutUrl == null) {
        return const PaymentResult(
          status: PaymentStatus.failed,
          errorMessage: 'Failed to obtain Maya checkout URL',
        );
      }

      LoggingService.info('Maya checkout URL: $checkoutUrl',
          tag: 'PaymentController');

      return PaymentResult(
        status: PaymentStatus.success,
        transactionId: checkoutUrl,
      );
    } catch (e) {
      LoggingService.error('Maya payment error: $e', tag: 'PaymentController');
      return PaymentResult(
        status: PaymentStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<String?> _fetchMayaCheckoutUrl({
    required double amount,
    required String currency,
    String? description,
    Map<String, String>? metadata,
  }) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/payments/create-intent/',
        data: {
          'totalAmount': {'value': amount, 'currency': currency},
          'amount': (amount * 100).round(),
          'currency': currency.toLowerCase(),
          'payment_method': 'paymaya',
          if (description != null) 'description': description,
          if (metadata != null) 'metadata': metadata,
        },
      );
      final data = response.data ?? const <String, dynamic>{};
      return data['checkout_url'] as String?;
    } catch (e) {
      LoggingService.error('Error fetching Maya checkout URL: $e',
          tag: 'PaymentController');
      return null;
    }
  }

  String _extractTransactionId(String clientSecret) {
    final parts = clientSecret.split('_secret_');
    return parts.isNotEmpty ? parts[0] : clientSecret;
  }
}
