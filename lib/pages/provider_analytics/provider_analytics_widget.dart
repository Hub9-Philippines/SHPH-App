import 'package:flutter/material.dart';

import '/components/error_state.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'provider_analytics_model.dart';

export 'provider_analytics_model.dart';

class ProviderAnalyticsWidget extends StatefulWidget {
  const ProviderAnalyticsWidget({super.key});

  static String routeName = 'ProviderAnalytics';
  static String routePath = '/provider-analytics';

  @override
  State<ProviderAnalyticsWidget> createState() =>
      _ProviderAnalyticsWidgetState();
}

class _ProviderAnalyticsWidgetState extends State<ProviderAnalyticsWidget> {
  late ProviderAnalyticsModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ProviderAnalyticsModel.new);
    _model.loadAnalytics().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: const Text('Analytics'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.fetchError != null
              ? Center(
                  child: ErrorState(
                  message: _model.fetchError!,
                  onRetry: () =>
                      _model.loadAnalytics().then((_) => safeSetState(() {})),
                ))
              : RefreshIndicator(
                  onRefresh: () =>
                      _model.loadAnalytics().then((_) => safeSetState(() {})),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPeriodSelector(theme),
                      const SizedBox(height: 16),
                      _buildMetricsGrid(theme),
                      const SizedBox(height: 16),
                      _buildPerformanceSection(theme),
                      const SizedBox(height: 16),
                      _buildTopServices(theme),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPeriodSelector(AppThemeData theme) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'week', label: Text('7D')),
        ButtonSegment(value: 'month', label: Text('30D')),
        ButtonSegment(value: 'quarter', label: Text('90D')),
        ButtonSegment(value: 'year', label: Text('1Y')),
      ],
      selected: {_model.selectedPeriod},
      onSelectionChanged: (v) => _model
          .changePeriod(v.first)
          .then((_) => safeSetState(() {})),
    );
  }

  Widget _buildMetricsGrid(AppThemeData theme) {
    final a = _model.analytics;
    final items = [
      ('Total Earnings', '\$${_fmt(a['totalEarnings'])}', Icons.trending_up,
          theme.primary),
      ('Completed Jobs', '${a['completedBookings'] ?? 0}', Icons.task_alt,
          theme.success),
      ('Avg Rating', '${_fmt1(a['averageRating'])}', Icons.star,
          theme.warning),
      ('Avg Response', _fmtTime(a['avgResponseTime']), Icons.timer,
          theme.info),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.$3, color: item.$4, size: 20),
              const Spacer(),
              Text(item.$2,
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: item.$4,
                  )),
              Text(item.$1,
                  style:
                      theme.bodySmall?.copyWith(color: theme.secondaryText)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceSection(AppThemeData theme) {
    final a = _model.analytics;
    final metrics = [
      ('Acceptance Rate', a['acceptanceRate'] ?? 0, theme.primary),
      ('On-Time Completion', a['onTimeRate'] ?? 0, theme.success),
      ('Satisfaction', a['satisfactionRate'] ?? 0, theme.warning),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Performance', style: theme.titleSmall),
        const SizedBox(height: 12),
        ...metrics.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${m.$1}: ${m.$2}%',
                      style: theme.bodySmall
                          ?.copyWith(color: theme.secondaryText)),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (m.$2 as num).toDouble() / 100,
                      backgroundColor: theme.border,
                      valueColor: AlwaysStoppedAnimation(m.$3),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildTopServices(AppThemeData theme) {
    final topServices =
        (_model.analytics['topServices'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (topServices.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Services', style: theme.titleSmall),
        const SizedBox(height: 8),
        ...topServices.map((s) {
          final id = s['id'] as int? ?? 0;
          final expanded = _model.expandedServiceId == id;
          final metrics = _model.serviceMetricsCache[id];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: theme.secondaryBackground,
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                  title: Text(s['name']?.toString() ?? '',
                      style: theme.bodyMedium),
                  subtitle: Text('${s['bookings']} bookings',
                      style: theme.bodySmall),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\$${_fmt(s['revenue'])}',
                          style: theme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Icon(
                        expanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: theme.secondaryText,
                      ),
                    ],
                  ),
                  onTap: () => _model
                      .toggleServiceMetrics(id)
                      .then((_) => safeSetState(() {})),
                ),
                if (expanded && metrics != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _statChip('Total', '${metrics['total_bookings'] ?? '-'}'),
                        _statChip('Completed', '${metrics['completed_bookings'] ?? '-'}'),
                        _statChip('Cancelled', '${metrics['cancelled_bookings'] ?? '-'}'),
                        _statChip('Avg Value',
                            '\$${_fmt(metrics['avg_booking_value'])}'),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _statChip(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        Text(label,
            style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  String _fmt(dynamic val) {
    if (val == null) return '0';
    final n = val is num ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return n.toStringAsFixed(0);
  }

  String _fmt1(dynamic val) {
    if (val == null) return '0.0';
    final n = val is num ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return n.toStringAsFixed(1);
  }

  String _fmtTime(dynamic val) {
    if (val == null) return '0m';
    final minutes = val is num ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    if (minutes < 60) return '${minutes.toInt()}m';
    return '${(minutes / 60).toInt()}h ${(minutes % 60).toInt()}m';
  }
}
