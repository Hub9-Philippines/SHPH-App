import 'package:flutter/material.dart';

class WalletModel {
  double balance = 2850.00;
  double totalEarnings = 12400.00;
  double totalSpent = 9550.00;
  List<Map<String, dynamic>> transactions = [];

  void loadTransactions() {
    transactions = [
      {
        'type': 'credit',
        'description': 'Service Payment — Plumbing Repair',
        'date': 'Jul 25, 2026',
        'amount': 1500.00,
      },
      {
        'type': 'debit',
        'description': 'Top-up via GCash',
        'date': 'Jul 24, 2026',
        'amount': 2000.00,
      },
      {
        'type': 'credit',
        'description': 'Service Payment — Electrical Wiring',
        'date': 'Jul 22, 2026',
        'amount': 3500.00,
      },
      {
        'type': 'debit',
        'description': 'Withdrawal to Bank',
        'date': 'Jul 20, 2026',
        'amount': 5000.00,
      },
      {
        'type': 'credit',
        'description': 'Service Payment — AC Cleaning',
        'date': 'Jul 18, 2026',
        'amount': 1200.00,
      },
    ];
  }

  void dispose() {}
}
