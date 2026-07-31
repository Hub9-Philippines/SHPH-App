import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/screen_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/logging_service.dart';
import '/services/pro_bookings_service.dart';
import '/theme/app_theme.dart';

class ServiceHistoryWidget extends StatefulWidget {
  const ServiceHistoryWidget({super.key});

  static const String routeName = 'ServiceHistory';
  static const String routePath = '/pro/service-history';

  @override
  State<ServiceHistoryWidget> createState() => _ServiceHistoryWidgetState();
}

class _ServiceHistoryWidgetState extends State<ServiceHistoryWidget> {
  final ProBookingsService _bookingsService = ProBookingsService.instance;

  List<Map<String, dynamic>> _completedJobs = const [];
  bool _isLoading = true;
  String? _errorMessage;
  _HistoryStats _stats = const _HistoryStats();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobs = await _bookingsService.getScheduledJobs();
      final completed = jobs.where(_isCompletedJob).toList()
        ..sort(_sortCompletedJobs);

      safeSetState(() {
        _completedJobs = completed;
        _stats = _buildStats(completed);
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading service history',
        tag: 'ServiceHistory',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      safeSetState(() {
        _isLoading = false;
        _errorMessage = 'We could not load your completed jobs right now.';
      });
    }
  }

  bool _isCompletedJob(Map<String, dynamic> job) =>
      (job['status'] as String?)?.toLowerCase() == 'completed';

  int _sortCompletedJobs(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final aDate = _parseDate(
      a['completed_at']?.toString() ?? a['updated_at']?.toString(),
    );
    final bDate = _parseDate(
      b['completed_at']?.toString() ?? b['updated_at']?.toString(),
    );

    if (aDate == null && bDate == null) {
      return 0;
    }
    if (aDate == null) {
      return 1;
    }
    if (bDate == null) {
      return -1;
    }
    return bDate.compareTo(aDate);
  }

  _HistoryStats _buildStats(List<Map<String, dynamic>> jobs) {
    final now = DateTime.now();
    var totalEarnings = 0.0;
    var thisMonthEarnings = 0.0;
    var last30DaysEarnings = 0.0;
    var thisMonthJobs = 0;
    var tmJobs = 0;
    var ratedJobs = 0;

    for (final job in jobs) {
      final price = _readPrice(job);
      totalEarnings += price;

      if (_bookingsService.isTimeMaterialBooking(job)) {
        tmJobs++;
      }

      final rating = _readRating(job);
      if (rating != null && rating > 0) {
        ratedJobs++;
      }

      final completedAt = _parseDate(
        job['completed_at']?.toString() ?? job['updated_at']?.toString(),
      );
      if (completedAt == null) {
        continue;
      }

      if (completedAt.year == now.year && completedAt.month == now.month) {
        thisMonthJobs++;
        thisMonthEarnings += price;
      }

      if (!completedAt.isBefore(now.subtract(const Duration(days: 30)))) {
        last30DaysEarnings += price;
      }
    }

    return _HistoryStats(
      totalJobs: jobs.length,
      totalEarnings: totalEarnings,
      thisMonthJobs: thisMonthJobs,
      thisMonthEarnings: thisMonthEarnings,
      last30DaysEarnings: last30DaysEarnings,
      tmJobs: tmJobs,
      ratedJobs: ratedJobs,
    );
  }

  double _readPrice(Map<String, dynamic> job) =>
      (job['total_price'] as num?)?.toDouble() ?? 0.0;

  int? _readRating(Map<String, dynamic> job) {
    final value = job['rating'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return null;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  String _currency(double amount) => 'PHP ${amount.toStringAsFixed(0)}';

  String _serviceName(Map<String, dynamic> job) {
    final listing = job['service_listings'] as Map<String, dynamic>?;
    return (listing?['title'] ??
            listing?['name'] ??
            _bookingsService.tmSubCategoryTitle(job) ??
            'Unknown Service')
        .toString();
  }

  String _serviceCategory(Map<String, dynamic> job) {
    final listing = job['service_listings'] as Map<String, dynamic>?;
    final category = listing?['category_name'] ??
        listing?['category'] ??
        listing?['service_category'];
    if (category != null && category.toString().trim().isNotEmpty) {
      return category.toString();
    }
    if (_bookingsService.isTimeMaterialBooking(job)) {
      return 'Time-material service';
    }
    return 'Completed service';
  }

  String _clientName(Map<String, dynamic> job) {
    final profile = job['profiles'] as Map<String, dynamic>?;
    return (profile?['display_name'] ??
            profile?['full_name'] ??
            profile?['first_name'] ??
            'Client')
        .toString();
  }

  String? _clientPhoto(Map<String, dynamic> job) {
    final profile = job['profiles'] as Map<String, dynamic>?;
    final raw = profile?['photo_url'] ?? profile?['avatar_url'];
    final value = raw?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  String _completedDateLabel(Map<String, dynamic> job) {
    final completedAt = _parseDate(
      job['completed_at']?.toString() ?? job['updated_at']?.toString(),
    );
    if (completedAt == null) {
      return 'Completion date unavailable';
    }
    return 'Completed ${DateFormat('MMM d, yyyy').format(completedAt)}';
  }

  String _bookingReference(Map<String, dynamic> job) {
    final rawId = job['id']?.toString() ?? '';
    if (rawId.isEmpty) {
      return 'Unknown';
    }
    return rawId.length <= 8
        ? rawId.toUpperCase()
        : rawId.substring(0, 8).toUpperCase();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: AppTheme.of(context).primaryBackground,
          body: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: 'Service History',
                  subtitle: 'Review completed jobs, earnings, and client outcomes.',
                  action: IconButton(
                    onPressed: _loadHistory,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.of(context).primary,
                          ),
                        )
                      : _errorMessage != null
                          ? _buildMessageState(
                              context,
                              icon: Icons.history_toggle_off_rounded,
                              title: 'Could not load history',
                              subtitle: _errorMessage!,
                              actionLabel: 'Try again',
                              onPressed: _loadHistory,
                              accent: AppTheme.of(context).error,
                            )
                          : RefreshIndicator(
                              color: AppTheme.of(context).primary,
                              onRefresh: _loadHistory,
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                                children: [
                                  const SizedBox(height: 18),
                                  _buildHeroCard(context),
                                  const SizedBox(height: 18),
                                  _buildStatsGrid(context),
                                  const SizedBox(height: 20),
                                  _buildSectionHeader(context),
                                  const SizedBox(height: 12),
                                  if (_completedJobs.isEmpty)
                                    _buildMessageState(
                                      context,
                                      icon: Icons.assignment_turned_in_outlined,
                                      title: 'No completed jobs yet',
                                      subtitle:
                                          'Finished visits will appear here once you start closing out bookings.',
                                      actionLabel: 'Refresh',
                                      onPressed: _loadHistory,
                                      accent: AppTheme.of(context).primary,
                                      compact: true,
                                    )
                                  else
                                    ..._completedJobs.map(
                                      (job) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _buildHistoryCard(context, job),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeroCard(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0E6B58),
              Color(0xFF169873),
              Color(0xFF69C8A1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x220E6B58),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currency(_stats.totalEarnings),
              style: AppTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: AppTheme.of(context).secondaryBackground,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_stats.totalJobs} completed jobs recorded so far.',
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: AppTheme.of(context).secondaryBackground.withValues(alpha: 0.84),
                  ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _HeroMetric(
                    label: 'This month',
                    value: '${_stats.thisMonthJobs}',
                    caption: _currency(_stats.thisMonthEarnings),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HeroMetric(
                    label: 'Last 30 days',
                    value: _currency(_stats.last30DaysEarnings),
                    caption: '${_stats.ratedJobs} rated jobs',
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildStatsGrid(BuildContext context) => Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'TM Jobs',
              value: '${_stats.tmJobs}',
              subtitle: 'Time-material requests completed',
              icon: Icons.bolt_rounded,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Rated Jobs',
              value: '${_stats.ratedJobs}',
              subtitle: 'Completed bookings with a rating',
              icon: Icons.star_rounded,
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      );

  Widget _buildSectionHeader(BuildContext context) => Row(
        children: [
          Text(
            'Completed Jobs',
            style: AppTheme.of(context).titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: AppTheme.of(context).primaryText,
                ),
          ),
          const Spacer(),
          Text(
            '${_completedJobs.length} total',
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: AppTheme.of(context).secondaryText,
                ),
          ),
        ],
      );

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> job) {
    final photoUrl = _clientPhoto(job);
    final serviceName = _serviceName(job);
    final serviceCategory = _serviceCategory(job);
    final clientName = _clientName(job);
    final price = _readPrice(job);
    final rating = _readRating(job);
    final isTm = _bookingsService.isTimeMaterialBooking(job);
    final bookingId = job['id']?.toString();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppThemeData.shadowCard,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: bookingId == null
              ? null
              : () => context.pushNamed(
                    BookingDetailsWidget.routeName,
                    extra: <String, dynamic>{'bookingId': bookingId},
                  ),
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        image: photoUrl == null
                            ? null
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(photoUrl),
                              ),
                      ),
                      child: photoUrl == null
                          ? Icon(
                              Icons.person_rounded,
                              color: AppTheme.of(context).primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              const _StatusChip(
                                label: 'Completed',
                                foreground: Color(0xFF0E9F6E),
                                background: Color(0xFFE9F9F1),
                              ),
                              if (isTm)
                                _StatusChip(
                                  label: _bookingsService.tmStageLabel(job),
                                  foreground: const Color(0xFF2563EB),
                                  background: const Color(0xFFEAF2FF),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            serviceName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: AppTheme.of(context).primaryText,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$clientName • $serviceCategory',
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.plusJakartaSans(),
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currency(price),
                          style: AppTheme.of(context).titleSmall.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: AppTheme.of(context).success,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '#${_bookingReference(job)}',
                          style: AppTheme.of(context).labelSmall.override(
                                font: GoogleFonts.plusJakartaSans(),
                                color: AppTheme.of(context).textTertiary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      _MetaRow(
                        label: 'Status',
                        value: _completedDateLabel(job),
                      ),
                      const SizedBox(height: 10),
                      _MetaRow(
                        label: 'Rating',
                        value: rating == null || rating <= 0
                            ? 'No rating yet'
                            : '$rating / 5',
                        trailing: rating == null || rating <= 0
                            ? null
                            : const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFF59E0B),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Open this completed booking to review full details.',
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.plusJakartaSans(),
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppTheme.of(context).primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onPressed,
    required Color accent,
    bool compact = false,
  }) =>
      Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: EdgeInsets.all(compact ? 24 : 28),
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppThemeData.shadowCard,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 30, color: accent),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.of(context).titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      color: AppTheme.of(context).primaryText,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: compact ? 140 : double.infinity,
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppTheme.of(context).secondaryBackground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: AppTheme.of(context).labelLarge.override(
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          color: AppTheme.of(context).secondaryBackground,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _HistoryStats {
  const _HistoryStats({
    this.totalJobs = 0,
    this.totalEarnings = 0,
    this.thisMonthJobs = 0,
    this.thisMonthEarnings = 0,
    this.last30DaysEarnings = 0,
    this.tmJobs = 0,
    this.ratedJobs = 0,
  });

  final int totalJobs;
  final double totalEarnings;
  final int thisMonthJobs;
  final double thisMonthEarnings;
  final double last30DaysEarnings;
  final int tmJobs;
  final int ratedJobs;
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    color: AppTheme.of(context).secondaryBackground.withValues(alpha: 0.8),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: AppTheme.of(context).secondaryBackground,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: AppTheme.of(context).labelSmall.override(
                    color: AppTheme.of(context).secondaryBackground.withValues(alpha: 0.74),
                  ),
            ),
          ],
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppThemeData.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: AppTheme.of(context).primaryText,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.of(context).labelSmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: AppTheme.of(context).textTertiary,
                  ),
            ),
          ],
        ),
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTheme.of(context).labelSmall.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                color: foreground,
              ),
        ),
      );
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                          color: AppTheme.of(context).primaryText,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
