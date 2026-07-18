import 'package:flutter/material.dart';

import '/api/models/analytics.dart';
import '/api/resources/analytics_api.dart';
import '/theme/app_theme.dart';
import '/utils/formatters.dart';

class ProviderAnalyticsPage extends StatefulWidget {
  const ProviderAnalyticsPage({super.key});

  static String routeName = 'ProviderAnalytics';
  static String routePath = '/provider-analytics';

  @override
  State<ProviderAnalyticsPage> createState() => _ProviderAnalyticsPageState();
}

class _ProviderAnalyticsPageState extends State<ProviderAnalyticsPage> {
  ProviderAnalytics? _analytics;
  bool _isLoading = true;
  String _selectedPeriod = '30d';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final data = await ShphAnalyticsApi.instance
          .getProviderAnalytics(period: _selectedPeriod);
      if (mounted) {
        setState(() {
          _analytics = ProviderAnalytics.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Analytics',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today_outlined),
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7d', child: Text('Last 7 days')),
              const PopupMenuItem(value: '30d', child: Text('Last 30 days')),
              const PopupMenuItem(value: '90d', child: Text('Last 90 days')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: _analytics == null
                  ? _buildEmptyState(theme)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      children: [
                        _buildStatGrid(context, theme),
                        const SizedBox(height: 16),
                        _buildPerformanceMetrics(context, theme),
                        const SizedBox(height: 16),
                        _buildTopServices(context, theme),
                        const SizedBox(height: 16),
                        _buildRecentFeedback(context, theme),
                      ],
                    ),
            ),
    );
  }

  Widget _buildEmptyState(AppThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined,
                size: 64, color: theme.secondaryText),
            const SizedBox(height: 16),
            Text('No analytics data yet',
                style: theme.bodyMedium.override(color: theme.secondaryText)),
          ],
        ),
      );

  Widget _buildStatGrid(BuildContext context, AppThemeData theme) =>
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _buildStatCard(
            theme,
            icon: Icons.payments_outlined,
            label: 'Total Earnings',
            value: Formatters.currency(_analytics!.totalEarnings),
            color: theme.success,
          ),
          _buildStatCard(
            theme,
            icon: Icons.check_circle_outline,
            label: 'Completed Jobs',
            value: '${_analytics!.completedJobs}',
            color: theme.primary,
          ),
          _buildStatCard(
            theme,
            icon: Icons.star_outline,
            label: 'Avg Rating',
            value: _analytics!.averageRating.toStringAsFixed(1),
            color: theme.warning,
          ),
          _buildStatCard(
            theme,
            icon: Icons.schedule_outlined,
            label: 'Response Time',
            value: _analytics!.responseTime,
            color: theme.tertiary,
          ),
        ],
      );

  Widget _buildStatCard(
    AppThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: color, size: 24)]),
            const Spacer(),
            Text(value,
                style: theme.titleLarge.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label,
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
        ),
      );

  Widget _buildPerformanceMetrics(BuildContext context, AppThemeData theme) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Metrics',
                style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _buildMetricBar(theme, 'Acceptance Rate',
                _analytics!.acceptanceRate, theme.success),
            const SizedBox(height: 12),
            _buildMetricBar(theme, 'On-Time Completion',
                _analytics!.onTimeCompletion, theme.primary),
            const SizedBox(height: 12),
            _buildMetricBar(theme, 'Customer Satisfaction',
                _analytics!.customerSatisfaction, theme.secondary),
          ],
        ),
      );

  Widget _buildMetricBar(
    AppThemeData theme,
    String label,
    double percent,
    Color color,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.bodyMedium),
              Text('${(percent * 100).toStringAsFixed(0)}%',
                  style:
                      theme.bodyMedium.override(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: theme.secondaryBackground,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      );

  Widget _buildTopServices(BuildContext context, AppThemeData theme) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Services',
                style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (_analytics!.topServices.isEmpty)
              Text('No service data yet',
                  style: theme.bodySmall.override(color: theme.secondaryText))
            else
              ..._analytics!.topServices.map((service) => _buildServiceItem(
                    theme,
                    service['name'] as String? ?? 'Unknown',
                    service['count'] as int? ?? 0,
                    Formatters.currency(
                      double.tryParse(service['revenue']?.toString() ?? '0') ??
                          0,
                    ),
                  )),
          ],
        ),
      );

  Widget _buildServiceItem(
    AppThemeData theme,
    String name,
    int count,
    String revenue,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.bodyMedium),
                  Text('$count jobs',
                      style:
                          theme.bodySmall.override(color: theme.secondaryText)),
                ],
              ),
            ),
            Text(revenue,
                style: theme.bodyMedium.override(fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _buildRecentFeedback(BuildContext context, AppThemeData theme) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Feedback',
                style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (_analytics!.recentFeedback.isEmpty)
              Text('No feedback yet',
                  style: theme.bodySmall.override(color: theme.secondaryText))
            else
              ..._analytics!.recentFeedback
                  .map((feedback) => _buildFeedbackItem(
                        theme,
                        feedback['client_name'] as String? ?? 'Client',
                        feedback['rating'] as int? ?? 0,
                        feedback['comment'] as String? ?? '',
                      )),
          ],
        ),
      );

  Widget _buildFeedbackItem(
    AppThemeData theme,
    String name,
    int rating,
    String comment,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name,
                    style:
                        theme.bodyMedium.override(fontWeight: FontWeight.w700)),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: theme.warning,
                    ),
                  ),
                ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(comment,
                  style: theme.bodySmall.override(color: theme.secondaryText)),
            ],
          ],
        ),
      );
}
