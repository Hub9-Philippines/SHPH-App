import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '/api/resources/bookings_api.dart';
import '/services/logging_service.dart';

/// Service for real-time provider location tracking and ETA sharing.
///
/// Two modes:
/// - **Provider broadcast**: periodically polls GPS and pushes coords to backend
///   via `PATCH /api/services/bookings/<id>/location/`
/// - **Client polling**: polls `GET /api/services/eta/<token>/` to display
///   the provider's live location on a map
class EtaTrackingService {
  EtaTrackingService._();
  static final EtaTrackingService instance = EtaTrackingService._();

  final _bookingsApi = ShphBookingsApi.instance;

  Timer? _broadcastTimer;
  String? _activeBookingId;
  StreamSubscription<Position>? _positionStream;

  /// Start broadcasting provider location for a booking.
  ///
  /// Called when the provider transitions to `en_route` status.
  /// Uses Geolocator position stream for real-time updates, with a
  /// fallback periodic poll every 10 seconds.
  Future<void> startBroadcasting(String bookingId) async {
    if (_activeBookingId == bookingId) return;
    await stopBroadcasting();

    _activeBookingId = bookingId;
    LoggingService.info('ETA broadcast started for $bookingId', tag: 'ETA');

    // Check permissions
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      LoggingService.warning(
        'Location permission permanently denied — using periodic poll',
        tag: 'ETA',
      );
      _startPeriodicPoll(bookingId);
      return;
    }

    // Try position stream first
    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // only send updates every 10m
        ),
      ).listen(
        (position) => _sendLocation(bookingId, position),
        onError: (e) {
          LoggingService.error('Position stream error: $e', tag: 'ETA');
          _startPeriodicPoll(bookingId);
        },
      );
    } catch (e) {
      LoggingService.warning('Stream init failed, using poll: $e', tag: 'ETA');
      _startPeriodicPoll(bookingId);
    }
  }

  /// Stop broadcasting provider location.
  Future<void> stopBroadcasting() async {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    await _positionStream?.cancel();
    _positionStream = null;
    _activeBookingId = null;
    LoggingService.info('ETA broadcast stopped', tag: 'ETA');
  }

  /// Whether broadcasting is currently active.
  bool get isBroadcasting => _activeBookingId != null;

  void _startPeriodicPoll(String bookingId) {
    _broadcastTimer?.cancel();
    _broadcastTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          await _sendLocation(bookingId, position);
        } catch (e) {
          LoggingService.error('Periodic location poll failed: $e', tag: 'ETA');
        }
      },
    );
    // Send immediately
    _broadcastTimer?.tick;
  }

  Future<void> _sendLocation(String bookingId, Position position) async {
    try {
      await _bookingsApi.updateBookingLocation(
        bookingId,
        lat: position.latitude,
        lng: position.longitude,
      );
      LoggingService.debug(
        'Location sent: ${position.latitude}, ${position.longitude}',
        tag: 'ETA',
      );
    } catch (e) {
      LoggingService.error('Location send failed: $e', tag: 'ETA');
    }
  }

  // ── Client-side ETA polling ───────────────────────────────────────

  /// Poll ETA for a share token. Returns the ETA data or null on error.
  Future<Map<String, dynamic>?> pollEta(String token) async {
    try {
      return await _bookingsApi.getEtaPublic(token);
    } catch (e) {
      LoggingService.error('ETA poll failed: $e', tag: 'ETA');
      return null;
    }
  }

  /// Create a share-eta token for a booking (client side).
  Future<Map<String, dynamic>?> createShareToken(String bookingId) async {
    try {
      return await _bookingsApi.shareEta(bookingId);
    } catch (e) {
      LoggingService.error('Share ETA failed: $e', tag: 'ETA');
      return null;
    }
  }

  /// Calculate distance between two coordinates in km (haversine).
  double distanceKm({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }

  /// Estimate travel time in minutes given distance in km.
  /// Assumes average urban speed of 20 km/h.
  int estimateEtaMinutes(double distanceKm) {
    return (distanceKm / 20 * 60).round().clamp(1, 999);
  }
}
