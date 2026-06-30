import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/main.dart';
import '/services/nearby_pro_mock_data.dart';
import '/theme/app_theme.dart';
import '../booking_controller.dart';
import '../booking_models.dart';

// ────────────────────────────────────────────────────────────────────────
// Screen
// ────────────────────────────────────────────────────────────────────────

class LiveMatchingScreen extends StatefulWidget {
  const LiveMatchingScreen({
    super.key,
    this.showMap = true,
    this.serviceTitle,
  });

  final bool showMap;
  final String? serviceTitle;

  @override
  State<LiveMatchingScreen> createState() => _LiveMatchingScreenState();
}

class _LiveMatchingScreenState extends State<LiveMatchingScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────
  late final AnimationController _radarController;
  late final AnimationController _gradientController;
  late final AnimationController _matchRevealController;

  // ── Map ────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;

  // ── Timer / stage ──────────────────────────────────────────────────
  Timer? _timer;
  Timer? _matchTimer;
  int _secondsRemaining = 30;
  bool _timedOut = false;

  // ── Mock provider matching ─────────────────────────────────────────
  Map<String, dynamic>? _matchedPro;
  List<Map<String, dynamic>> _nearbyPros = [];
  LatLng? _providerLatLng;

  // ── Zoom targets per stage ─────────────────────────────────────────
  static const _zoomNearby = 16.0;
  static const _zoomChecking = 14.5;
  static const _zoomSweep = 13.0;
  static const _zoomMatched = 15.0;

  // ── Lifecycle ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    )..repeat();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _matchRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Generate nearby pros immediately — context is valid in initState
    // because the widget is already in the tree when pushed via Navigator.
    _generateNearbyPros();

    // Schedule the mock match at 5 seconds.
    _matchTimer = Timer(const Duration(seconds: 5), _onMatchFound);

    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _generateNearbyPros() {
    final booking = context.read<BookingFlowController?>();
    final draft = booking?.draft;
    _nearbyPros = NearbyProMockData.instance.generateNearbyPros(
      serviceId: draft?.serviceListingId ?? 0,
      category: draft?.serviceCategoryName ?? 'Cleaning',
      count: 3,
    );
  }

  void _onMatchFound() {
    if (!mounted || _timedOut || _matchedPro != null) return;
    if (_nearbyPros.isEmpty) return;

    // Pick the closest pro.
    _nearbyPros.sort((a, b) =>
        (a['distanceKm'] as double).compareTo(b['distanceKm'] as double));
    final pro = _nearbyPros.first;

    setState(() {
      _matchedPro = pro;
      _providerLatLng = LatLng(
        pro['providerLatitude'] as double,
        pro['providerLongitude'] as double,
      );
      _timer?.cancel();
      _matchTimer?.cancel();
      _radarController.stop();
      _gradientController.stop();
      _matchRevealController.forward(from: 0.0);
    });

    // Zoom to frame both the user pin and the provider dot.
    final booking = context.read<BookingFlowController?>();
    final draft = booking?.draft;
    final userLatLng = LatLng(
      draft?.latitude ?? 14.5995,
      draft?.longitude ?? 120.9842,
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            math.min(userLatLng.latitude, _providerLatLng!.latitude),
            math.min(userLatLng.longitude, _providerLatLng!.longitude),
          ),
          northeast: LatLng(
            math.max(userLatLng.latitude, _providerLatLng!.latitude),
            math.max(userLatLng.longitude, _providerLatLng!.longitude),
          ),
        ),
        80,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _matchTimer?.cancel();
    _radarController.dispose();
    _gradientController.dispose();
    _matchRevealController.dispose();
    super.dispose();
  }

  // ── Tick ───────────────────────────────────────────────────────────
  void _onTick(Timer timer) {
    if (!mounted) return;
    if (_matchedPro != null) {
      _timer?.cancel();
      return;
    }
    setState(() {
      _secondsRemaining--;
      if (_secondsRemaining <= 0) {
        _timedOut = true;
        _timer?.cancel();
        _radarController.stop();
        _gradientController.stop();
      } else if (_secondsRemaining == 20 || _secondsRemaining == 10) {
        _gradientController.forward(from: 0.0);
        _animateMapZoom();
      }
    });
  }

  // ── Map zoom animation ────────────────────────────────────────────
  void _animateMapZoom() {
    final zoom = _targetZoom();
    _mapController?.animateCamera(CameraUpdate.zoomTo(zoom));
  }

  double _targetZoom() {
    if (_matchedPro != null) return _zoomMatched;
    if (_timedOut) return _zoomNearby;
    if (_secondsRemaining > 20) return _zoomNearby;
    if (_secondsRemaining > 10) return _zoomChecking;
    return _zoomSweep;
  }

  int _currentStage() {
    if (_matchedPro != null) return 4;
    if (_timedOut || _secondsRemaining <= 0) return 3;
    if (_secondsRemaining > 20) return 1;
    if (_secondsRemaining > 10) return 2;
    return 3;
  }

  // ── Matching stage helpers ─────────────────────────────────────────
  _MatchingStage _matchingStage(int seconds) {
    if (_matchedPro != null) {
      final name = _matchedPro!['providerName'] as String? ?? 'a pro';
      return _MatchingStage(
        label: 'Provider found',
        subtitle: '$name is on the way to your location.',
      );
    }
    if (seconds > 20) {
      return const _MatchingStage(
        label: 'Broadcasting request',
        subtitle: 'Alerting nearby active providers around your pin.',
      );
    }
    if (seconds > 10) {
      return const _MatchingStage(
        label: 'Checking availability',
        subtitle: 'Comparing who can reach you the fastest.',
      );
    }
    return const _MatchingStage(
      label: 'Final nearby sweep',
      subtitle: 'Running one last pass before the request times out.',
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
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: theme.primaryBackground,
        title: Text(
          'Cancel provider search?',
          style: theme.titleMedium.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        content: Text(
          'Your current search is still running. '
          'If you cancel now, you can adjust the booking details and try again.',
          style: theme.bodyMedium.override(color: theme.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Continue search',
              style: theme.bodyMedium.override(
                fontWeight: FontWeight.w600,
                color: theme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _popClean();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Cancel search'),
          ),
        ],
      ),
    );
  }

  void _popClean() {
    final booking = context.read<BookingFlowController?>();
    booking?.setMatchingActive(true);
    booking?.setLiveSearchTimedOut(true);
    if (mounted) Navigator.of(context).pop();
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingFlowController?>();
    final draft = booking?.draft;
    final location = LatLng(
      draft?.latitude ?? 14.5995,
      draft?.longitude ?? 120.9842,
    );
    final serviceTitle =
        widget.serviceTitle ?? draft?.serviceTitle ?? 'Service request';
    final stage = _matchingStage(_secondsRemaining);

    final bool showActive = !_timedOut && _matchedPro == null;

    return PopScope(
      canPop: _matchedPro != null || _timedOut,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBackOrCancel();
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
            if (_matchedPro != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: _MatchReveal(
                    controller: _matchRevealController,
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
    final theme = AppTheme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.12,
      maxChildSize: 0.82,
      snap: true,
      snapSizes: const [0.12, 0.38, 0.72],
      snapAnimationDuration: const Duration(milliseconds: 320),
      builder: (context, scrollController) {
        return Container(
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
                          ? _MatchedSheet(
                              scrollController: scrollController,
                              theme: theme,
                              pro: _matchedPro!,
                              addressLabel:
                                  draft?.address.label ?? 'Pinned location',
                              addressLine:
                                  '${draft?.address.line1 ?? 'Location loading'}${(draft?.address.city ?? '').isNotEmpty ? ', ${draft!.address.city}' : ''}',
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
                          : _SearchingSheet(
                              scrollController: scrollController,
                              theme: theme,
                              stageLabel: stage.label,
                              stageSubtitle: stage.subtitle,
                              addressLabel:
                                  draft?.address.label ?? 'Pinned location',
                              addressLine:
                                  '${draft?.address.line1 ?? 'Location loading'}${(draft?.address.city ?? '').isNotEmpty ? ', ${draft!.address.city}' : ''}',
                              referenceId: booking?.activeReferenceId,
                              secondsRemaining: _secondsRemaining,
                              gradientValue: _gradientController,
                              stageIndex: _currentStage(),
                              onCancel: _showCancelDialog,
                            ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Matching stage model
// ────────────────────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
          (i == 0 ? 0.55 : i == 1 ? 0.38 : 0.22);

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

class _MatchReveal extends StatelessWidget {
  const _MatchReveal({
    required this.controller,
    required this.theme,
  });

  final AnimationController controller;
  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final scale = 1.0 + (1.0 - t) * 0.15;
        final opacity = t;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  color: theme.primaryBackground.withValues(alpha: 0.94),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.success.withValues(alpha: 0.30),
                      blurRadius: 28,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 58,
                  color: theme.success,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
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
                        'Assigned',
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
                isMatched ? 'Provider assigned' : 'Finding the nearest provider',
                style: theme.titleMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
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
                  progress: secondsRemaining / 30,
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
      color1: Color(0xFF368EFF),
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gradientValue,
      builder: (context, _) {
        final t = gradientValue.isAnimating
            ? gradientValue.value
            : 1.0;

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
  });

  final ScrollController scrollController;
  final AppThemeData theme;
  final String stageLabel;
  final String stageSubtitle;
  final String addressLabel;
  final String addressLine;
  final VoidCallback onCancel;
  final String? referenceId;
  final int secondsRemaining;
  final Animation<double> gradientValue;
  final int stageIndex;

  @override
  Widget build(BuildContext context) {
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
          progress: secondsRemaining / 30,
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
          'Searching nearby providers',
          style: theme.titleMedium.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Stay on this screen while we look for the closest available professional.',
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
            title: 'Search reference',
            subtitle: referenceId!,
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.alternate),
              foregroundColor: theme.secondaryText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Cancel search'),
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
    final name = pro['providerName'] as String? ?? 'Professional';
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
                  Icons.check_circle_rounded,
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
                      'Provider found',
                      style: theme.labelLarge.override(
                        color: theme.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'A professional has been assigned to your request.',
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
                    ? Icon(Icons.person_rounded,
                        size: 30, color: theme.primary)
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
                label: 'ETA',
                value: '$etaMinutes min',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MatchedInfoTile(
                theme: theme,
                icon: Icons.near_me_rounded,
                label: 'Distance',
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
            title: 'Reference',
            subtitle: referenceId!,
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onBackHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              'Back to Home',
              style: theme.titleMedium.override(
                color: Colors.white,
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
  Widget build(BuildContext context) {
    return Container(
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
        Icon(Icons.timer_off_rounded,
            size: 48, color: theme.secondaryText),
        const SizedBox(height: 12),
        Text(
          'Providers are busy, try again',
          textAlign: TextAlign.center,
          style: theme.titleMedium.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can adjust the booking details and retry, or head back home for now.',
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onAdjustBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Adjust booking'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: onBackHome,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.alternate),
              foregroundColor: theme.secondaryText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Back home'),
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
  Widget build(BuildContext context) {
    return Row(
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
}
