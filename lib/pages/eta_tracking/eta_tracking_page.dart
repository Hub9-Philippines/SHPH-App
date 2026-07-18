import 'package:flutter/material.dart';

import '/api/resources/services_api.dart';
import '/theme/app_theme.dart';

/// Public ETA tracking page.
///
/// Mirrors `shph-app/src/views/services/EtaTrackingPage.vue`. Backed by
/// `ShphServicesApi.getPublicEta()` → GET `/api/services/eta/<token>/`.
/// This is a public endpoint — no auth required.
class EtaTrackingPage extends StatefulWidget {
  const EtaTrackingPage({super.key, required this.token});

  final String token;

  static String routeName = 'EtaTracking';
  static String routePath = '/eta/:token';

  @override
  State<EtaTrackingPage> createState() => _EtaTrackingPageState();
}

class _EtaTrackingPageState extends State<EtaTrackingPage> {
  Map<String, dynamic> _eta = const {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEta();
  }

  Future<void> _loadEta() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final eta = await ShphServicesApi.instance.getPublicEta(widget.token);
      if (mounted) {
        setState(() {
          _eta = eta;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load ETA: $e';
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
        title: Text('Provider ETA',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadEta)
              : RefreshIndicator(
                  onRefresh: _loadEta,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      _StatusCard(eta: _eta),
                      const SizedBox(height: 16),
                      _InfoCard(eta: _eta),
                    ],
                  ),
                ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.eta});
  final Map<String, dynamic> eta;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final status = eta['status']?.toString() ?? 'unknown';
    final (label, color, icon) = _style(status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(label,
                  style: theme.titleMedium.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          if (eta['eta_minutes'] != null)
            Text(
              'ETA: ${eta['eta_minutes']} min',
              style: theme.bodyMedium.override(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  (String, Color, IconData) _style(String s) {
    switch (s) {
      case 'en_route':
        return ('En route', Colors.blue.shade700, Icons.directions_car);
      case 'arrived':
        return ('Arrived', Colors.green.shade700, Icons.check_circle);
      case 'started':
        return ('Work started', Colors.purple.shade700, Icons.build);
      case 'completed':
        return ('Completed', Colors.grey.shade700, Icons.task_alt);
      case 'cancelled':
        return ('Cancelled', Colors.red.shade700, Icons.cancel);
      default:
        return (s, Colors.blueGrey, Icons.info_outline);
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.eta});
  final Map<String, dynamic> eta;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final rows = <_Row>[];
    if (eta['provider_name'] != null) {
      rows.add(_Row('Provider', eta['provider_name'].toString()));
    }
    if (eta['listing_title'] != null) {
      rows.add(_Row('Service', eta['listing_title'].toString()));
    }
    if (eta['distance_km'] != null) {
      rows.add(_Row(
          'Distance', '${_double(eta, 'distance_km').toStringAsFixed(1)} km'));
    }
    if (eta['last_updated'] != null) {
      rows.add(_Row('Last updated', eta['last_updated'].toString()));
    }
    if (eta['expires_at'] != null) {
      rows.add(_Row('Link expires', eta['expires_at'].toString()));
    }
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details',
              style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(r.label,
                        style: theme.bodySmall
                            .override(color: theme.secondaryText)),
                    const Spacer(),
                    Text(r.value,
                        style: theme.bodyMedium
                            .override(fontWeight: FontWeight.w700)),
                  ],
                ),
              )),
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

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final String value;
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
