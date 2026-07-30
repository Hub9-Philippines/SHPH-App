import 'package:flutter/material.dart';

import '/api/resources/earnings_api.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'earnings_widget.dart' show EarningsWidget;

class EarningsModel extends FlutterFlowModel<EarningsWidget> {
  Map<String, dynamic> summary = {};
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> payouts = [];
  bool isLoading = true;
  String? fetchError;

  @override
  void initState(BuildContext context) {}

  Future<void> load() async {
    isLoading = true;
    fetchError = null;
    try {
      final api = ShphEarningsApi.instance;
      final summaryRes = await api.getSummary();
      final txRes = await api.getTransactions();
      final payoutsRes = await api.getPayouts();
      summary = summaryRes;
      transactions = (txRes['results'] as List? ?? txRes['data'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      payouts = (payoutsRes['results'] as List? ??
              payoutsRes['data'] as List? ??
              [])
          .cast<Map<String, dynamic>>();
    } catch (e) {
      fetchError = 'Failed to load earnings.';
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
