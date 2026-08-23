// ignore Unused import: 'package:dio/dio.dart'.
// import 'package:dio/dio.dart';

import '/api/shph_api_client.dart';

class ShphEarningsApi {
  ShphEarningsApi._();

  static final ShphEarningsApi instance = ShphEarningsApi._();
  final _client = ShphApiClient.instance;

  Future<Map<String, dynamic>> getSummary() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/earnings/summary/',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getTransactions({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/earnings/transactions/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getPayouts({int? page}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/earnings/payouts/',
      queryParameters: {if (page != null) 'page': page},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> requestPayout({
    required double amount,
    required int paymentMethodId,
    String? stepUpToken,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/earnings/request-payout/',
      data: {
        'amount': amount,
        'payment_method_id': paymentMethodId,
        if (stepUpToken != null) 'step_up_token': stepUpToken,
      },
    );
    return response.data ?? {};
  }
}
