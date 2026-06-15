import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/services/logging_service.dart';
import '/services/pro_bookings_service.dart';

class ServiceHistoryWidget extends StatefulWidget {
  const ServiceHistoryWidget({super.key});

  static const String routeName = 'ServiceHistory';
  static const String routePath = '/pro/service-history';

  @override
  State<ServiceHistoryWidget> createState() => _ServiceHistoryWidgetState();
}

class _ServiceHistoryWidgetState extends State<ServiceHistoryWidget> {
  final ProBookingsService _bookingsService = ProBookingsService.instance;
  List<Map<String, dynamic>> completedJobs = [];
  bool isLoading = true;
  Map<String, dynamic> stats = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    try {
      // Get completed jobs
      final jobs = await _bookingsService.getScheduledJobs();
      final completed = jobs.where((j) => j['status'] == 'completed').toList();

      // Calculate stats
      double totalEarnings = 0;
      int totalJobs = completed.length;
      int thisMonthJobs = 0;
      double thisMonthEarnings = 0;

      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);

      for (final job in completed) {
        final price = (job['total_price'] as num?)?.toDouble() ?? 0.0;
        totalEarnings += price;

        final completedAt = job['completed_at'] != null
            ? DateTime.parse(job['completed_at'])
            : null;

        if (completedAt != null &&
            completedAt.year == thisMonth.year &&
            completedAt.month == thisMonth.month) {
          thisMonthJobs++;
          thisMonthEarnings += price;
        }
      }

      setState(() {
        completedJobs = completed;
        stats = {
          'totalJobs': totalJobs,
          'totalEarnings': totalEarnings,
          'thisMonthJobs': thisMonthJobs,
          'thisMonthEarnings': thisMonthEarnings,
        };
        isLoading = false;
      });
    } catch (e) {
      LoggingService.error('Error loading service history: $e',
          tag: 'ServiceHistory');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Service History',
          style: AppTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
        ),
        backgroundColor: AppTheme.of(context).primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Stats Cards
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Jobs',
                              value: '${stats['totalJobs'] ?? 0}',
                              icon: Icons.work_outline,
                              color: AppTheme.of(context).primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Earnings',
                              value:
                                  '₱${(stats['totalEarnings'] ?? 0).toStringAsFixed(0)}',
                              icon: Icons.payments_outlined,
                              color: AppTheme.of(context).success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'This Month',
                              value: '${stats['thisMonthJobs'] ?? 0} jobs',
                              subtitle:
                                  '₱${(stats['thisMonthEarnings'] ?? 0).toStringAsFixed(0)}',
                              icon: Icons.calendar_today,
                              color: AppTheme.of(context).info,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Jobs List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Completed Jobs',
                            style: AppTheme.of(context).titleMedium.override(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '${completedJobs.length} jobs',
                            style: AppTheme.of(context).bodyMedium.override(
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (completedJobs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: AppTheme.of(context).secondaryText,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No completed jobs yet',
                              style: AppTheme.of(context).bodyLarge.override(
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: completedJobs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final job = completedJobs[index];
                          return _buildHistoryCard(job);
                        },
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.of(context).bodySmall.override(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.of(context).headlineSmall.override(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> job) {
    final serviceListing = job['service_listings'] as Map<String, dynamic>?;
    final profile = job['profiles'] as Map<String, dynamic>?;

    final serviceName = serviceListing?['name'] ?? 'Unknown Service';
    final clientName =
        profile?['display_name'] ?? profile?['first_name'] ?? 'Unknown Client';
    final clientPhoto = profile?['photo_url'];
    final price = (job['total_price'] as num?)?.toDouble() ?? 0.0;
    final completedAt = job['completed_at'] != null
        ? DateTime.parse(job['completed_at'])
        : null;
    final rating = job['rating'] as int?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryText.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary,
                  shape: BoxShape.circle,
                  image: clientPhoto != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(clientPhoto),
                        )
                      : null,
                ),
                child: clientPhoto == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: AppTheme.of(context).bodyLarge.override(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      clientName,
                      style: AppTheme.of(context).bodyMedium.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${price.toStringAsFixed(0)}',
                    style: AppTheme.of(context).bodyLarge.override(
                          color: AppTheme.of(context).success,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (rating != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        Text(
                          '$rating',
                          style: AppTheme.of(context).bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          if (completedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppTheme.of(context).success,
                ),
                const SizedBox(width: 4),
                Text(
                  'Completed on ${DateFormat('MMM d, yyyy').format(completedAt)}',
                  style: AppTheme.of(context).bodySmall.override(
                        color: AppTheme.of(context).success,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
