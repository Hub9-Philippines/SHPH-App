import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/resources/analytics_api.dart';
import '/api/resources/bookings_api.dart';
import '/api/resources/provider_api.dart';
import '/index.dart';
import '/theme/app_theme.dart';

/// Provider dashboard (SHPH).
///
/// Mirrors `shph-app/src/views/provider/ProviderDashboardPage.vue`. There is
/// no dedicated backend endpoint — this page aggregates three calls:
///   1. `ShphBookingsApi.listUserBookings()` — recent bookings
///   2. `ShphAnalyticsApi.getProviderAnalytics()` — stats + revenue
///   3. `ShphProviderApi.getIncentives()` — achievement badges
class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});

  static String routeName = 'ProviderDashboard';
  static String routePath = '/provider-dashboard';

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _analytics = const {};
  Map<String, dynamic> _incentives = const {};
  List<Map<String, dynamic>> _recentBookings = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Fire all three calls; let the slowest one set the ready flag.
      final analytics = await ShphAnalyticsApi.instance.getProviderAnalytics();
      final incentives = await ShphProviderApi.instance.getIncentives();
      final bookingsResp = await ShphBookingsApi.instance.listUserBookings();
      final bookingsList = <Map<String, dynamic>>[];
      if (bookingsResp.results.isNotEmpty) {
        // The booking model is typed; expose raw maps for the dashboard cards.
        bookingsList.addAll(bookingsResp.results
            .map((b) => <String, dynamic>{
                  'id': b.id,
                  'status': b.status,
                  'title': b.listingTitle ?? 'Booking',
                  'client_name': b.providerName ?? '',
                  'scheduled_date': b.scheduledDate,
                  'total_price': b.totalPrice,
                })
            .toList());
      }
      if (mounted) {
        setState(() {
          _analytics = analytics;
          _incentives = incentives;
          _recentBookings = bookingsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load dashboard: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('Provider Dashboard',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadData)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      _StatGrid(analytics: _analytics),
                      const SizedBox(height: 16),
                      _RevenueCard(analytics: _analytics),
                      const SizedBox(height: 16),
                      if (_incentives.isNotEmpty) ...[
                        _IncentivesCard(incentives: _incentives),
                        const SizedBox(height: 16),
                      ],
                      _QuickActionsRow(),
                      const SizedBox(height: 16),
                      Text('Recent Bookings',
                          style: theme.titleMedium
                              .override(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (_recentBookings.isEmpty)
                        _EmptyCard(label: 'No bookings yet')
                      else
                        ..._recentBookings
                            .take(5)
                            .map((b) => _BookingRow(booking: b)),
                    ],
                  ),
                ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.analytics});
  final Map<String, dynamic> analytics;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _Stat(
        label: 'Bookings',
        value: _int(analytics, 'total_bookings').toString(),
        icon: Icons.calendar_today_outlined,
        color: Colors.blue.shade700,
      ),
      _Stat(
        label: 'Completed',
        value: _int(analytics, 'completed_bookings').toString(),
        icon: Icons.check_circle_outline,
        color: Colors.green.shade700,
      ),
      _Stat(
        label: 'Pending',
        value: _int(analytics, 'pending_bookings').toString(),
        icon: Icons.hourglass_top_outlined,
        color: Colors.orange.shade700,
      ),
      _Stat(
        label: 'Rating',
        value: _double(analytics, 'avg_rating').toStringAsFixed(1),
        icon: Icons.star_outline,
        color: Colors.amber.shade700,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: stats.map((s) => _StatCard(stat: s)).toList(),
    );
  }

  int _int(Map<String, dynamic> m, String k) {
    final v = m[k];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  double _double(Map<String, dynamic> m, String k) {
    final v = m[k];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class _Stat {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: stat.color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(stat.value,
                  style: theme.titleMedium.override(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  )),
              Text(stat.label,
                  style: theme.bodySmall.override(color: theme.secondaryText)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.analytics});
  final Map<String, dynamic> analytics;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final revenue = _double(analytics, 'total_revenue');
    final period = analytics['period'] as String? ?? '30d';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue ($period)',
              style: theme.bodyMedium.override(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            'PHP ${revenue.toStringAsFixed(2)}',
            style: theme.displaySmall.override(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  double _double(Map<String, dynamic> m, String k) {
    final v = m[k];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class _IncentivesCard extends StatelessWidget {
  const _IncentivesCard({required this.incentives});
  final Map<String, dynamic> incentives;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final badges = _badges();
    if (badges.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achievements',
              style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges
                .map((b) => Chip(
                      avatar: const Icon(Icons.emoji_events, size: 18),
                      label: Text(b),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  List<String> _badges() {
    final raw = incentives['badges'];
    if (raw is List) {
      return raw
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ActionChip(
          label: const Text('My Services'),
          avatar: const Icon(Icons.list_alt),
          onPressed: () => context.push('/provider/my-services'),
        ),
        ActionChip(
          label: const Text('Post Service'),
          avatar: const Icon(Icons.add_circle_outline),
          onPressed: () => context.push('/provider/post-service'),
        ),
        ActionChip(
          label: const Text('Availability'),
          avatar: const Icon(Icons.event_available),
          onPressed: () => context.push('/provider/availability'),
        ),
        ActionChip(
          label: const Text('Analytics'),
          avatar: const Icon(Icons.insights),
          onPressed: () => context.push(ProviderAnalyticsPage.routePath),
        ),
        ActionChip(
          label: const Text('Earnings'),
          avatar: const Icon(Icons.account_balance_wallet_outlined),
          onPressed: () => context.push(EarningsPage.routePath),
        ),
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking});
  final Map<String, dynamic> booking;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final status = booking['status'] as String? ?? 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking['title']?.toString() ?? 'Booking',
                    style:
                        theme.bodyMedium.override(fontWeight: FontWeight.w700)),
                Text(booking['scheduled_date']?.toString() ?? '',
                    style:
                        theme.bodySmall.override(color: theme.secondaryText)),
              ],
            ),
          ),
          Text(status,
              style: theme.bodySmall.override(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(color: theme.secondaryText)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(color: theme.secondaryText)),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
