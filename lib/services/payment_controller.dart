import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '/api/api_config.dart';
import '/demo/demo_mode.dart';
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

  String baseUrl = ApiConfig.baseUrl;

  String? _stripePublishableKey;
  String? get stripePublishableKey => _stripePublishableKey;

  Future<void> initializeStripe(String publishableKey) async {
    _stripePublishableKey = publishableKey;
    if (kDemoMode) return;
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
      if (kDemoMode) {
        return const PaymentResult(
          status: PaymentStatus.success,
          transactionId: 'demo-stripe-txn',
        );
      }
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
      final isCancel = e.error.localizedMessage?.toLowerCase().contains('cancel') == true ||
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
      final uri = Uri.parse('$baseUrl/api/payments/stripe/create-intent');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (amount * 100).round(),
          'currency': currency.toLowerCase(),
          if (description != null) 'description': description,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      if (response.statusCode != 200) {
        LoggingService.error(
          'Stripe create-intent failed: ${response.statusCode} ${response.body}',
          tag: 'PaymentController',
        );
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
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
      if (kDemoMode) {
        return const PaymentResult(
          status: PaymentStatus.success,
          transactionId: 'demo-maya-txn',
        );
      }
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
      LoggingService.error('Maya payment error: $e',
          tag: 'PaymentController');
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
      final uri = Uri.parse('$baseUrl/api/payments/maya/create-checkout');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'totalAmount': {'value': amount, 'currency': currency},
          if (description != null) 'description': description,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      if (response.statusCode != 200) {
        LoggingService.error(
          'Maya create-checkout failed: ${response.statusCode} ${response.body}',
          tag: 'PaymentController',
        );
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
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
