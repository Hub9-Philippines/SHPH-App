import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/provider_analytics_service.dart';
import 'provider_analytics_widget.dart' show ProviderAnalyticsWidget;

class ProviderAnalyticsModel extends FlutterFlowModel<ProviderAnalyticsWidget> {
  Map<String, dynamic> analytics = {};
  Map<String, dynamic>? revenueBreakdown;
  bool isLoading = true;
  String? fetchError;
  String selectedPeriod = 'month';
  int? expandedServiceId;
  final Map<int, Map<String, dynamic>> serviceMetricsCache = {};
  int? loadingServiceId;

  @override
  void initState(BuildContext context) {}

  Future<void> loadAnalytics() async {
    isLoading = true;
    fetchError = null;
    try {
      final svc = ProviderAnalyticsService.instance;
      analytics = await svc.getAnalytics(period: selectedPeriod);
      revenueBreakdown = await svc.getRevenueBreakdown();
    } catch (e) {
      fetchError = 'Failed to load analytics.';
    } finally {
      isLoading = false;
    }
  }

  Future<void> changePeriod(String period) async {
    selectedPeriod = period;
    await loadAnalytics();
  }

  Future<void> toggleServiceMetrics(int serviceId) async {
    if (expandedServiceId == serviceId) {
      expandedServiceId = null;
      return;
    }
    expandedServiceId = serviceId;
    if (serviceMetricsCache.containsKey(serviceId)) return;
    loadingServiceId = serviceId;
    try {
      final metrics = await ProviderAnalyticsService.instance
          .getServiceMetrics(serviceId);
      serviceMetricsCache[serviceId] = metrics;
    } catch (_) {
      expandedServiceId = null;
    } finally {
      loadingServiceId = null;
    }
  }

  @override
  void dispose() {}
}
