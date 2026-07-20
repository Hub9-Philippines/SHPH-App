import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/services/eta_tracking_service.dart';
import '/theme/app_theme.dart';

/// Client-side screen to track provider location in real-time.
///
/// Mirrors the web `EtaTrackingPage.vue` — polls the public ETA endpoint
/// every 10 seconds and displays the provider on a map.
class EtaTrackingScreen extends StatefulWidget {
  const EtaTrackingScreen({super.key, required this.token});

  final String token;

  static const String routeName = 'EtaTracking';
  static const String routePath = '/eta-tracking';

  @override
  State<EtaTrackingScreen> createState() => _EtaTrackingScreenState();
}

class _EtaTrackingScreenState extends State<EtaTrackingScreen> {
  Map<String, dynamic>? _etaData;
  bool _loading = true;
  bool _error = false;
  bool _expired = false;
  Timer? _pollTimer;
  GoogleMapController? _mapController;
  LatLng? _providerPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchEta();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchEta() async {
    final data = await EtaTrackingService.instance.pollEta(widget.token);
    if (!mounted) return;

    if (data == null) {
      setState(() {
        _error = true;
        _loading = false;
      });
      return;
    }

    final status = data['status'] as String? ?? '';
    if (['completed', 'cancelled', 'disputed'].contains(status)) {
      _pollTimer?.cancel();
      _pollTimer = null;
    }

    final lat = data['provider_lat'] as num?;
    final lng = data['provider_lng'] as num?;
    final newLatLng =
        (lat != null && lng != null) ? LatLng(lat.toDouble(), lng.toDouble()) : null;

    setState(() {
      _etaData = data;
      _loading = false;
      _error = false;
      if (newLatLng != null) {
        _providerPosition = newLatLng;
        _markers = {
          Marker(
            markerId: const MarkerId('provider'),
            position: newLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: data['provider_first_name'] as String? ?? 'Provider',
              snippet: _statusLabel(status),
            ),
          ),
        };
      }
    });

    if (newLatLng != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newLatLng, 15),
      );
    }

    _startPolling();
  }

  void _startPolling() {
    _pollTimer ??= Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchEta(),
    );
  }

  Future<void> _retry() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    await _fetchEta();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'en_route':
        return 'On the way';
      case 'arrived':
        return 'Arrived at location';
      case 'in_progress':
        return 'Service in progress';
      case 'completed':
        return 'Service completed';
      case 'cancelled':
        return 'Booking cancelled';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        title: Text(
          'Track Provider',
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.primaryText),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.primaryText),
            onPressed: _retry,
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(AppThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error) {
      return _buildErrorState(theme);
    }
    if (_expired) {
      return _buildExpiredState(theme);
    }
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: _providerPosition != null
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _providerPosition!,
                    zoom: 15,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                )
              : Center(
                  child: Text(
                    'Waiting for provider location...',
                    style: GoogleFonts.poppins(color: theme.secondaryText),
                  ),
                ),
        ),
        Expanded(child: _buildInfoCard(theme)),
      ],
    );
  }

  Widget _buildInfoCard(AppThemeData theme) {
    final status = _etaData?['status'] as String? ?? '';
    final serviceName = _etaData?['service_title'] as String? ?? '';
    final providerName = _etaData?['provider_first_name'] as String? ?? 'Provider';
    final category = _etaData?['category'] as String? ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.person, color: theme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: theme.primaryText,
                            ),
                          ),
                          Text(
                            '$category • $serviceName',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status, theme).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _statusIcon(status),
                        color: _statusColor(status, theme),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _statusLabel(status),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: _statusColor(status, theme),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_providerPosition != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Provider Location',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_providerPosition!.latitude.toStringAsFixed(5)}, '
                    '${_providerPosition!.longitude.toStringAsFixed(5)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: theme.secondaryText,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Updates every 10 seconds',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(AppThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64, color: theme.secondaryText),
          const SizedBox(height: 16),
          Text(
            'Could not load tracking data',
            style: GoogleFonts.poppins(color: theme.secondaryText),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retry,
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredState(AppThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_off, size: 64, color: theme.secondaryText),
          const SizedBox(height: 16),
          Text(
            'This tracking link has expired',
            style: GoogleFonts.poppins(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status, AppThemeData theme) {
    switch (status) {
      case 'en_route':
        return theme.primary;
      case 'arrived':
        return const Color(0xFF0F766E);
      case 'in_progress':
        return const Color(0xFF0F766E);
      case 'completed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return theme.error;
      default:
        return theme.secondaryText;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'en_route':
        return Icons.directions_car;
      case 'arrived':
        return Icons.location_on;
      case 'in_progress':
        return Icons.build;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
