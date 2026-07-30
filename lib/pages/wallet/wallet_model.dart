import 'package:flutter/material.dart';

import '/services/logging_service.dart';
import '/services/wallet_service.dart';

class WalletModel {
  double balance = 0.0;
  double totalEarnings = 0.0;
  double totalSpent = 0.0;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = false;

  Future<void> loadTransactions() async {
    isLoading = true;
    try {
      final data = await WalletService.instance.getWalletData();
      balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      totalEarnings = (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
      totalSpent = (data['totalSpent'] as num?)?.toDouble() ?? 0.0;
      transactions = (data['transactions'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
    } catch (e) {
      LoggingService.error('Error loading wallet: $e', tag: 'WalletModel');
    } finally {
      isLoading = false;
    }
  }

  void dispose() {}
}
