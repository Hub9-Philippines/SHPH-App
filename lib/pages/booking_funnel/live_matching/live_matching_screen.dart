import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/api/models/service_listing.dart';
import '/models/service_listing.dart';
import '/api/resources/bookings_api.dart';
import '/api/resources/ondemand_jobs_api.dart';
import '/api/resources/services_api.dart';
import '/app_state.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_feedback.dart';
import '/components/map_radar_scan.dart';
import '/components/smooth_progress_bar.dart';
import '/l10n/app_localizations.dart';
import '/main.dart';
import '/utils/geo_utils.dart';
import '/theme/app_theme.dart';
import '../status_page.dart';
import '../../../api/app_config.dart';
import '../../booking_details/booking_details_widget.dart';
import '../booking_controller.dart';
import '../booking_models.dart';
import '../booking_repository.dart';
import '../booking_flow_screen.dart';
import '../widgets/booking_flow_route.dart';
import '../widgets/booking_map_sheet_host.dart';

// ────────────────────────────────────────────────────────────────────────
// Screen
// ────────────────────────────────────────────────────────────────────────

/// The on-demand search runs for 180s with a 4→24 km radius ladder widened
/// one rung every 30s (parity with shph-web/src/utils/onDemandRadius.ts).
const _searchWindowSeconds = 180;

class LiveMatchingScreen extends StatefulWidget {
  const LiveMatchingScreen({
    required this.bookingDate,
    super.key,
    this.showMap = true,
    this.serviceTitle,
  });

  final bool showMap;
  final String? serviceTitle;
  final DateTime bookingDate;

  @override
  State<LiveMatchingScreen> createState() => _LiveMatchingScreenState();
}

class _LiveMatchingScreenState extends State<LiveMatchingScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────
  late final AnimationController _gradientController;

  // ── Native map radar ripple (only when the screen shows a map) ─────
  RadarScanController? _scanController;

  // ── Map ────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  Set<Marker>? _mapMarkers;
  LatLng? _lastMarkerLocation;

  // ── Timer / stage ──────────────────────────────────────────────────
  Timer? _pollTimer;
  int _secondsRemaining = 180;
  bool _timedOut = false;
  bool _isRealJob = false;
  String? _liveJobId;
  double _currentRadiusKm = 4;
  DateTime? _lastExpandAt;
  static const _expandRungInterval = Duration(seconds: 30);

  // ── Provider matching ──────────────────────────────────────────────
  Map<String, dynamic>? _matchedPro;
  List<Map<String, dynamic>> _nearbyPros = [];
  LatLng? _providerLatLng;
  String bookingStatus = 'confirmation pending';

  /// True while a user-initiated broadcast retry is in flight (failure card
  /// spinner).
  bool _isRetryingBroadcast = false;

  // ── Fluid sheet & map viewport extent ─────────────────────────────
  double _bottomSheetExtent = 0.45;
  double _settledSheetExtent = 0.45;
  Offset? _pinScreenOffset;
  DraggableScrollableController? _sheetController;
  Timer? _boundsUpdateTimer;

  // ── Ripple pin resync (map padding / camera moves) ────────────────
  EdgeInsets? _lastMapPadding;
  DateTime _lastCameraMoveSync = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _pinResyncTimer;

  // ── Zoom targets per stage ─────────────────────────────────────────
  static const _zoomNearby = 16.0;
  static const _zoomMatched = 15.0;

  // ── Lifecycle ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    bookingStatus = 'confirmation pending';

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _sheetController = DraggableScrollableController();

    // Read initial dispatch state if controller was already running
    final booking = context.read<BookingFlowController?>();
    if (booking != null) {
      _liveJobId = booking.liveJobId;
      _isRealJob = (_liveJobId ?? '').isNotEmpty;
      if (booking.liveMatchingSecondsRemaining > 0 &&
          booking.liveMatchingSecondsRemaining < _searchWindowSeconds) {
        _secondsRemaining = booking.liveMatchingSecondsRemaining;
      }
      _bottomSheetExtent = booking.lastSheetExtent.clamp(0.15, 0.85);
      _settledSheetExtent = _bottomSheetExtent;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          booking
            ..setMatchingActive(true)
            ..setMinimized(false);
        }
      });
    } else {
      _liveJobId = null;
      _isRealJob = false;
      _settledSheetExtent = _bottomSheetExtent;
    }

    // Generate nearby pros immediately — context is valid in initState
    // because the widget is already in the tree when pushed via Navigator.
    _generateNearbyPros();

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollTick());
  }

  /// Lazily creates the native radar ripple controller once the theme is
  /// available; the ripple only exists when the screen shows a map.
  void _ensureScanController() {
    if (!widget.showMap || _scanController != null) return;
    _scanController = RadarScanController(
      vsync: this,
      center: _rippleCenter(),
      ringColor: AppTheme.of(context).primary,
      maxRadiusMeters: _currentRadiusKm * 1000,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureScanController();
  }

  LatLng _rippleCenter() {
    final draft = context.read<BookingFlowController?>()?.draft;
    return LatLng(
      draft?.latitude ?? 14.5995,
      draft?.longitude ?? 120.9842,
    );
  }

  Future<void> _generateNearbyPros() async {
    final appState = FFAppState();
    final useLocation = GeoUtils.hasValidLocation(
      appState.selectedLatitude,
      appState.selectedLongitude,
    );

    List<ShphServiceListing> listings = const [];
    try {
      final page = await ShphServicesApi.instance.listListings(
        ordering: '-rating',
        pageSize: 20,
        latitude: useLocation ? appState.selectedLatitude : null,
        longitude: useLocation ? appState.selectedLongitude : null,
      );
      listings = page.results
          .where((s) => s.latitude != null && s.longitude != null)
          .toList();
    } catch (_) {
      listings = const [];
    }

    if (!mounted) return;
    setState(() {
      _nearbyPros = listings.map(_listingToPro).toList();
    });
  }

  static Map<String, dynamic> _listingToPro(ShphServiceListing s) {
    final distanceKm = s.distanceKm;
    return {
      'providerId': s.provider?.toString() ?? '${s.id}',
      'providerName': s.providerName ?? 'Professional',
      'providerPhoto': s.providerPhoto ?? '',
      'providerLatitude': s.latitude,
      'providerLongitude': s.longitude,
      'distanceKm': distanceKm ?? 99.0,
      'distanceText': distanceKm != null
          ? (distanceKm < 1.0
              ? '${(distanceKm * 1000).round()} m away'
              : '${distanceKm.toStringAsFixed(1)} km away')
          : 'nearby',
      'rating': double.tryParse(s.rating ?? '0') ?? 0.0,
      'completedJobs': 0,
      'etaMinutes': distanceKm != null ? GeoUtils.calculateETA(distanceKm) : 15,
    };
  }

  // ── Real status polling ────────────────────────────────────────────
  void _pollTick() {
    if (!mounted || _timedOut || _matchedPro != null) {
      return;
    }
    if (_isRealJob) {
      _pollJobStatus();
    } else {
      _decrementCountdown();
    }
  }

  Future<void> _pollJobStatus() async {
    final jobId = _liveJobId;
    if (jobId == null || jobId.isEmpty) {
      _decrementCountdown();
      return;
    }
    try {
      final response = await ShphOnDemandJobsApi.instance.getJobStatus(jobId);
      if (!mounted) return;
      if (_timedOut || _matchedPro != null) return;

      final status = (response['status'] as String?)?.toLowerCase() ?? '';
      final radiusRaw = response['radius_km'];
      if (radiusRaw is num && radiusRaw > 0) {
        _currentRadiusKm = radiusRaw.toDouble();
        _onScanRadiusChanged();
      }
      _syncCountdownFromExpiry(response['expires_at'] as String?);
      if (!mounted || _timedOut) return;

      switch (status) {
        case 'accepted':
          await _onJobAccepted(response);
        case 'expired':
        case 'cancelled':
          _finishTimedOut();
        default:
          _maybeExpandRadius();
      }
    } catch (_) {
      // Transient network/parse error — keep the honest countdown moving.
      _decrementCountdown();
    }
  }

  void _syncCountdownFromExpiry(String? expiresAt) {
    final parsed = expiresAt == null ? null : DateTime.tryParse(expiresAt);
    if (parsed != null) {
      final seconds = parsed.difference(DateTime.now()).inSeconds;
      if (seconds <= 0) {
        _finishTimedOut();
        return;
      }
      _secondsRemaining = seconds.clamp(0, _searchWindowSeconds);
    } else {
      _decrementCountdown();
    }
    if (_secondsRemaining <= 0) {
      _finishTimedOut();
    }
  }

  void _decrementCountdown() {
    if (_secondsRemaining <= 0) {
      _finishTimedOut();
      return;
    }
    setState(() {
      _secondsRemaining--;
      context
          .read<BookingFlowController?>()
          ?.setLiveMatchingSecondsRemaining(_secondsRemaining);
      if (_secondsRemaining % 30 == 0 && _secondsRemaining < _searchWindowSeconds) {
        _gradientController.forward(from: 0.0);
        _animateMapZoom();
      }
      if (_secondsRemaining <= 0) {
        _timedOut = true;
        _scanController?.stop();
        _gradientController.stop();
        _pollTimer?.cancel();
      }
    });
  }

  void _finishTimedOut() {
    if (!mounted) return;
    setState(() {
      if (!_timedOut) {
        _timedOut = true;
        _secondsRemaining = 0;
      }
      _scanController?.stop();
      _gradientController.stop();
    });
    _pollTimer?.cancel();
  }

  // Walks the 4→8→12→16→20→24 km radius ladder while the job is still
  // searching. Mirrors the backend/web cadence: one rung every 30s over the
  // 180s search window, snapping to the next multiple of 4 km (parity with
  // shph-web/src/utils/onDemandRadius.ts computeExpandTarget).
  void _maybeExpandRadius() {
    final jobId = _liveJobId;
    if (jobId == null || jobId.isEmpty) return;
    final now = DateTime.now();
    if (_lastExpandAt != null &&
        now.difference(_lastExpandAt!) < _expandRungInterval) {
      return;
    }
    final nextRadius = _computeExpandTarget(_currentRadiusKm);
    if (nextRadius <= _currentRadiusKm) return;
    _currentRadiusKm = nextRadius.toDouble();
    _lastExpandAt = now;
    _onScanRadiusChanged();
    unawaited(_expandRadiusQuietly(jobId, nextRadius));
  }

  // Next rung above [currentRadiusKm], snapped to a multiple of 4 km, capped
  // at 24 km. Never narrows. Mirrors the web's computeExpandTarget.
  static int _computeExpandTarget(double currentKm) {
    const step = 4.0;
    const maxKm = 24.0;
    final rung = (currentKm / step).floorToDouble() * step + step;
    final target = rung.clamp(currentKm, maxKm);
    return target.round();
  }

  Future<void> _expandRadiusQuietly(String jobId, int radiusKm) async {
    try {
      await ShphOnDemandJobsApi.instance.expandRadius(jobId, radiusKm);
    } catch (_) {
      // Radius expansion is best-effort; ignore transient failures.
    }
  }

  Future<void> _onJobAccepted(Map<String, dynamic> response) async {
    bookingStatus = 'booking confirmed';
    final bookingId = (response['booking_id'] ??
            (response['booking'] is Map
                ? (response['booking'] as Map)['id']
                : null))
        ?.toString();

    if (bookingId != null && bookingId.isNotEmpty) {
      await _resolveAcceptedProvider(bookingId);
    }
    if (!mounted) return;

    if (_matchedPro == null) {
      _useNearestRealPro();
    }
    if (!mounted) return;

    if (_matchedPro != null) {
      setState(() {
        _pollTimer?.cancel();
        _scanController?.stop();
        _gradientController.stop();
      });
    } else {
      // Accepted but could not resolve a real provider — honest fallback to
      // the timeout sheet rather than fabricating one.
      _finishTimedOut();
    }
  }

  Future<void> _resolveAcceptedProvider(String bookingId) async {
    try {
      final booking = await ShphBookingsApi.instance.getBooking(bookingId);
      final listing = _matchingListingFor(booking.providerId);

      if (listing != null) {
        _adoptMatchedPro(
          pro: {
            ...listing,
            if ((booking.providerName ?? '').isNotEmpty)
              'providerName': booking.providerName,
            if ((booking.providerPhoto ?? '').isNotEmpty)
              'providerPhoto': booking.providerPhoto,
          },
        );
        return;
      }

      // No matching listing with real coords — nothing to route to.
      _matchedPro = null;
    } catch (_) {
      _matchedPro = null;
    }
  }

  Map<String, dynamic>? _matchingListingFor(int? providerId) {
    if (providerId != null) {
      for (final pro in _nearbyPros) {
        if (pro['providerId'] == providerId.toString()) {
          return pro;
        }
      }
    }
    return _closestNearbyPro();
  }

  Map<String, dynamic>? _closestNearbyPro() {
    if (_nearbyPros.isEmpty) return null;
    final sorted = [..._nearbyPros]
      ..sort((a, b) =>
          (a['distanceKm'] as double).compareTo(b['distanceKm'] as double));
    return sorted.first;
  }

  void _useNearestRealPro() {
    final pro = _closestNearbyPro();
    if (pro == null) {
      return;
    }
    _adoptMatchedPro(pro: pro);
  }

  void _adoptMatchedPro({required Map<String, dynamic> pro}) {
    final lat = pro['providerLatitude'] as double?;
    final lng = pro['providerLongitude'] as double?;
    if (lat == null || lng == null) {
      return;
    }
    setState(() {
      _matchedPro = pro;
      _providerLatLng = LatLng(lat, lng);
      _pollTimer?.cancel();
      _scanController?.stop();
      _gradientController.stop();
    });
  }

  /// Re-runs ONLY the on-demand broadcast (the booking already exists) and
  /// resumes polling on success. Used by the failure card's retry action.
  Future<void> _retryBroadcast() async {
    if (_isRetryingBroadcast) return;
    final booking = context.read<BookingFlowController?>();
    final draft = booking?.draft;
    if (booking == null || draft == null) return;

    setState(() => _isRetryingBroadcast = true);
    try {
      final repo = booking.repository;
      if (repo is ShphBookingRepository) {
        await repo.broadcastOnDemandJobOnly(draft);
      }
    } catch (_) {
      // Repository records the error; the card simply re-renders it.
    }
    if (!mounted) return;
    setState(() => _isRetryingBroadcast = false);

    final jobId = booking.liveJobId ?? '';
    if (jobId.isNotEmpty) {
      // Broadcast recovered — flip back to the real polling loop.
      _pollTimer?.cancel();
      setState(() {
        _liveJobId = jobId;
        _isRealJob = true;
        _timedOut = false;
      });
      if (widget.showMap) {
        _ensureScanController();
        _scanController?.restart();
      }
      _gradientController.reset();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _pollTick(),
      );
    }
  }

  void _retryProviderSearch() {
    _pollTimer?.cancel();
    _generateNearbyPros();
    setState(() {
      _matchedPro = null;
      _providerLatLng = null;
      _timedOut = false;
      _secondsRemaining = _searchWindowSeconds;
      _currentRadiusKm = 4;
      _lastExpandAt = null;
      bookingStatus = 'confirmation pending';
    });
    if (widget.showMap) {
      _ensureScanController();
      _scanController?.restart();
    }
    _gradientController.reset();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollTick());
  }

  void _onRetryMatching() {
    if (_isRealJob) {
      _retryBroadcast();
    } else {
      _retryProviderSearch();
    }
  }

  void _openScheduleInstead() {
    final booking = context.read<BookingFlowController?>();
    if (booking != null) {
      booking.setUrgency(BookingUrgency.scheduled);
      booking.setMatchingActive(false);
      booking.setMinimized(false);
    }
    final draft = booking?.draft;
    final listing = draft == null
        ? null
        : ServiceListing(
            id: draft.serviceListingId ?? 0,
            title: draft.serviceTitle ?? 'Service',
            categoryName: draft.serviceCategoryName,
            description: draft.serviceDescription,
            basePrice: draft.serviceBasePrice,
            priceUnit: draft.servicePriceUnit,
            thumbnail: draft.serviceImageUrl,
          );

    if (listing != null) {
      Navigator.of(context).pushReplacement(
        buildBookingFlowRoute(
          BookingFlowScreen(
            selectedService: listing,
            initialUrgency: BookingUrgency.scheduled,
          ),
        ),
      );
    } else {
      _goHome();
    }
  }

  @override
  void dispose() {
    _boundsUpdateTimer?.cancel();
    _pinResyncTimer?.cancel();
    _sheetController?.dispose();
    _pollTimer?.cancel();
    _scanController?.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  // ── Map zoom / framing ─────────────────────────────────────────────
  void _animateMapZoom() {
    if (_matchedPro != null) {
      _mapController?.animateCamera(CameraUpdate.zoomTo(_zoomMatched));
      return;
    }
    if (_timedOut) {
      _mapController?.animateCamera(CameraUpdate.zoomTo(_zoomNearby));
      return;
    }
    _fitCameraToRadius();
  }

  /// Reacts to a scan-radius change: re-sizes the ripple and re-frames the
  /// map so the enlarged radius (and ripple) stays visible.
  void _onScanRadiusChanged() {
    _scanController?.updateMaxRadiusMeters(_currentRadiusKm * 1000);
    _fitCameraToRadius();
  }

  /// Frames the map so the full current scan radius (and the ripple rings)
  /// fit inside the viewport. No-op until the map controller is available.
  void _fitCameraToRadius() {
    final controller = _mapController;
    if (controller == null) {
      return;
    }
    final bounds = _radiusBounds(
      _rippleCenter(),
      _currentRadiusKm * 1000,
    );
    try {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 96));
    } catch (_) {
      // Map not laid out yet — the initial camera position still applies.
    }
    // The fit animation moves the camera under us; refresh the ripple center
    // once this frame lands, then again whenever the camera settles.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updatePinScreenOffset();
      }
    });
  }

  /// [LatLngBounds] bounding a circle of [radiusMeters] around [center].
  static LatLngBounds _radiusBounds(LatLng center, double radiusMeters) {
    const earthRadiusMeters = 6371000.0;
    final latSpanDeg =
        radiusMeters / earthRadiusMeters * (180 / math.pi);
    final cosLat = math.cos(center.latitude * math.pi / 180).abs();
    final lngSpanDeg = cosLat < 1e-6
        ? latSpanDeg
        : radiusMeters / (earthRadiusMeters * cosLat) * (180 / math.pi);
    return LatLngBounds(
      southwest: LatLng(
        center.latitude - latSpanDeg,
        center.longitude - lngSpanDeg,
      ),
      northeast: LatLng(
        center.latitude + latSpanDeg,
        center.longitude + lngSpanDeg,
      ),
    );
  }

  int _currentStage() {
    if (_matchedPro != null) {
      return 4;
    }
    if (_timedOut || _secondsRemaining <= 0) {
      return 3;
    }
    if (_secondsRemaining > 120) {
      return 1;
    }
    if (_secondsRemaining > 60) {
      return 2;
    }
    return 3;
  }

  // ── Matching stage helpers ─────────────────────────────────────────
  _MatchingStage _matchingStage(int seconds, AppLocalizations l10n) {
    if (_matchedPro != null) {
      final name = _matchedPro!['providerName'] as String? ?? 'a pro';
      return _MatchingStage(
        label: l10n.bfProviderFound,
        subtitle: l10n.bfNameOnWay(name),
      );
    }
    if (seconds > 120) {
      return _MatchingStage(
        label: l10n.bfBroadcastingRequest,
        subtitle: l10n.bfAlertingNearbyProviders,
      );
    }
    if (seconds > 60) {
      return _MatchingStage(
        label: l10n.bfCheckingAvailability,
        subtitle: l10n.bfComparingWhoReaches,
      );
    }
    return _MatchingStage(
      label: l10n.bfFinalNearbySweep,
      subtitle: l10n.bfFinalPass,
    );
  }

  Future<void> _updatePinScreenOffset() async {
    final controller = _mapController;
    if (controller == null || !mounted) return;
    try {
      final screenCoord = await controller.getScreenCoordinate(_rippleCenter());
      if (!mounted) return;
      final newOffset = Offset(
        screenCoord.x.toDouble(),
        screenCoord.y.toDouble(),
      );
      _scanController?.updateScreenOffset(newOffset);
      if (_pinScreenOffset != newOffset) {
        setState(() {
          _pinScreenOffset = newOffset;
        });
      }
    } catch (_) {}
  }

  void _scheduleBoundsUpdate() {
    _boundsUpdateTimer?.cancel();
    _boundsUpdateTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _settledSheetExtent = _bottomSheetExtent;
        });
        _fitCameraToRadius();
        _updatePinScreenOffset();
      }
    });
  }

  // ── Cancel / back / minimize ─────────────────────────────────────────
  void _onMinimize() {
    final booking = context.read<BookingFlowController?>();
    booking?.setMatchingActive(true);
    booking?.setMinimized(true);
    booking?.setLastSheetExtent(_bottomSheetExtent);
    booking?.setLiveMatchingSecondsRemaining(_secondsRemaining);
    if (mounted) {
      _goHome();
    }
  }

  void _onBackOrCancel() {
    if (_timedOut || _matchedPro != null) {
      _goHome();
      return;
    }
    _onMinimize();
  }

  Future<void> _showCancelDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirmDialog(
      context: context,
      title: l10n.bfCancelProviderSearchQ,
      message: l10n.bfCancelSearchBody,
      confirmText: l10n.bfCancelSearch,
      cancelText: l10n.bfContinueSearch,
      destructive: true,
    );
    if (!mounted || confirmed != true) {
      return;
    }
    final booking = context.read<BookingFlowController?>();
    booking?.setMatchingActive(false);
    booking?.setMinimized(false);
    final jobId = _liveJobId;
    if (jobId != null && jobId.isNotEmpty) {
      ShphOnDemandJobsApi.instance.cancelJob(jobId).ignore();
    }
    _goHome();
  }

  void _popClean() {
    final booking = context.read<BookingFlowController?>();
    booking?.setLiveSearchTimedOut(true);
    if (mounted) {
      _goHome();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final booking = context.watch<BookingFlowController?>();
    final draft = booking?.draft;
    final location = LatLng(
      draft?.latitude ?? 14.5995,
      draft?.longitude ?? 120.9842,
    );
    final serviceTitle =
        widget.serviceTitle ?? draft?.serviceTitle ?? l10n.bfServiceRequest;
    final stage = _matchingStage(_secondsRemaining, l10n);

    if (_matchedPro != null && _providerLatLng != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _goHome();
          }
        },
        child: _AssignedProviderRouteMap(
          clientLocation: location,
          providerLocation: _providerLatLng!,
          pro: _matchedPro!,
          serviceTitle: serviceTitle,
          addressLabel: draft?.address.label ?? l10n.bfPinnedLocation,
          addressLine:
              '${draft?.address.line1 ?? l10n.bfLocationLoading}${(draft?.address.city ?? '').isNotEmpty ? ', ${draft!.address.city}' : ''}',
          referenceId: booking?.activeReferenceId,
          locationLabel: _resolveLocationLabel(draft, l10n),
          bookingStatus: bookingStatus,
          bookingDate: widget.bookingDate,
          onFindAnotherProvider: _retryProviderSearch,
          onBackHome: _goHome,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final currentSheetExtent = _settledSheetExtent.clamp(0.15, 0.85);
        final mapPadding = EdgeInsets.only(
          bottom: constraints.maxHeight * currentSheetExtent,
        );

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              return;
            }
            _onBackOrCancel();
          },
          child: Scaffold(
            backgroundColor: AppTheme.of(context).primaryBackground,
            body: NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if ((notification.extent - _bottomSheetExtent).abs() > 0.005) {
                  setState(() {
                    _bottomSheetExtent = notification.extent;
                  });
                  booking?.setLastSheetExtent(notification.extent);
                  _scheduleBoundsUpdate();
                }
                return false;
              },
              child: Stack(
                children: [
                  // ── Layer 1: Full-screen map (with dynamic bottom padding) ──
                  Positioned.fill(
                    child: _mapBody(location, mapPadding),
                  ),

                  // ── Layer 2: Top minimize floating button ──
                  if (!_timedOut)
                    Positioned(
                      key: const ValueKey('live_matching_top_minimize_btn'),
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      child: _TopMinimizeButton(
                        onTap: _onMinimize,
                      ),
                    ),

                  // ── Layer 3: Collapsible dashboard ──
                  Positioned.fill(
                    key: const ValueKey('live_matching_dashboard_layer'),
                    child: _buildDashboard(
                      stage: stage,
                      draft: draft,
                      booking: booking,
                      serviceTitle: serviceTitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Opens the created booking's detail page as the failure card's escape
  /// route (the booking exists even when the broadcast failed).
  void _openBookingDetails(BookingFlowController? booking) {
    final bookingId = booking?.activeReferenceId;
    if (bookingId == null || bookingId.isEmpty) {
      return;
    }
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => BookingDetailsWidget(bookingId: bookingId),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const NavBarPage(
          initialPage: 'Home',
          disableResizeToAvoidBottomInset: true,
        ),
      ),
      (route) => false,
    );
  }

  String _resolveLocationLabel(BookingDraft? draft, AppLocalizations l10n) {
    final label = draft?.address.label.trim() ?? '';
    if (label.isNotEmpty) {
      return label;
    }

    final addressParts = [
      draft?.address.line1,
      draft?.address.city,
    ]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (addressParts.isNotEmpty) {
      return addressParts.join(', ');
    }

    return l10n.bfYourCurrentLocation;
  }

  // ── Map widget ──────────────────────────────────────────────────────
  Widget _mapBody(LatLng location, EdgeInsets padding) {
    if (!widget.showMap) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.of(context).primaryBackground,
              AppTheme.of(context).secondaryBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }

    // The GoogleMap viewport shifts when its padding changes (sheet settle),
    // which invalidates the cached pin screen offset without a camera event.
    // Re-sync once this frame lands, plus one delayed pass for the platform
    // view to finish applying the new viewport.
    if (_lastMapPadding != padding) {
      _lastMapPadding = padding;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updatePinScreenOffset();
        }
      });
      _pinResyncTimer?.cancel();
      _pinResyncTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          _updatePinScreenOffset();
        }
      });
    }

    final scan = _scanController;
    // Stable marker set: rebuilt only when the provider marker appears or the
    // pinned location changes, so per-tick platform diffs touch only circles.
    final markers = (_providerLatLng == null && location == _lastMarkerLocation)
        ? (_mapMarkers ??= _buildMapMarkers(location))
        : _buildMapMarkers(location);
    _lastMarkerLocation = location;

    final map = GoogleMap(
      initialCameraPosition: CameraPosition(
        target: location,
        zoom: _zoomNearby,
      ),
      padding: padding,
      zoomControlsEnabled: false,
      compassEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        _fitCameraToRadius();
        _updatePinScreenOffset();
      },
      // Camera fits animate for a while; re-sync the ripple center at most
      // every 100 ms so the ring tracks the pin tip during the move.
      onCameraMove: (_) {
        final now = DateTime.now();
        if (now.difference(_lastCameraMoveSync).inMilliseconds >= 100) {
          _lastCameraMoveSync = now;
          _updatePinScreenOffset();
        }
      },
      onCameraIdle: () {
        _updatePinScreenOffset();
      },
      markers: markers,
    );

    if (scan == null) {
      return map;
    }

    return Stack(
      children: [
        map,
        ValueListenableBuilder<bool>(
          valueListenable: scan.isScanningListenable,
          builder: (context, isScanning, _) => MapRadarPulseOverlay(
            ringColor: AppTheme.of(context).primary,
            isScanning: isScanning && _matchedPro == null && !_timedOut,
            mapPadding: padding,
            customCenterOffset: _pinScreenOffset,
          ),
        ),
      ],
    );
  }

  Set<Marker> _buildMapMarkers(LatLng location) {
    return {
      Marker(
        markerId: const MarkerId('booking_location'),
        position: location,
        anchor: const Offset(0.5, 1),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
      ),
      if (_providerLatLng != null)
        Marker(
          markerId: const MarkerId('provider_location'),
          position: _providerLatLng!,
          anchor: const Offset(0.5, 1),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
    };
  }

  // ── Collapsible dashboard ──────────────────────────────────────────
  Widget _buildDashboard({
    required _MatchingStage stage,
    required BookingDraft? draft,
    required BookingFlowController? booking,
    required String serviceTitle,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    final totalFare =
        booking?.serverQuote?.total ?? booking?.draft.serviceBasePrice ?? 0.0;
    final paymentMethod = booking?.paymentLabel(l10n) ?? 'GCash';
    final appliedTip = booking?.tipAmount ?? 0.0;

    final initialSize = ((!_isRealJob && _matchedPro == null && !_timedOut)
            ? math.max(_bottomSheetExtent, 0.65)
            : _bottomSheetExtent)
        .clamp(0.15, 0.85);

    return DraggableScrollableSheet(
      key: const ValueKey('live_matching_sheet'),
      controller: _sheetController,
      initialChildSize: initialSize,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.15, 0.45, 0.85],
      snapAnimationDuration: const Duration(milliseconds: 280),
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: _timedOut
              ? _TimeoutSheet(
                  scrollController: scrollController,
                  theme: theme,
                  onRetrySearch: _onRetryMatching,
                  onScheduleInstead: _openScheduleInstead,
                  onCancelSearch: _showCancelDialog,
                )
              : _matchedPro != null
                  ? _MatchedSheet(
                      scrollController: scrollController,
                      theme: theme,
                      pro: _matchedPro!,
                      addressLabel:
                          draft?.address.label ?? l10n.bfPinnedLocation,
                      addressLine:
                          '${draft?.address.line1 ?? l10n.bfLocationLoading}${(draft?.address.city ?? '').isNotEmpty ? ', ${draft!.address.city}' : ''}',
                      referenceId: booking?.activeReferenceId,
                      onBackHome: _goHome,
                    )
                  : _SearchingSheet(
                      scrollController: scrollController,
                      theme: theme,
                      stageLabel: stage.label,
                      stageSubtitle: stage.subtitle,
                      addressLabel:
                          draft?.address.label ?? l10n.bfPinnedLocation,
                      addressLine:
                          '${draft?.address.line1 ?? l10n.bfLocationLoading}${(draft?.address.city ?? '').isNotEmpty ? ', ${draft!.address.city}' : ''}',
                      serviceTitle: serviceTitle,
                      paymentMethod: paymentMethod,
                      totalFare: totalFare,
                      appliedTip: appliedTip,
                      referenceId:
                          booking?.liveJobId ?? booking?.activeReferenceId,
                      providerCount: booking?.liveProviderCount,
                      feeMin: booking?.liveEstFeeMin,
                      feeMax: booking?.liveEstFeeMax,
                      secondsRemaining: _secondsRemaining,
                      searchRadiusKm: _currentRadiusKm,
                      gradientValue: _gradientController,
                      stageIndex: _currentStage(),
                      broadcastFailed: !_isRealJob,
                      broadcastError: booking?.liveBroadcastError,
                      isRetryingBroadcast: _isRetryingBroadcast,
                      onRetryBroadcast: _retryBroadcast,
                      onViewBooking: () => _openBookingDetails(booking),
                      onCancel: _showCancelDialog,
                      onMinimize: _onMinimize,
                      onTipSubmitted: (tip) async {
                        if (booking != null) {
                          await booking.updateTip(tip);
                        }
                      },
                    ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Matching stage model
// ────────────────────────────────────────────────────────────────────────

class _AssignedProviderRouteMap extends StatefulWidget {
  const _AssignedProviderRouteMap({
    required this.clientLocation,
    required this.providerLocation,
    required this.pro,
    required this.serviceTitle,
    required this.addressLabel,
    required this.addressLine,
    required this.locationLabel,
    required this.onBackHome,
    required this.onFindAnotherProvider,
    required this.bookingStatus,
    required this.bookingDate,
    this.referenceId,
  });

  final LatLng clientLocation;
  final LatLng providerLocation;
  final Map<String, dynamic> pro;
  final String serviceTitle;
  final String addressLabel;
  final String addressLine;
  final String locationLabel;
  final VoidCallback onBackHome;
  final VoidCallback onFindAnotherProvider;
  final String bookingStatus;
  final DateTime bookingDate;
  final String? referenceId;

  @override
  State<_AssignedProviderRouteMap> createState() =>
      _AssignedProviderRouteMapState();
}

class _AssignedProviderRouteMapState extends State<_AssignedProviderRouteMap> {
  static const double _collapsedSheetExtent = 0.25;
  static const double _expandedSheetExtent = 0.50;

  GoogleMapController? _mapController;
  Timer? _boundsDebounce;
  List<LatLng> _routePoints = const [];
  String? _routeError;
  String? _routeDistanceText;
  int? _routeEtaMinutes;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _fetchRoutePolyline();
  }

  @override
  void didUpdateWidget(covariant _AssignedProviderRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clientLocation != widget.clientLocation ||
        oldWidget.providerLocation != widget.providerLocation) {
      _fetchRoutePolyline();
      _scheduleBoundsUpdate();
    }
  }

  @override
  void dispose() {
    _boundsDebounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchRoutePolyline() async {
    final l10n = AppLocalizations.of(context)!;
    final fallbackRoute = [
      widget.clientLocation,
      widget.providerLocation,
    ];

    try {
      final polylinePoints = PolylinePoints(
        apiKey: AppConfig.googleDirectionsKey,
      );
      final result = await polylinePoints.getRouteBetweenCoordinates(
        // ignore: deprecated_member_use
        request: PolylineRequest(
          origin: PointLatLng(
            widget.clientLocation.latitude,
            widget.clientLocation.longitude,
          ),
          destination: PointLatLng(
            widget.providerLocation.latitude,
            widget.providerLocation.longitude,
          ),
          mode: TravelMode.driving,
          timeoutDuration: const Duration(seconds: 12),
        ),
      );
      final points = <LatLng>[];
      for (final point in result.points) {
        points.add(LatLng(point.latitude, point.longitude));
      }
      final routePoints = points.isEmpty ? fallbackRoute : points;
      final distanceMeters =
          result.totalDistanceValue ?? _routeDistanceMeters(routePoints);
      final etaMinutes = _etaMinutesFromRoute(
        durationSeconds: result.totalDurationValue,
        distanceMeters: result.totalDistanceValue,
        routePoints: routePoints,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _routePoints = routePoints;
        _routeDistanceText = _formatDistanceMeters(distanceMeters);
        _routeEtaMinutes = etaMinutes;
        _routeError = result.errorMessage?.isNotEmpty == true
            ? result.errorMessage
            : points.isEmpty
                ? l10n.bfNoRouteFound
                : null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _routePoints = fallbackRoute;
        _routeDistanceText = _formatDistanceMeters(
          _routeDistanceMeters(fallbackRoute),
        );
        _routeEtaMinutes = _etaMinutesFromRoute(routePoints: fallbackRoute);
        _routeError = l10n.bfRouteUnavailable;
      });
    }

    _scheduleBoundsUpdate();
  }

  void _scheduleBoundsUpdate() {
    _boundsDebounce?.cancel();
    _boundsDebounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted || !_mapReady) {
        return;
      }
      _updateMapBounds(widget.clientLocation, widget.providerLocation);
    });
  }

  void _updateMapBounds(LatLng client, LatLng provider) {
    final controller = _mapController;
    if (controller == null) {
      return;
    }

    final bounds = _boundsForPoints([
      client,
      provider,
      ..._routePoints,
    ]);
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  LatLngBounds _boundsForPoints(List<LatLng> points) {
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    if (minLat == maxLat) {
      minLat -= 0.001;
      maxLat += 0.001;
    }
    if (minLng == maxLng) {
      minLng -= 0.001;
      maxLng += 0.001;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  int _etaMinutesFromRoute({
    int? durationSeconds,
    int? distanceMeters,
    List<LatLng> routePoints = const [],
  }) {
    if (durationSeconds != null && durationSeconds > 0) {
      return math.max(1, (durationSeconds / 60).ceil());
    }

    final meters = distanceMeters ?? _routeDistanceMeters(routePoints);
    if (meters <= 0) {
      return widget.pro['etaMinutes'] as int? ?? 15;
    }

    const metersPerMinute = 500; // Approx. 30 km/h city driving fallback.
    return math.max(1, (meters / metersPerMinute).ceil());
  }

  int _routeDistanceMeters(List<LatLng> points) {
    if (points.length < 2) {
      return 0;
    }

    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += _distanceBetween(points[i], points[i + 1]);
    }
    return total.round();
  }

  double _distanceBetween(LatLng start, LatLng end) {
    const earthRadiusMeters = 6371000.0;
    final startLat = _degreesToRadians(start.latitude);
    final endLat = _degreesToRadians(end.latitude);
    final deltaLat = _degreesToRadians(end.latitude - start.latitude);
    final deltaLng = _degreesToRadians(end.longitude - start.longitude);

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(startLat) *
            math.cos(endLat) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;

  String _formatDistanceMeters(int meters) {
    if (meters <= 0) {
      return widget.pro['distanceText'] as String? ?? 'nearby';
    }
    if (meters < 1000) {
      return '$meters m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  bool _isBookingToday() {
    final now = DateTime.now();
    final date = widget.bookingDate;
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _openStatusPage() {
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => StatusPage(
          bookingStatus: widget.bookingStatus,
          bookingDate: widget.bookingDate,
          providerName: widget.pro['providerName'] as String? ?? l10n.bfProfessional,
          serviceTitle: widget.serviceTitle,
          clientLatitude: widget.clientLocation.latitude,
          clientLongitude: widget.clientLocation.longitude,
          providerLatitude: widget.providerLocation.latitude,
          providerLongitude: widget.providerLocation.longitude,
          providerPhoto: widget.pro['providerPhoto'] as String?,
          bookingReference: widget.referenceId,
          shouldPopToHome: true,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _openBookingsPage() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const NavBarPage(
          initialPage: 'Bookings',
          disableResizeToAvoidBottomInset: true,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final name = widget.pro['providerName'] as String? ?? l10n.bfProfessional;
    final photo = widget.pro['providerPhoto'] as String?;
    final rating = widget.pro['rating'] as double? ?? 0;
    final distanceText = _routeDistanceText ??
        (widget.pro['distanceText'] as String? ?? 'nearby');
    final etaMinutes =
        _routeEtaMinutes ?? (widget.pro['etaMinutes'] as int? ?? 15);
    final completedJobs = widget.pro['completedJobs'] as int? ?? 0;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          _AssignedRouteTopBar(
            serviceTitle: widget.serviceTitle,
            providerName: name,
            locationLabel: widget.locationLabel,
            bookingStatus: widget.bookingStatus,
          ),
          Expanded(
            child: BookingMapSheetHost(
              resizable: BookingResizableSheet(
                initialFraction: _collapsedSheetExtent,
                minFraction: _collapsedSheetExtent,
                maxFraction: _expandedSheetExtent,
              ),
              // The sheet's max extent grows with its measured content height,
              // clamped to the collapsed/expanded bounds — the same rule the
              // screen used to apply privately.
              maxExtentBuilder: (availableHeight, measuredContentHeight) {
                if (availableHeight <= 0 || measuredContentHeight == null) {
                  return _expandedSheetExtent;
                }
                final measuredExtent = (measuredContentHeight! / availableHeight)
                    .clamp(_collapsedSheetExtent, _expandedSheetExtent)
                    .toDouble();
                return math.max(_collapsedSheetExtent, measuredExtent);
              },
              includeTopSafeArea: false,
              topCameraPadding: 16,
              bottomCameraPadding: 24,
              horizontalCameraPadding: 16,
              removeBottomPaddingForDraggable: true,
              onSheetContentHeightChanged: (_) => _scheduleBoundsUpdate(),
              mapBuilder: (context, cameraPadding) => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.clientLocation,
                  zoom: 14,
                ),
                padding: cameraPadding,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                markers: {
                  Marker(
                    markerId: const MarkerId('client_location'),
                    position: widget.clientLocation,
                    anchor: const Offset(0.5, 1),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                  ),
                  Marker(
                    markerId: const MarkerId('provider_location'),
                    position: widget.providerLocation,
                    anchor: const Offset(0.5, 1),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('provider_route'),
                    points: _routePoints.isEmpty
                        ? [
                            widget.clientLocation,
                            widget.providerLocation,
                          ]
                        : _routePoints,
                    color: theme.primary,
                    width: 5,
                    jointType: JointType.round,
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                  ),
                },
                onMapCreated: (controller) {
                  _mapController = controller;
                  _mapReady = true;
                  _scheduleBoundsUpdate();
                },
              ),
              sheetBuilder: (context, onHeightChanged, scrollController) =>
                  _AssignedRouteBottomSheet(
                scrollController: scrollController!,
                theme: theme,
                providerName: name,
                providerPhoto: photo,
                rating: rating,
                distanceText: distanceText,
                etaMinutes: etaMinutes,
                completedJobs: completedJobs,
                addressLabel: widget.addressLabel,
                addressLine: widget.addressLine,
                referenceId: widget.referenceId,
                routeError: _routeError,
                bottomInset: bottomPadding,
                onContentHeightChanged: (height) {
                  onHeightChanged(height);
                  _scheduleBoundsUpdate();
                },
                bookingStatus: widget.bookingStatus,
                isBookingToday: _isBookingToday(),
                onFindAnotherProvider: widget.onFindAnotherProvider,
                onViewStatus: _openStatusPage,
                onViewBookings: _openBookingsPage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedRouteTopBar extends StatelessWidget {
  const _AssignedRouteTopBar({
    required this.serviceTitle,
    required this.providerName,
    required this.locationLabel,
    required this.bookingStatus,
  });

  final String serviceTitle;
  final String providerName;
  final String locationLabel;
  final String bookingStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          border: Border(bottom: BorderSide(color: theme.alternate)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.route_rounded, color: theme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          providerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.titleSmall.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _BookingStatusChip(
                        status: bookingStatus,
                        theme: theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.bfHeadingTo(locationLabel),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignedRouteBottomSheet extends StatelessWidget {
  const _AssignedRouteBottomSheet({
    required this.scrollController,
    required this.theme,
    required this.providerName,
    required this.rating,
    required this.distanceText,
    required this.etaMinutes,
    required this.completedJobs,
    required this.addressLabel,
    required this.addressLine,
    required this.bottomInset,
    required this.onContentHeightChanged,
    required this.bookingStatus,
    required this.isBookingToday,
    required this.onFindAnotherProvider,
    required this.onViewStatus,
    required this.onViewBookings,
    this.providerPhoto,
    this.referenceId,
    this.routeError,
  });

  final ScrollController scrollController;
  final AppThemeData theme;
  final String providerName;
  final String? providerPhoto;
  final double rating;
  final String distanceText;
  final int etaMinutes;
  final int completedJobs;
  final String addressLabel;
  final String addressLine;
  final double bottomInset;
  final ValueChanged<double> onContentHeightChanged;
  final String bookingStatus;
  final bool isBookingToday;
  final VoidCallback onFindAnotherProvider;
  final VoidCallback onViewStatus;
  final VoidCallback onViewBookings;
  final String? referenceId;
  final String? routeError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.primaryBackground.withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: AppThemeData.shadowCard,
        ),
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
          children: [
            _MeasureSize(
              onChange: (size) => onContentHeightChanged(size.height),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: theme.alternate,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              theme.primary.withValues(alpha: 0.10),
                          backgroundImage:
                              providerPhoto != null && providerPhoto!.isNotEmpty
                                  ? NetworkImage(providerPhoto!)
                                  : null,
                          child: providerPhoto == null || providerPhoto!.isEmpty
                              ? Icon(Icons.person_rounded, color: theme.primary)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                providerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.titleMedium.override(
                                  font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: theme.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: theme.bodySmall.override(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.work_outline_rounded,
                                    size: 14,
                                    color: theme.secondaryText,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.bfJobsCount(completedJobs),
                                    style: theme.bodySmall.override(
                                      color: theme.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MatchedInfoTile(
                            theme: theme,
                            icon: Icons.access_time_rounded,
                            label: l10n.bfEta,
                            value: l10n.bfMinutesShort(etaMinutes),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MatchedInfoTile(
                            theme: theme,
                            icon: Icons.near_me_rounded,
                            label: l10n.bfDistance,
                            value: distanceText,
                          ),
                        ),
                      ],
                    ),
                    if ((routeError ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _MetaRow(
                        theme: theme,
                        icon: Icons.info_outline_rounded,
                        title: l10n.bfRoute,
                        subtitle: routeError!,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _MetaRow(
                      theme: theme,
                      icon: Icons.place_rounded,
                      title: addressLabel,
                      subtitle: addressLine,
                    ),
                    if ((referenceId ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _MetaRow(
                        theme: theme,
                        icon: Icons.tag_rounded,
                        title: l10n.lmReference,
                        subtitle: referenceId!,
                      ),
                    ],
                    const SizedBox(height: 20),
                    _BookingActionButton(
                      theme: theme,
                      bookingStatus: bookingStatus,
                      isBookingToday: isBookingToday,
                      onFindAnotherProvider: onFindAnotherProvider,
                      onViewStatus: onViewStatus,
                      onViewBookings: onViewBookings,
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

class _BookingStatusChip extends StatelessWidget {
  const _BookingStatusChip({
    required this.status,
    required this.theme,
  });

  final String status;
  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'booking confirmed' => const Color(0xFF16A34A),
      'booking cancelled' => const Color(0xFFDC2626),
      _ => const Color(0xFFF59E0B),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        _titleCaseStatus(l10n, normalized),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.bodySmall.override(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BookingActionButton extends StatelessWidget {
  const _BookingActionButton({
    required this.theme,
    required this.bookingStatus,
    required this.isBookingToday,
    required this.onFindAnotherProvider,
    required this.onViewStatus,
    required this.onViewBookings,
  });

  final AppThemeData theme;
  final String bookingStatus;
  final bool isBookingToday;
  final VoidCallback onFindAnotherProvider;
  final VoidCallback onViewStatus;
  final VoidCallback onViewBookings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = bookingStatus.toLowerCase();

    if (normalized == 'booking confirmed') {
      return _SheetPrimaryButton(
        theme: theme,
        label: isBookingToday ? l10n.bfViewStatus : l10n.bfViewBookings,
        icon: isBookingToday
            ? Icons.track_changes_rounded
            : Icons.calendar_month_rounded,
        backgroundColor: theme.primary,
        onPressed: isBookingToday ? onViewStatus : onViewBookings,
      );
    }

    return _SheetPrimaryButton(
      theme: theme,
      label: l10n.bfFindAnotherProvider,
      icon: Icons.person_search_rounded,
      backgroundColor: theme.secondary,
      onPressed: normalized == 'confirmation pending'
          ? () => _confirmFindAnotherProvider(context)
          : onFindAnotherProvider,
    );
  }

  Future<void> _confirmFindAnotherProvider(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldCancel = await AppFeedback.confirmDialog(
      context: context,
      title: l10n.bfFindAnotherProviderQ,
      message: l10n.bfCancelBookingQ,
      confirmText: l10n.bfYesCancel,
      cancelText: l10n.bfNo,
      destructive: true,
    );

    if (shouldCancel == true) {
      onFindAnotherProvider();
    }
  }
}

class _SheetPrimaryButton extends StatelessWidget {
  const _SheetPrimaryButton({
    required this.theme,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  final AppThemeData theme;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: AppButton(
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          borderRadius: 18,
          width: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.titleMedium.override(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
}

String _titleCaseStatus(AppLocalizations l10n, String status) {
  final normalized = status.toLowerCase();
  return switch (normalized) {
    'booking confirmed' => l10n.bfBookingConfirmed,
    'booking cancelled' => l10n.bfBookingCancelled,
    _ => l10n.bfConfirmationPending,
  };
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({
    required this.onChange,
    required super.child,
  });

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) {
      return;
    }
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}

class _MatchingStage {
  const _MatchingStage({
    required this.label,
    required this.subtitle,
  });
  final String label;
  final String subtitle;
}


// ────────────────────────────────────────────────────────────────────────
// Animated gradient progress bar
// ────────────────────────────────────────────────────────────────────────

class _GradientBar extends StatelessWidget {
  const _GradientBar({
    required this.gradientValue,
    required this.stageIndex,
    required this.progress,
    required this.theme,
  });

  final Animation<double> gradientValue;
  final int stageIndex;
  final double progress;
  final AppThemeData theme;

  static const _stages = <_GradientStage>[
    _GradientStage(
      color1: Color(0xFF1E3A8A),
      color2: Color(0xFF4FC3F7),
    ),
    _GradientStage(
      color1: Color(0xFF3F51B5),
      color2: Color(0xFF7C4DFF),
    ),
    _GradientStage(
      color1: Color(0xFF7C4DFF),
      color2: Color(0xFFE040FB),
    ),
  ];

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: gradientValue,
        builder: (context, _) {
          final t = gradientValue.isAnimating ? gradientValue.value : 1.0;

          final prevIdx = (stageIndex - 2).clamp(0, _stages.length - 1);
          final currIdx = (stageIndex - 1).clamp(0, _stages.length - 1);

          final prev = _stages[prevIdx];
          final curr = _stages[currIdx];

          return Container(
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  Color.lerp(prev.color1, curr.color1, t)!,
                  Color.lerp(prev.color2, curr.color2, t)!,
                ],
              ),
            ),
            child: SmoothProgress(
              value: progress,
              builder: (context, widthFactor) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widthFactor,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _GradientStage {
  const _GradientStage({
    required this.color1,
    required this.color2,
  });
  final Color color1;
  final Color color2;
}

// ────────────────────────────────────────────────────────────────────────
// Top minimize button
// ────────────────────────────────────────────────────────────────────────

class _TopMinimizeButton extends StatelessWidget {
  const _TopMinimizeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.primaryBackground.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
            boxShadow: AppThemeData.shadowCard,
          ),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 26,
            color: theme.primaryText,
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Matching header bar (Move It parity drag handle & status)
// ────────────────────────────────────────────────────────────────────────

class _MatchingHeaderBar extends StatelessWidget {
  const _MatchingHeaderBar({
    required this.theme,
    required this.stageLabel,
    required this.stageSubtitle,
    required this.searchRadiusKm,
    required this.onMinimize,
    required this.secondsRemaining,
    required this.gradientValue,
    required this.stageIndex,
  });

  final AppThemeData theme;
  final String stageLabel;
  final String stageSubtitle;
  final double searchRadiusKm;
  final VoidCallback onMinimize;
  final int secondsRemaining;
  final Animation<double> gradientValue;
  final int stageIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle pill
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            InkWell(
              onTap: onMinimize,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.alternate),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.primaryText,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bfFindingNearestProvider,
                    style: theme.titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                      ),
                      color: theme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stageSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.radar_rounded,
                    size: 14,
                    color: theme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${searchRadiusKm.toStringAsFixed(0)} km',
                    style: theme.labelSmall.override(
                      color: theme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _GradientBar(
          gradientValue: gradientValue,
          stageIndex: stageIndex,
          progress: (secondsRemaining / _searchWindowSeconds).clamp(0.0, 1.0),
          theme: theme,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Tip & incentive unit (Move It parity)
// ────────────────────────────────────────────────────────────────────────

class _TipSelectionCard extends StatefulWidget {
  const _TipSelectionCard({
    required this.theme,
    required this.onTipSubmitted,
    this.appliedTip = 0.0,
  });

  final AppThemeData theme;
  final Future<void> Function(double tip) onTipSubmitted;
  final double appliedTip;

  @override
  State<_TipSelectionCard> createState() => _TipSelectionCardState();
}

class _TipSelectionCardState extends State<_TipSelectionCard> {
  double? _selectedTip;
  bool _isSubmitting = false;

  final List<double> _presetTips = const [25.0, 50.0, 100.0];

  @override
  void initState() {
    super.initState();
    if (widget.appliedTip > 0) {
      _selectedTip = widget.appliedTip;
    }
  }

  Future<void> _submitTip() async {
    final tip = _selectedTip;
    if (tip == null || tip <= 0 || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onTipSubmitted(tip);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tip of ₱${tip.toStringAsFixed(2)} added!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showCustomTipDialog() async {
    final controller = TextEditingController(
      text: _selectedTip != null && !_presetTips.contains(_selectedTip)
          ? _selectedTip!.toStringAsFixed(0)
          : '',
    );
    final theme = widget.theme;

    final customAmount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.primaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Enter Custom Tip',
          style: theme.titleMedium.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            prefixText: '₱ ',
            hintText: 'e.g. 150',
            filled: true,
            fillColor: theme.secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.alternate),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
          ),
          AppButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                Navigator.of(dialogContext).pop(val);
              }
            },
            backgroundColor: theme.primary,
            foregroundColor: theme.onPrimary,
            borderRadius: 12,
            child: const Text('Set Tip'),
          ),
        ],
      ),
    );

    if (customAmount != null && mounted) {
      setState(() {
        _selectedTip = customAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isCustomSelected =
        _selectedTip != null && !_presetTips.contains(_selectedTip);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.volunteer_activism_rounded,
                  color: theme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a tip; 100% goes to the provider',
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tips incentivize nearby pros to accept faster',
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ..._presetTips.map((preset) {
                final isSelected = _selectedTip == preset;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTip = isSelected ? null : preset;
                        });
                      },
                      borderRadius:
                          BorderRadius.circular(AppThemeData.radiusPill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primary
                              : theme.primaryBackground,
                          borderRadius:
                              BorderRadius.circular(AppThemeData.radiusPill),
                          border: Border.all(
                            color:
                                isSelected ? theme.primary : theme.alternate,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '₱${preset.toStringAsFixed(0)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected ? Colors.white : theme.primaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              Expanded(
                child: InkWell(
                  onTap: _showCustomTipDialog,
                  borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isCustomSelected
                          ? theme.primary
                          : theme.primaryBackground,
                      borderRadius:
                          BorderRadius.circular(AppThemeData.radiusPill),
                      border: Border.all(
                        color:
                            isCustomSelected ? theme.primary : theme.alternate,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isCustomSelected
                          ? '₱${_selectedTip!.toStringAsFixed(0)}'
                          : 'Custom',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isCustomSelected
                            ? Colors.white
                            : theme.primaryText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedTip != null && _selectedTip! > 0) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: AppButton(
                onPressed: _isSubmitting ? null : _submitTip,
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                borderRadius: 14,
                width: double.infinity,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit tip (₱${_selectedTip!.toStringAsFixed(2)})',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Booking route details tile (Service location, category, payment, fare)
// ────────────────────────────────────────────────────────────────────────

class _BookingRouteDetailsTile extends StatelessWidget {
  const _BookingRouteDetailsTile({
    required this.theme,
    required this.addressLabel,
    required this.addressLine,
    required this.serviceTitle,
    required this.paymentMethod,
    required this.totalFare,
    this.tipAmount = 0.0,
  });

  final AppThemeData theme;
  final String addressLabel;
  final String addressLine;
  final String serviceTitle;
  final String paymentMethod;
  final double totalFare;
  final double tipAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Location Row with Blue Dot
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primary.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Location',
                      style: theme.labelSmall.override(
                        color: theme.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addressLine.isNotEmpty ? addressLine : addressLabel,
                      style: theme.bodyMedium.override(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Container(
              width: 2,
              height: 12,
              color: theme.alternate,
            ),
          ),
          const SizedBox(height: 4),
          // Target Category / Service Row with Red Dot
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.error.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category / Service',
                      style: theme.labelSmall.override(
                        color: theme.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      serviceTitle,
                      style: theme.bodyMedium.override(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          // Payment Method Row
          Row(
            children: [
              Icon(Icons.payment_rounded, size: 20, color: theme.secondaryText),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Payment Method',
                  style: theme.bodyMedium.override(
                    color: theme.secondaryText,
                  ),
                ),
              ),
              Text(
                paymentMethod,
                style: theme.bodyMedium.override(
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Total Fare Breakdown Row
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 20, color: theme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Fare',
                      style: theme.bodyMedium.override(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                    if (tipAmount > 0)
                      Text(
                        'Includes ₱${tipAmount.toStringAsFixed(2)} tip',
                        style: theme.bodySmall.override(
                          color: theme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '₱${totalFare.toStringAsFixed(2)}',
                style: theme.titleMedium.override(
                  fontWeight: FontWeight.w800,
                  color: theme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Searching sheet (collapsible dashboard content)
// ────────────────────────────────────────────────────────────────────────

class _SearchingSheet extends StatelessWidget {
  const _SearchingSheet({
    required this.scrollController,
    required this.theme,
    required this.stageLabel,
    required this.stageSubtitle,
    required this.addressLabel,
    required this.addressLine,
    required this.serviceTitle,
    required this.paymentMethod,
    required this.totalFare,
    required this.appliedTip,
    required this.onCancel,
    required this.onMinimize,
    required this.onTipSubmitted,
    required this.secondsRemaining,
    required this.searchRadiusKm,
    required this.gradientValue,
    required this.stageIndex,
    this.referenceId,
    this.providerCount,
    this.feeMin,
    this.feeMax,
    this.broadcastFailed = false,
    this.broadcastError,
    this.isRetryingBroadcast = false,
    this.onRetryBroadcast,
    this.onViewBooking,
  });

  final ScrollController scrollController;
  final AppThemeData theme;
  final String stageLabel;
  final String stageSubtitle;
  final String addressLabel;
  final String addressLine;
  final String serviceTitle;
  final String paymentMethod;
  final double totalFare;
  final double appliedTip;
  final VoidCallback onCancel;
  final VoidCallback onMinimize;
  final Future<void> Function(double tip) onTipSubmitted;
  final String? referenceId;
  final int? providerCount;
  final double? feeMin;
  final double? feeMax;
  final int secondsRemaining;
  final double searchRadiusKm;
  final Animation<double> gradientValue;
  final int stageIndex;
  final bool broadcastFailed;
  final String? broadcastError;
  final bool isRetryingBroadcast;
  final VoidCallback? onRetryBroadcast;
  final VoidCallback? onViewBooking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _MatchingHeaderBar(
          theme: theme,
          stageLabel: stageLabel,
          stageSubtitle: stageSubtitle,
          searchRadiusKm: searchRadiusKm,
          onMinimize: onMinimize,
          secondsRemaining: secondsRemaining,
          gradientValue: gradientValue,
          stageIndex: stageIndex,
        ),
        if (broadcastFailed) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
              border: Border.all(
                color: theme.warning.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: theme.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.bfBroadcastFailedTitle,
                        style: theme.labelMedium.override(
                          fontWeight: FontWeight.w800,
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        (broadcastError != null &&
                                broadcastError!.trim().isNotEmpty)
                            ? l10n.bfBroadcastFailedRetryBody
                            : l10n.bfBroadcastFailedBody,
                        style: theme.bodySmall.override(
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onRetryBroadcast != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isRetryingBroadcast ? null : onRetryBroadcast,
                icon: isRetryingBroadcast
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.primary,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  isRetryingBroadcast
                      ? l10n.bfBroadcastRetrying
                      : l10n.bfBroadcastRetry,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(38),
                  side: BorderSide(color: theme.primary),
                  foregroundColor: theme.primary,
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
                  ),
                ),
              ),
            ),
          ],
          if (onViewBooking != null) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onViewBooking,
                icon: const Icon(Icons.receipt_long_rounded, size: 16),
                label: Text(l10n.bfViewBookingDetails),
                style: TextButton.styleFrom(
                  foregroundColor: theme.secondaryText,
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
        const SizedBox(height: 18),
        _TipSelectionCard(
          theme: theme,
          onTipSubmitted: onTipSubmitted,
          appliedTip: appliedTip,
        ),
        const SizedBox(height: 16),
        _BookingRouteDetailsTile(
          theme: theme,
          addressLabel: addressLabel,
          addressLine: addressLine,
          serviceTitle: serviceTitle,
          paymentMethod: paymentMethod,
          totalFare: totalFare,
          tipAmount: appliedTip,
        ),
        if ((referenceId ?? '').isNotEmpty) ...[
          const SizedBox(height: 14),
          _MetaRow(
            theme: theme,
            icon: Icons.tag_rounded,
            title: 'Search Reference',
            subtitle: referenceId!,
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: AppButton(
            onPressed: onCancel,
            variant: AppButtonVariant.outlined,
            borderSide: BorderSide(color: theme.error),
            foregroundColor: theme.error,
            borderRadius: 16,
            width: double.infinity,
            child: Text(
              'Cancel Booking',
              style: theme.bodyMedium.override(
                fontWeight: FontWeight.w700,
                color: theme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Matched sheet — shown when a nearby pro has been found
// ────────────────────────────────────────────────────────────────────────

class _MatchedSheet extends StatelessWidget {
  const _MatchedSheet({
    required this.scrollController,
    required this.theme,
    required this.pro,
    required this.addressLabel,
    required this.addressLine,
    required this.onBackHome,
    this.referenceId,
  });

  final ScrollController scrollController;
  final AppThemeData theme;
  final Map<String, dynamic> pro;
  final String addressLabel;
  final String addressLine;
  final VoidCallback onBackHome;
  final String? referenceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = pro['providerName'] as String? ?? l10n.bfProfessional;
    final photo = pro['providerPhoto'] as String?;
    final rating = pro['rating'] as double? ?? 0;
    final distanceText = pro['distanceText'] as String? ?? 'nearby';
    final etaMinutes = pro['etaMinutes'] as int? ?? 15;
    final completedJobs = pro['completedJobs'] as int? ?? 0;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Matched banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.success.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.success.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_pin_circle_rounded,
                  color: theme.success,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bfProviderFound,
                      style: theme.labelLarge.override(
                        color: theme.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.bfProAssigned,
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // Provider card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.alternate),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.iconBackground,
                backgroundImage: photo != null ? NetworkImage(photo) : null,
                child: photo == null
                    ? Icon(Icons.person_rounded, size: 30, color: theme.primary)
                    : null,
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.titleSmall.override(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 16, color: theme.warning),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: theme.bodySmall.override(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.work_outline_rounded,
                            size: 14, color: theme.secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          '$completedJobs jobs',
                          style: theme.bodySmall.override(
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // ETA + distance row
        Row(
          children: [
            Expanded(
              child: _MatchedInfoTile(
                theme: theme,
                icon: Icons.access_time_rounded,
                label: l10n.bfEta,
                value: '$etaMinutes min',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MatchedInfoTile(
                theme: theme,
                icon: Icons.near_me_rounded,
                label: l10n.bfDistance,
                value: distanceText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MetaRow(
          theme: theme,
          icon: Icons.place_rounded,
          title: addressLabel,
          subtitle: addressLine,
        ),
        if ((referenceId ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          _MetaRow(
            theme: theme,
            icon: Icons.tag_rounded,
            title: l10n.bfReference,
            subtitle: referenceId!,
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: AppButton(
            onPressed: onBackHome,
            backgroundColor: theme.primary,
            foregroundColor: theme.onPrimary,
            borderRadius: 18,
            width: double.infinity,
            child: Text(
              l10n.bfBackToHome,
              style: theme.titleMedium.override(
                fontWeight: FontWeight.w700,
                color: theme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchedInfoTile extends StatelessWidget {
  const _MatchedInfoTile({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  final AppThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.alternate),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
                Text(
                  value,
                  style: theme.bodyMedium.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

// ────────────────────────────────────────────────────────────────────────
// Timeout sheet
// ────────────────────────────────────────────────────────────────────────

class _TimeoutSheet extends StatelessWidget {
  const _TimeoutSheet({
    required this.scrollController,
    required this.theme,
    required this.onRetrySearch,
    required this.onScheduleInstead,
    required this.onCancelSearch,
  });

  final ScrollController scrollController;
  final AppThemeData theme;
  final VoidCallback onRetrySearch;
  final VoidCallback onScheduleInstead;
  final VoidCallback onCancelSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Icon(Icons.timer_off_rounded, size: 48, color: theme.secondaryText),
          const SizedBox(height: 12),
          Text(
            l10n.bfProvidersBusy,
            textAlign: TextAlign.center,
            style: theme.titleMedium.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.bfAdjustOrGoHome,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AppButton(
              onPressed: onRetrySearch,
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
              borderRadius: 16,
              width: double.infinity,
              child: Text(
                l10n.tmSearchAgain,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AppButton(
              onPressed: onScheduleInstead,
              variant: AppButtonVariant.outlined,
              borderSide: BorderSide(color: theme.primary),
              foregroundColor: theme.primary,
              borderRadius: 16,
              width: double.infinity,
              child: Text(
                l10n.tmScheduleInstead,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: AppButton(
              onPressed: onCancelSearch,
              variant: AppButtonVariant.text,
              foregroundColor: theme.secondaryText,
              borderRadius: 16,
              width: double.infinity,
              child: Text(
                l10n.bfCancelSearch,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Meta row (small label + value card)
// ────────────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final AppThemeData theme;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.bodyMedium.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
