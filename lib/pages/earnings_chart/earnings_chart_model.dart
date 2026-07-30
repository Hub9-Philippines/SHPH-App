import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/earnings_service.dart';
import '/theme/app_theme.dart';
import 'earnings_chart_widget.dart' show EarningsChartWidget;

class EarningsChartModel extends FlutterFlowModel<EarningsChartWidget> {
  Map<String, dynamic> earningsData = {};
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadEarnings() async {
    isLoading = true;
    try {
      earningsData = await EarningsService.instance.getEarningsSummary();
    } catch (e) {
      debugPrint('Error loading earnings: $e');
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
