import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/earnings_service.dart';
import '/theme/app_theme.dart';
import 'earnings_chart_model.dart';

export 'earnings_chart_model.dart';

class EarningsChartWidget extends StatefulWidget {
  const EarningsChartWidget({super.key});

  static String routeName = 'EarningsChart';
  static String routePath = '/earnings-chart';

  @override
  State<EarningsChartWidget> createState() => _EarningsChartWidgetState();
}

class _EarningsChartWidgetState extends State<EarningsChartWidget> {
  late EarningsChartModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, EarningsChartModel.new);
    _model.loadEarnings().then((_) => safeSetState(() {}));
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
      backgroundColor: theme.secondaryBackground,
      appBar: AppBar(
        backgroundColor: theme.secondaryBackground,
        title: Text('Earnings', style: theme.titleLarge),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(context, theme),
                  const SizedBox(height: 20),
                  _buildPeriodStats(context, theme),
                  const SizedBox(height: 24),
                  _buildChartSection(context, theme),
                  const SizedBox(height: 24),
                  _buildTransactionsSection(context, theme),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AppThemeData theme) {
    final total = _model.earningsData['totalEarnings'] as double? ?? 0.0;
    final jobs = _model.earningsData['totalJobs'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₱${total.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$jobs completed jobs',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodStats(BuildContext context, AppThemeData theme) {
    final periods = [
      ('This Week', 'thisWeek'),
      ('Last Week', 'lastWeek'),
      ('This Month', 'thisMonth'),
      ('Last Month', 'lastMonth'),
    ];

    return Row(
      children: periods
          .map((p) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        p.$1,
                        style: GoogleFonts.poppins(
                          color: theme.secondaryText,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₱${(_model.earningsData[p.$2] as double? ?? 0.0).toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          color: theme.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildChartSection(BuildContext context, AppThemeData theme) {
    final weeklyData =
        _model.earningsData['weeklyData'] as List<dynamic>? ?? [];
    if (weeklyData.isEmpty) return const SizedBox.shrink();

    final maxEarnings = (weeklyData
            .map((w) => (w['earnings'] as double? ?? 0.0))
            .toList()
              ..sort())
            .lastOrNull ??
        1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Performance',
          style: theme.titleMedium.override(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyData.asMap().entries.map((entry) {
              final earnings = (entry.value['earnings'] as double? ?? 0.0);
              final height = maxEarnings > 0
                  ? (earnings / maxEarnings) * 120
                  : 0.0;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '₱${earnings.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          color: theme.secondaryText,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: height.clamp(4, 120),
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value['week'] as String? ?? '',
                        style: GoogleFonts.poppins(
                          color: theme.secondaryText,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection(
      BuildContext context, AppThemeData theme) {
    final transactions =
        _model.earningsData['recentTransactions'] as List<dynamic>? ?? [];
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: theme.titleMedium.override(
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        ...transactions.take(5).map((tx) {
          final t = tx as Map<String, dynamic>;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t['serviceName'] as String? ?? '',
                        style: GoogleFonts.poppins(
                          color: theme.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        t['date'] as String? ?? '',
                        style: GoogleFonts.poppins(
                          color: theme.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₱${(t['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  style: GoogleFonts.poppins(
                    color: theme.success,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
