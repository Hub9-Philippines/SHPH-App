import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/api/models/service_listing.dart';
import '/api/resources/bookings_api.dart';
import '/api/resources/ondemand_jobs_api.dart';
import '/api/resources/services_api.dart';
import '/app_state.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_feedback.dart';
import '/l10n/app_localizations.dart';
import '/main.dart';
import '/utils/geo_utils.dart';
import '/theme/app_theme.dart';
import '../status_page.dart';
import '../../../api/app_config.dart';
import '../booking_controller.dart';
import '../booking_models.dart';

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
  late final AnimationController _radarController;
  late final AnimationController _gradientController;

  // ── Map ────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;

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

  // ── Zoom targets per stage ─────────────────────────────────────────
  static const _zoomNearby = 16.0;
  static const _zoomChecking = 14.5;
  static const _zoomSweep = 13.0;
  static const _zoomMatched = 15.0;

  // ── Lifecycle ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    bookingStatus = 'confirmation pending';
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    )..repeat();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Real on-demand job id (when the broadcast succeeded). When present the
    // screen polls the server for the real matching status; otherwise it runs
    // an honest countdown that never fabricates a match.
    _liveJobId = context.read<BookingFlowController?>()?.liveJobId;
    _isRealJob = (_liveJobId ?? '').isNotEmpty;

    // Generate nearby pros immediately — context is valid in initState
    // because the widget is already in the tree when pushed via Navigator.
    _generateNearbyPros();

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollTick());
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
      if (_secondsRemaining % 30 == 0 && _secondsRemaining < _searchWindowSeconds) {
        _gradientController.forward(from: 0.0);
        _animateMapZoom();
      }
      if (_secondsRemaining <= 0) {
        _timedOut = true;
        _radarController.stop();
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
      _radarController.stop();
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
        _radarController.stop();
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
    if (pro == null) return;
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
      _radarController.stop();
      _gradientController.stop();
    });
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
    _radarController.repeat();
    _gradientController.reset();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollTick());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _radarController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  // ── Map zoom animation ────────────────────────────────────────────
  void _animateMapZoom() {
    final zoom = _targetZoom();
    _mapController?.animateCamera(CameraUpdate.zoomTo(zoom));
  }

  double _targetZoom() {
    if (_matchedPro != null) {
      return _zoomMatched;
    }
    if (_timedOut) {
      return _zoomNearby;
    }
    if (_secondsRemaining > 120) {
      return _zoomNearby;
    }
    if (_secondsRemaining > 60) {
      return _zoomChecking;
    }
    return _zoomSweep;
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

  // ── Cancel / back ──────────────────────────────────────────────────
  void _onBackOrCancel() {
    if (_timedOut) {
      _popClean();
      return;
    }
    _showCancelDialog();
  }

  void _showCancelDialog() {
    final l10n = AppLocalizations.of(context)!;
    AppFeedback.confirmDialog(
      context: context,
      title: l10n.bfCancelProviderSearchQ,
      message: l10n.bfCancelSearchBody,
      confirmText: l10n.bfCancelSearch,
      cancelText: l10n.bfContinueSearch,
      destructive: true,
    ).then((value) {
      if (value == true) {
        _popClean();
      }
    });
  }

  void _popClean() {
    final booking = context.read<BookingFlowController?>();
    booking?.setMatchingActive(true);
    booking?.setLiveSearchTimedOut(true);
    if (mounted) {
      Navigator.of(context).pop();
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

    final showActive = !_timedOut && _matchedPro == null;

    if (_matchedPro != null && _providerLatLng != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _goHome();
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

    return PopScope(
      canPop: _matchedPro != null || _timedOut,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onBackOrCancel();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ── Layer 1: Full-screen map ──────────────────────────
            Positioned.fill(
              child: _mapBody(location),
            ),

            // ── Layer 2: Radar / success pulse overlay ────────────
            if (showActive)
              Positioned.fill(
                child: IgnorePointer(
                  child: _RadarPulse(
                    controller: _radarController,
                    theme: AppTheme.of(context),
                  ),
                ),
              ),
            // ── Layer 3: Top status badge ─────────────────────────
            if (!_timedOut)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _StatusBadge(
                  serviceTitle: serviceTitle,
                  stageLabel: stage.label,
                  stageSubtitle: stage.subtitle,
                  secondsRemaining: _secondsRemaining,
                  gradientValue: _gradientController,
                  stageIndex: _currentStage(),
                  matchedPro: _matchedPro,
                ),
              ),

            // ── Layer 4: Collapsible dashboard ──────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildDashboard(
                stage: stage,
                draft: draft,
                booking: booking,
              ),
            ),
          ],
        ),
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
  Widget _mapBody(LatLng location) {
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

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: location,
        zoom: _zoomNearby,
      ),
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
      },
      markers: {
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
      },
    );
  }

  // ── Collapsible dashboard ──────────────────────────────────────────
  Widget _buildDashboard({
    required _MatchingStage stage,
    required BookingDraft? draft,
    required BookingFlowController? booking,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.12,
      maxChildSize: 0.82,
      snap: true,
      snapSizes: const [0.12, 0.38, 0.72],
      snapAnimationDuration: const Duration(milliseconds: 320),
      builder: (context, scrollController) => Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: theme.primaryBackground.withValues(alpha: 0.78),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 0.5,
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              child: _timedOut
                  ? _TimeoutSheet(
                      scrollController: scrollController,
                      theme: theme,
                      onAdjustBooking: _popClean,
                      onBackHome: () =>
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const NavBarPage(
                            initialPage: 'Home',
                            disableResizeToAvoidBottomInset: true,
                          ),
                        ),
                        (route) => false,
                      ),
                    )
                  : _matchedPro != null
                      ?                           _MatchedSheet(
                          scrollController: scrollController,
                          theme: theme,
                          pro: _matchedPro!,
                          addressLabel:
                              draft?.address.label ?? l10n.bfPinnedLocation,
                          addressLine:
                              '${draft?.address.line1 ?? l10n.bfLocationLoading}${(draft?.address.city ?? '').isNotEmpty ? ', ${draft!.address.city}' : ''}',
                          referenceId: booking?.activeReferenceId,
                          onBackHome: () =>
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const NavBarPage(
                                initialPage: 'Home',
                                disableResizeToAvoidBottomInset: true,
                              ),
                            ),
                            (route) => false,
                          ),
                        )
                      :                           _SearchingSheet(
                          scrollController: scrollController,
                          theme: theme,
                          stageLabel: stage.label,
                          stageSubtitle: stage.subtitle,
                          addressLabel:
                              draft?.address.label ?? l10n.bfPinnedLocation,
                          addressLine:
                              '${draft?.address.line1 ?? l10n.bfLocationLoading}${(draft?.address.city ?? '').isNotEmpty ? ', ${draft!.address.city}' : ''}',
                          referenceId:
                              booking?.liveJobId ?? booking?.activeReferenceId,
                          providerCount: booking?.liveProviderCount,
                          feeMin: booking?.liveEstFeeMin,
                          feeMax: booking?.liveEstFeeMax,
                          secondsRemaining: _secondsRemaining,
                          gradientValue: _gradientController,
                          stageIndex: _currentStage(),
                          onCancel: _showCancelDialog,
                        ),
            ),
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
  double _bottomSheetExtent = _collapsedSheetExtent;
  double? _sheetContentHeight;
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

  double _dynamicMaxSheetExtent(double availableHeight) {
    if (availableHeight <= 0 || _sheetContentHeight == null) {
      return _expandedSheetExtent;
    }

    final measuredExtent = (_sheetContentHeight! / availableHeight)
        .clamp(_collapsedSheetExtent, _expandedSheetExtent)
        .toDouble();
    return math.max(_collapsedSheetExtent, measuredExtent);
  }

  void _handleSheetContentHeightChanged(double height) {
    if (((_sheetContentHeight ?? 0) - height).abs() < 1) {
      return;
    }
    setState(() {
      _sheetContentHeight = height;
    });
    _scheduleBoundsUpdate();
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
          clientLocation: widget.clientLocation,
          providerLocation: widget.providerLocation,
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

  bool _handleSheetNotification(DraggableScrollableNotification notification) {
    if ((notification.extent - _bottomSheetExtent).abs() < 0.002) {
      return false;
    }
    setState(() {
      _bottomSheetExtent = notification.extent;
    });
    _scheduleBoundsUpdate();
    return false;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxSheetExtent =
                    _dynamicMaxSheetExtent(constraints.maxHeight);
                final currentSheetExtent = _bottomSheetExtent.clamp(
                  _collapsedSheetExtent,
                  maxSheetExtent,
                );
                final mapPadding = EdgeInsets.only(
                  top: 16,
                  bottom: constraints.maxHeight * currentSheetExtent +
                      bottomPadding +
                      24,
                  left: 16,
                  right: 16,
                );

                return NotificationListener<DraggableScrollableNotification>(
                  onNotification: _handleSheetNotification,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: widget.clientLocation,
                            zoom: 14,
                          ),
                          padding: mapPadding,
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
                      ),
                      Positioned.fill(
                        child: MediaQuery.removePadding(
                          context: context,
                          removeBottom: true,
                          child: DraggableScrollableSheet(
                            initialChildSize: _collapsedSheetExtent,
                            minChildSize: _collapsedSheetExtent,
                            maxChildSize: maxSheetExtent,
                            builder: (context, scrollController) =>
                                _AssignedRouteBottomSheet(
                              scrollController: scrollController,
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
                              onContentHeightChanged:
                                  _handleSheetContentHeightChanged,
                              bookingStatus: widget.bookingStatus,
                              isBookingToday: _isBookingToday(),
                              onFindAnotherProvider:
                                  widget.onFindAnotherProvider,
                              onViewStatus: _openStatusPage,
                              onViewBookings: _openBookingsPage,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
                    const SizedBox(height: 16),
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
// Radar pulse — CustomPainter for 3 cascading concentric circles
// ────────────────────────────────────────────────────────────────────────

class _RadarPulse extends StatelessWidget {
  const _RadarPulse({
    required this.controller,
    required this.theme,
  });

  final AnimationController controller;
  final AppThemeData theme;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final progress = controller.value * 3.0;
          return CustomPaint(
            painter: _RadarPainter(
              progress: progress,
              primaryColor: theme.primary,
            ),
          );
        },
      );
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.progress,
    required this.primaryColor,
  });

  final double progress;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.38;

    for (int i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final curved = Curves.easeOutCubic.transform(phase);
      final radius = math.max(10.0, curved * maxRadius);
      final opacity = (1.0 - curved) *
          (i == 0
              ? 0.55
              : i == 1
                  ? 0.38
                  : 0.22);

      // Ring fill (glow)
      final fillPaint = Paint()
        ..color = primaryColor.withValues(alpha: opacity * 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, fillPaint);

      // Ring stroke
      final strokePaint = Paint()
        ..color = primaryColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + (1.0 - curved) * 1.5;
      canvas.drawCircle(center, radius, strokePaint);
    }

    // Centre dot
    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, dotPaint);

    // Centre glow
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, 14, glowPaint);
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.progress != progress;
}

// ────────────────────────────────────────────────────────────────────────
// Match reveal — success pulse overlay when a provider is found
// ────────────────────────────────────────────────────────────────────────

// ────────────────────────────────────────────────────────────────────────
// Top status badge — glassmorphic card with animated gradient bar
// ────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.serviceTitle,
    required this.stageLabel,
    required this.stageSubtitle,
    required this.secondsRemaining,
    required this.gradientValue,
    required this.stageIndex,
    this.matchedPro,
  });

  final String serviceTitle;
  final String stageLabel;
  final String stageSubtitle;
  final int secondsRemaining;
  final Animation<double> gradientValue;
  final int stageIndex;
  final Map<String, dynamic>? matchedPro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    final isMatched = matchedPro != null;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primaryBackground.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isMatched
                  ? theme.success.withValues(alpha: 0.30)
                  : Colors.white.withValues(alpha: 0.18),
            ),
            boxShadow: AppThemeData.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      serviceTitle,
                      style: theme.bodyMedium.override(
                        fontWeight: FontWeight.w700,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                  if (isMatched)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.bfAssigned,
                        style: theme.labelSmall.override(
                          color: theme.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isMatched
                    ? l10n.bfProviderAssigned
                    : l10n.bfFindingNearestProvider,
                style: theme.titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stageSubtitle,
                style: theme.bodySmall.override(
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 10),
              // Stage badge + countdown row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isMatched
                          ? theme.success.withValues(alpha: 0.10)
                          : theme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      stageLabel,
                      style: theme.labelMedium.override(
                        color: isMatched ? theme.success : theme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!isMatched) ...[
                    const Spacer(),
                    Text(
                      '$secondsRemaining s',
                      style: theme.labelLarge.override(
                        color: theme.secondaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
              if (!isMatched) ...[
                const SizedBox(height: 10),
                _GradientBar(
                  gradientValue: gradientValue,
                  stageIndex: stageIndex,
                  progress: secondsRemaining / _searchWindowSeconds,
                  theme: theme,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
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
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.transparent,
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
    required this.onCancel,
    required this.secondsRemaining,
    required this.gradientValue,
    required this.stageIndex,
    this.referenceId,
    this.providerCount,
    this.feeMin,
    this.feeMax,
  });

  final ScrollController scrollController;
  final AppThemeData theme;
  final String stageLabel;
  final String stageSubtitle;
  final String addressLabel;
  final String addressLine;
  final VoidCallback onCancel;
  final String? referenceId;
  final int? providerCount;
  final double? feeMin;
  final double? feeMax;
  final int secondsRemaining;
  final Animation<double> gradientValue;
  final int stageIndex;

  static String _roundFee(double value) {
    if (!value.isFinite) {
      return '0';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          // Stage card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stageLabel,
                  style: theme.labelLarge.override(
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stageSubtitle,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Gradient progress bar
          _GradientBar(
            gradientValue: gradientValue,
            stageIndex: stageIndex,
            progress: (secondsRemaining / _searchWindowSeconds).clamp(0.0, 1.0),
            theme: theme,
          ),
          const SizedBox(height: 8),
          // Countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Searching ',
                style: theme.bodySmall.override(color: theme.secondaryText),
              ),
              Text(
                '$secondsRemaining s',
                style: theme.labelLarge.override(
                  color: theme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Header
          Text(
            l10n.bfSearchingNearbyProviders,
            style: theme.titleMedium.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.bfStayOnScreen,
            style: theme.bodyMedium.override(
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
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
              title: l10n.bfSearchReference,
              subtitle: referenceId!,
            ),
          ],
          if (providerCount != null && providerCount! > 0) ...[
            const SizedBox(height: 12),
            _MetaRow(
              theme: theme,
              icon: Icons.people_alt_outlined,
              title: 'Providers notified',
              subtitle: providerCount! == 1
                  ? '1 provider'
                  : '${providerCount!} providers',
            ),
          ],
          if (feeMin != null && feeMax != null) ...[
            const SizedBox(height: 12),
            _MetaRow(
              theme: theme,
              icon: Icons.request_quote_outlined,
              title: 'Estimated fee',
              subtitle:
                  '₱${_roundFee(feeMin!)} – ₱${_roundFee(feeMax!)}',
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: AppButton(
              onPressed: onCancel,
              variant: AppButtonVariant.outlined,
              borderSide: BorderSide(color: theme.alternate),
              foregroundColor: theme.secondaryText,
              borderRadius: 16,
              width: double.infinity,
              child: Text(l10n.bfCancelSearch),
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
    required this.onAdjustBooking,
    required this.onBackHome,
  });

  final ScrollController scrollController;
  final AppThemeData theme;
  final VoidCallback onAdjustBooking;
  final VoidCallback onBackHome;

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
            height: 54,
            child: AppButton(
              onPressed: onAdjustBooking,
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
              borderRadius: 16,
              width: double.infinity,
              child: Text(l10n.bfAdjustBooking),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: AppButton(
              onPressed: onBackHome,
              variant: AppButtonVariant.outlined,
              borderSide: BorderSide(color: theme.alternate),
              foregroundColor: theme.secondaryText,
              borderRadius: 16,
              width: double.infinity,
              child: Text(l10n.bfBackHome),
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
