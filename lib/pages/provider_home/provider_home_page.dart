import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/models/booking.dart';
import '/api/resources/bookings_api.dart';
import '/api/resources/earnings_api.dart';
import '/index.dart';
import '/theme/app_theme.dart';

/// Provider home — current task, earnings summary, upcoming jobs.
///
/// Mirrors `shph-app/src/views/provider/ProviderHomePage.vue`. Aggregates
/// bookings + earnings summary. No dedicated backend endpoint.
class ProviderHomePage extends StatefulWidget {
  const ProviderHomePage({super.key});

  static String routeName = 'ProviderHome';
  static String routePath = '/provider-home';

  @override
  State<ProviderHomePage> createState() => _ProviderHomePageState();
}

class _ProviderHomePageState extends State<ProviderHomePage> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _earnings = const {};
  List<ShphBooking> _bookings = const [];
  ShphBooking? _currentTask;

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
      final earnings = await ShphEarningsApi.instance.getSummary();
      final bookingsResp = await ShphBookingsApi.instance.listUserBookings();
      final all = bookingsResp.results;
      // "Current" = first in-progress/accepted booking; upcoming = pending.
      final current = all.firstWhere(
        (b) => b.status == 'accepted' || b.status == 'in_progress',
        orElse: () => const ShphBooking(id: '', listing: 0, status: ''),
      );
      final upcoming = all
          .where((b) => b.status == 'pending' || b.status == 'confirmed')
          .toList();
      if (mounted) {
        setState(() {
          _earnings = earnings;
          _bookings = upcoming;
          _currentTask = current.id.isEmpty ? null : current;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load: $e';
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
        title: Text('Provider Home',
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
                      _EarningsCard(earnings: _earnings),
                      const SizedBox(height: 16),
                      if (_currentTask != null) ...[
                        _CurrentTaskCard(booking: _currentTask!),
                        const SizedBox(height: 16),
                      ],
                      Text('Upcoming Jobs',
                          style: theme.titleMedium
                              .override(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (_bookings.isEmpty)
                        _EmptyCard(label: 'No upcoming jobs')
                      else
                        ..._bookings
                            .take(5)
                            .map((b) => _BookingRow(booking: b)),
                      const SizedBox(height: 16),
                      _QuickActionsRow(),
                    ],
                  ),
                ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.earnings});
  final Map<String, dynamic> earnings;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final available = _double(earnings, 'available_balance');
    final pending = _double(earnings, 'pending_balance');
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
          Text('Available Earnings',
              style: theme.bodyMedium.override(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            'PHP ${available.toStringAsFixed(2)}',
            style: theme.displaySmall.override(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text('PHP ${pending.toStringAsFixed(2)} pending',
              style: theme.bodySmall.override(color: Colors.white60)),
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

class _CurrentTaskCard extends StatelessWidget {
  const _CurrentTaskCard({required this.booking});
  final ShphBooking booking;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text('Current Task',
                  style:
                      theme.titleMedium.override(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Text(booking.listingTitle ?? 'Booking',
              style: theme.bodyMedium.override(fontWeight: FontWeight.w700)),
          if (booking.scheduledDate != null) ...[
            const SizedBox(height: 4),
            Text('${booking.scheduledDate} ${booking.scheduledTime ?? ''}',
                style: theme.bodySmall.override(color: theme.secondaryText)),
          ],
        ],
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking});
  final ShphBooking booking;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
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
                Text(booking.listingTitle ?? 'Booking',
                    style:
                        theme.bodyMedium.override(fontWeight: FontWeight.w700)),
                Text(booking.scheduledDate ?? '',
                    style:
                        theme.bodySmall.override(color: theme.secondaryText)),
              ],
            ),
          ),
          Text(booking.status,
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
          label: const Text('Dashboard'),
          avatar: const Icon(Icons.dashboard_outlined),
          onPressed: () => context.push(ProviderDashboardPage.routePath),
        ),
      ],
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
