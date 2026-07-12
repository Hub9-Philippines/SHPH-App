import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/services/logging_service.dart';
import '/services/provider_analytics_service.dart';
import '/theme/app_theme.dart';

class ProAnalyticsWidget extends StatefulWidget {
  const ProAnalyticsWidget({super.key});

  static String routeName = 'ProAnalytics';
  static String routePath = '/pro-analytics';

  @override
  State<ProAnalyticsWidget> createState() => _ProAnalyticsWidgetState();
}

class _ProAnalyticsWidgetState extends State<ProAnalyticsWidget> {
  Map<String, dynamic> _data = {};
  bool _isLoading = true;
  final _service = ProviderAnalyticsService.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      _data = await _service.getAnalytics();
    } catch (e) {
      LoggingService.error('Analytics load error: $e',
          tag: 'ProAnalytics');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  double get totalEarnings =>
      (_data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
  int get totalJobs => _data['totalJobs'] as int? ?? 0;
  double get avgRating => (_data['avgRating'] as num?)?.toDouble() ?? 0.0;
  int get totalReviews => _data['totalReviews'] as int? ?? 0;
  double get completionRate =>
      (_data['completionRate'] as num?)?.toDouble() ?? 0.0;
  Map<String, int> get bookingInsights =>
      (_data['bookingInsights'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          <String, int>{};
  Map<String, double> get performanceMetrics =>
      (_data['performanceMetrics'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          <String, double>{};
  List<Map<String, dynamic>> get monthlyRevenue =>
      (_data['monthlyRevenue'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];

  String _currency(double v) => 'PHP ${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics', style: theme.titleMedium),
            Text(
              'Performance insights & growth',
              style: theme.bodySmall
                  .copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _buildStatsRow(context),
                  const SizedBox(height: 16),
                  _buildRevenueChart(context),
                  const SizedBox(height: 16),
                  _buildBookingInsights(context),
                  const SizedBox(height: 16),
                  _buildPerformanceMetrics(context),
                  const SizedBox(height: 16),
                  _buildGrowthTips(context),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Earnings',
            value: _currency(totalEarnings),
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Jobs Done',
            value: totalJobs.toString(),
            icon: Icons.work_outline_rounded,
            color: const Color(0xFF059669),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    final theme = AppTheme.of(context);
    final spots = monthlyRevenue.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: (e.value['revenue'] as num).toDouble(),
            color: const Color(0xFF2563EB),
            width: 16,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();

    final maxY = monthlyRevenue.fold<double>(
      0,
      (m, v) => (v['revenue'] as num).toDouble() > m
          ? (v['revenue'] as num).toDouble()
          : m,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '12-Month Revenue',
                style: theme.titleSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Icon(Icons.bar_chart_rounded,
                  size: 20, color: const Color(0xFF64748B)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY > 0 ? maxY * 1.15 : 1000,
                barGroups: spots,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 250,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFE2E8F0),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= monthlyRevenue.length) {
                          return const SizedBox.shrink();
                        }
                        final label =
                            monthlyRevenue[value.toInt()]['month'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}k',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF64748B),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final rev =
                          monthlyRevenue[group.x]['revenue'] as double;
                      return BarTooltipItem(
                        'PHP ${rev.toStringAsFixed(0)}',
                        GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInsights(BuildContext context) {
    final theme = AppTheme.of(context);
    final completed = bookingInsights['completed'] ?? 0;
    final cancelled = bookingInsights['cancelled'] ?? 0;
    final pending = bookingInsights['pending'] ?? 0;
    final total = completed + cancelled + pending;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Insights',
            style: theme.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _InsightPill(
                label: 'Completed',
                count: completed,
                color: const Color(0xFF059669),
              ),
              const SizedBox(width: 10),
              _InsightPill(
                label: 'Cancelled',
                count: cancelled,
                color: const Color(0xFFDC2626),
              ),
              const SizedBox(width: 10),
              _InsightPill(
                label: 'Pending',
                count: pending,
                color: const Color(0xFFD97706),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (total > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completed / total,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                minHeight: 8,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '${(completionRate * 100).toStringAsFixed(0)}% completion rate',
            style: theme.bodySmall.copyWith(color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    final theme = AppTheme.of(context);
    final repeatClients = performanceMetrics['repeatClients'] ?? 0.0;
    final avgJobValue = performanceMetrics['avgJobValue'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: theme.titleSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.people_outline_rounded,
                  label: 'Repeat Clients',
                  value: '${(repeatClients * 100).toStringAsFixed(0)}%',
                  color: const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  icon: Icons.receipt_long_rounded,
                  label: 'Avg Job Value',
                  value: _currency(avgJobValue),
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.star_rounded,
                  label: 'Rating',
                  value: '$avgRating ($totalReviews reviews)',
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthTips(BuildContext context) {
    final theme = AppTheme.of(context);
    final tips = <String>[];
    if (completionRate < 0.7) {
      tips.add('Improve response time to boost your completion rate.');
    }
    if (avgRating < 4.0 && totalReviews > 0) {
      tips.add('Ask satisfied clients to leave a review to raise your rating.');
    }
    if (totalJobs < 5) {
      tips.add('Keep your availability open to attract more booking requests.');
    }
    if ((performanceMetrics['repeatClients'] ?? 0.0) < 0.3 && totalJobs > 3) {
      tips.add('Follow up with past clients to encourage repeat bookings.');
    }
    if (tips.isEmpty) {
      tips.add('Great work! Your metrics look healthy. Keep it up!');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 20, color: const Color(0xFFD97706)),
              const SizedBox(width: 8),
              Text(
                'Growth Recommendations',
                style:
                    theme.titleSmall.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(color: Color(0xFF64748B))),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.bodySmall
                          .copyWith(color: const Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightPill extends StatelessWidget {
  const _InsightPill({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
