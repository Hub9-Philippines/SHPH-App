import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/main.dart';
import '/theme/app_theme.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({
    required this.bookingStatus,
    required this.bookingDate,
    required this.providerName,
    required this.serviceTitle,
    this.clientLocation,
    this.providerLocation,
    this.providerPhoto,
    this.bookingReference,
    this.shouldPopToHome = false,
    super.key,
  });

  final String bookingStatus;
  final DateTime bookingDate;
  final String providerName;
  final String serviceTitle;
  final LatLng? clientLocation;
  final LatLng? providerLocation;
  final String? providerPhoto;
  final String? bookingReference;
  final bool shouldPopToHome;

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage>
    with TickerProviderStateMixin {
  static const double _collapsedSheetExtent = 0.30;
  static const double _expandedSheetExtent = 0.55;

  late final AnimationController _pulseController;

  GoogleMapController? _mapController;
  Timer? _movementTimer;
  Timer? _statusTimer;
  double _bottomSheetExtent = _collapsedSheetExtent;
  bool _mapReady = false;

  LatLng _currentProviderLocation = const LatLng(14.5995, 120.9842);
  String _currentStatus = '';
  int _etaSeconds = 0;

  List<LatLng> _routeWaypoints = [];
  int _currentWaypointIndex = 0;
  final Set<Polyline> _polylines = {};

  bool get _isTerminal {
    final s = _currentStatus.toLowerCase();
    return s == 'completed' ||
        s == 'booking cancelled' ||
        s == 'cancelled';
  }

  int get _activeStageIndex => _stageIndexForStatus(_currentStatus);

  static const _stages = <_BookingStage>[
    _BookingStage(
      key: 'confirmed',
      label: 'Confirmed',
      description: 'Provider has accepted your booking',
      icon: Icons.check_circle_outline_rounded,
      estimatedMinutes: 2,
    ),
    _BookingStage(
      key: 'en_route',
      label: 'Provider En Route',
      description: 'Heading to your location',
      icon: Icons.near_me_rounded,
      estimatedMinutes: 15,
    ),
    _BookingStage(
      key: 'on_site',
      label: 'On Site',
      description: 'Provider has arrived at your location',
      icon: Icons.location_on_rounded,
      estimatedMinutes: 5,
    ),
    _BookingStage(
      key: 'in_progress',
      label: 'Service In Progress',
      description: 'Provider is working on your request',
      icon: Icons.build_circle_rounded,
      estimatedMinutes: 30,
    ),
    _BookingStage(
      key: 'completed',
      label: 'Completed',
      description: 'Service has been completed',
      icon: Icons.task_alt_rounded,
      estimatedMinutes: null,
    ),
  ];

  int _stageIndexForStatus(String s) {
    final lower = s.toLowerCase();
    if (lower == 'booking cancelled' || lower == 'cancelled') return -1;
    if (lower == 'completed') return _stages.length - 1;
    if (lower == 'in progress' || lower == 'in_progress') return 3;
    if (lower == 'on site' || lower == 'arrived') return 2;
    if (lower == 'en route' || lower == 'booking confirmed') return 1;
    return 0;
  }

  LatLng get _clientLocation =>
      widget.clientLocation ?? const LatLng(14.5995, 120.9842);

  double _distanceToClient(LatLng from) {
    const r = 6371.0;
    final dLat = _toRadians(_clientLocation.latitude - from.latitude);
    final dLon = _toRadians(_clientLocation.longitude - from.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(from.latitude)) *
            math.cos(_toRadians(_clientLocation.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _toRadians(double deg) => deg * math.pi / 180;

  @override
  void initState() {
    super.initState();
    _currentProviderLocation =
        widget.providerLocation ?? const LatLng(14.5995, 120.9842);
    _currentStatus = widget.bookingStatus;
    _etaSeconds = _etaForStatus(_currentStatus);

    _generateRouteWaypoints();
    _buildPolyline();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!_isTerminal) {
      _pulseController.repeat(reverse: true);
    }

    _startRealtimeSimulation();
  }

  void _generateRouteWaypoints() {
    final start = widget.providerLocation;
    final end = _clientLocation;
    if (start == null) {
      _routeWaypoints = [end];
      return;
    }

    const count = 30;
    _routeWaypoints = [start];

    final dx = end.longitude - start.longitude;
    final dy = end.latitude - start.latitude;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-8) {
      _routeWaypoints = [start, end];
      return;
    }

    final perpX = -dy / len;
    final perpY = dx / len;
    final distKm = _distanceToClient(start);
    final curveAmount = (distKm * 0.003).clamp(0.002, 0.02);

    final ctrlLat =
        (start.latitude + end.latitude) / 2 + perpY * curveAmount;
    final ctrlLng =
        (start.longitude + end.longitude) / 2 + perpX * curveAmount;

    for (int i = 1; i <= count; i++) {
      final t = i / count;
      final inv = 1 - t;
      final lat =
          inv * inv * start.latitude + 2 * inv * t * ctrlLat + t * t * end.latitude;
      final lng =
          inv * inv * start.longitude + 2 * inv * t * ctrlLng + t * t * end.longitude;
      _routeWaypoints.add(LatLng(lat, lng));
    }
  }

  void _buildPolyline() {
    if (_routeWaypoints.length < 2) return;
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routeWaypoints,
        color: AppTheme.of(context).primary,
        width: 5,
        jointType: JointType.round,
      ),
    );
  }

  void _startRealtimeSimulation() {
    if (_routeWaypoints.length < 2 || _isTerminal) return;

    _currentWaypointIndex = 0;
    _currentProviderLocation = _routeWaypoints[0];

    _movementTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentWaypointIndex++;
        if (_currentWaypointIndex >= _routeWaypoints.length - 1) {
          _currentProviderLocation = _routeWaypoints.last;
          timer.cancel();
        } else {
          _currentProviderLocation =
              _routeWaypoints[_currentWaypointIndex];
        }
      });

      _updateStatusBasedOnDistance();
      _etaSeconds = math.max(0, _etaSeconds - 1);
      _scheduleBoundsUpdate();
    });
  }

  void _updateStatusBasedOnDistance() {
    final distKm = _distanceToClient(_currentProviderLocation);
    final current = _currentStatus.toLowerCase();

    String newStatus;
    if (distKm < 0.05) {
      newStatus = current == 'in_progress' || current == 'completed'
          ? current
          : 'on_site';
    } else if (distKm < 0.5) {
      newStatus = 'on_site';
    } else {
      newStatus = 'en_route';
    }

    if (newStatus != _currentStatus) {
      setState(() => _currentStatus = newStatus);
      _etaSeconds = _etaForStatus(newStatus);
    }
  }

  int _etaForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'en_route':
        return 900; // 15 min
      case 'on_site':
        return 300; // 5 min
      case 'in_progress':
        return 1800; // 30 min
      default:
        return 0;
    }
  }

  void _scheduleBoundsUpdate() {
    if (_mapReady && _mapController != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          math.min(_clientLocation.latitude, _currentProviderLocation.latitude),
          math.min(_clientLocation.longitude, _currentProviderLocation.longitude),
        ),
        northeast: LatLng(
          math.max(_clientLocation.latitude, _currentProviderLocation.latitude),
          math.max(_clientLocation.longitude, _currentProviderLocation.longitude),
        ),
      );
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  @override
  void didUpdateWidget(covariant StatusPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isTerminal && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    } else if (!_isTerminal && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _movementTimer?.cancel();
    _statusTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
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

  double _dynamicMaxSheetExtent(double availableHeight) {
    return _expandedSheetExtent;
  }

  bool _handleSheetNotification(DraggableScrollableNotification n) {
    if ((n.extent - _bottomSheetExtent).abs() < 0.002) return false;
    setState(() => _bottomSheetExtent = n.extent);
    _scheduleBoundsUpdate();
    return false;
  }

  Widget _buildSheet(ScrollController scrollController) {
    final theme = AppTheme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return _StatusSheetContainer(
      scrollController: scrollController,
      theme: theme,
      stages: _stages,
      activeStageIndex: _activeStageIndex,
      pulseValue: _pulseController,
      isTerminal: _isTerminal,
      providerName: widget.providerName,
      status: _currentStatus,
      bookingDate: widget.bookingDate,
      bookingReference: widget.bookingReference,
      etaSeconds: _etaSeconds,
      distanceKm: _distanceToClient(_currentProviderLocation),
      bottomInset: bottomPadding,
      onBackToHome: widget.shouldPopToHome ? _goHome : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    final scaffold = Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          _StatusTopBar(
            providerName: widget.providerName,
            providerPhoto: widget.providerPhoto,
            status: _currentStatus,
            serviceTitle: widget.serviceTitle,
            theme: theme,
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
                  bottom: constraints.maxHeight * currentSheetExtent +
                      bottomPadding +
                      24,
                );

                return NotificationListener<
                    DraggableScrollableNotification>(
                  onNotification: _handleSheetNotification,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _clientLocation,
                            zoom: 14,
                          ),
                          padding: mapPadding,
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                          markers: {
                            Marker(
                              markerId:
                                  const MarkerId('client_location'),
                              position: _clientLocation,
                              anchor: const Offset(0.5, 1),
                              icon: BitmapDescriptor
                                  .defaultMarkerWithHue(
                                BitmapDescriptor.hueAzure,
                              ),
                            ),
                            Marker(
                              markerId:
                                  const MarkerId('provider_location'),
                              position: _currentProviderLocation,
                              anchor: const Offset(0.5, 1),
                              icon: BitmapDescriptor
                                  .defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen,
                              ),
                            ),
                          },
                          polylines: _polylines,
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
                                _buildSheet(scrollController),
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

    if (!widget.shouldPopToHome) return scaffold;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: scaffold,
    );
  }
}

class _StatusTopBar extends StatelessWidget {
  const _StatusTopBar({
    required this.providerName,
    required this.status,
    required this.serviceTitle,
    required this.theme,
    this.providerPhoto,
  });

  final String providerName;
  final String? providerPhoto;
  final String status;
  final String serviceTitle;
  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isTerminal = status.toLowerCase() == 'completed' ||
        status.toLowerCase() == 'booking cancelled' ||
        status.toLowerCase() == 'cancelled';

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
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.primary.withValues(alpha: 0.10),
              backgroundImage:
                  providerPhoto != null && providerPhoto!.trim().isNotEmpty
                      ? NetworkImage(providerPhoto!)
                      : null,
              child: providerPhoto == null || providerPhoto!.trim().isEmpty
                  ? Icon(Icons.person_rounded, color: theme.primary)
                  : null,
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
                        status: status,
                        theme: theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isTerminal
                        ? 'Booking $status'
                        : 'Tracking progress of $providerName',
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

class _BookingStatusChip extends StatelessWidget {
  const _BookingStatusChip({
    required this.status,
    required this.theme,
  });

  final String status;
  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final Color bg;
    final Color fg;
    final String label;

    if (lower == 'completed') {
      bg = const Color(0xFF16A34A).withValues(alpha: 0.12);
      fg = const Color(0xFF16A34A);
      label = 'Completed';
    } else if (lower == 'en route' || lower == 'booking confirmed') {
      bg = theme.primary.withValues(alpha: 0.12);
      fg = theme.primary;
      label = 'En Route';
    } else if (lower == 'on site' || lower == 'arrived') {
      bg = const Color(0xFFE65100).withValues(alpha: 0.12);
      fg = const Color(0xFFE65100);
      label = 'On Site';
    } else if (lower == 'in progress' || lower == 'in_progress') {
      bg = const Color(0xFF7B1FA2).withValues(alpha: 0.12);
      fg = const Color(0xFF7B1FA2);
      label = 'In Progress';
    } else if (lower == 'cancelled' || lower == 'booking cancelled') {
      bg = const Color(0xFFDC2626).withValues(alpha: 0.12);
      fg = const Color(0xFFDC2626);
      label = 'Cancelled';
    } else {
      bg = theme.secondaryText.withValues(alpha: 0.12);
      fg = theme.secondaryText;
      label = 'Confirmed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.labelSmall.override(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _StatusSheetContainer extends StatelessWidget {
  const _StatusSheetContainer({
    required this.scrollController,
    required this.theme,
    required this.stages,
    required this.activeStageIndex,
    required this.pulseValue,
    required this.isTerminal,
    required this.providerName,
    required this.status,
    required this.bookingDate,
    required this.etaSeconds,
    required this.distanceKm,
    required this.bottomInset,
    this.bookingReference,
    this.onBackToHome,
  });

  final ScrollController scrollController;
  final AppThemeData theme;
  final List<_BookingStage> stages;
  final int activeStageIndex;
  final Animation<double> pulseValue;
  final bool isTerminal;
  final String providerName;
  final String status;
  final DateTime bookingDate;
  final int etaSeconds;
  final double distanceKm;
  final double bottomInset;
  final String? bookingReference;
  final VoidCallback? onBackToHome;

  @override
  Widget build(BuildContext context) {
    final title = _serviceTitleFromStatus(status);

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
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.track_changes_rounded,
                        size: 20, color: theme.primary),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: theme.titleMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (!isTerminal) ...[
                  Text(
                    '${distanceKm.toStringAsFixed(1)} km away',
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                  if (etaSeconds > 0)
                    Text(
                      'Approximately ${_formatEta(etaSeconds)}',
                      style: theme.bodySmall.override(
                        color: theme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ] else
                  Text(
                    'This booking has been ${status.toLowerCase()}.',
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                    ),
                  ),
                const SizedBox(height: 16),
                ...List.generate(stages.length, (i) => _StageRow(
                  stage: stages[i],
                  stageCount: stages.length,
                  index: i,
                  activeIndex: activeStageIndex,
                  pulseValue: pulseValue,
                  isTerminal: isTerminal,
                  theme: theme,
                )),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        theme: theme,
                        icon: Icons.calendar_today_rounded,
                        label: 'Booking date',
                        value:
                            '${bookingDate.month}/${bookingDate.day}/${bookingDate.year}',
                      ),
                      if ((bookingReference ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          theme: theme,
                          icon: Icons.tag_rounded,
                          label: 'Reference',
                          value: bookingReference!,
                        ),
                      ],
                    ],
                  ),
                ),
                if (onBackToHome != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onBackToHome,
                      icon: const Icon(Icons.home_rounded, size: 18),
                      label: const Text('Back to Home'),
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatEta(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return '${h}h ${m}min';
    }
    return '${minutes}min';
  }

  String _serviceTitleFromStatus(String s) {
    final lower = s.toLowerCase();
    if (lower == 'completed') return 'Service Completed';
    if (lower == 'booking cancelled' || lower == 'cancelled') {
      return 'Booking Cancelled';
    }
    return 'Service In Progress';
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.stageCount,
    required this.index,
    required this.activeIndex,
    required this.pulseValue,
    required this.isTerminal,
    required this.theme,
  });

  final _BookingStage stage;
  final int stageCount;
  final int index;
  final int activeIndex;
  final Animation<double> pulseValue;
  final bool isTerminal;
  final AppThemeData theme;

  bool get _isCompleted => index < activeIndex;
  bool get _isActive => index == activeIndex;

  @override
  Widget build(BuildContext context) {
    final dotColor = _isCompleted
        ? const Color(0xFF16A34A)
        : _isActive
            ? theme.primary
            : theme.alternate;
    final textColor = _isCompleted || _isActive
        ? theme.primaryText
        : theme.secondaryText.withValues(alpha: 0.5);
    final descColor = _isCompleted || _isActive
        ? theme.secondaryText
        : theme.secondaryText.withValues(alpha: 0.35);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                _isActive && !isTerminal
                    ? AnimatedBuilder(
                        animation: pulseValue,
                        builder: (context, _) {
                          final size = 22 + pulseValue.value * 8;
                          return Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: dotColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: _isCompleted ? 22 : 14,
                        height: _isCompleted ? 22 : 14,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                        child: _isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                if (index < stageCount - 1)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _isCompleted
                          ? const Color(0xFF16A34A)
                          : theme.alternate,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        stage.label,
                        style: theme.bodyMedium.override(
                          fontWeight: FontWeight.w700,
                          color: _isActive && !isTerminal
                              ? theme.primary
                              : textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isActive &&
                          !isTerminal &&
                          stage.estimatedMinutes != null)
                        _EtaChip(
                          minutes: stage.estimatedMinutes!,
                          theme: theme,
                        ),
                      if (_isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isActive && !isTerminal
                        ? '${stage.description}â€¦'
                        : stage.description,
                    style: theme.bodySmall.override(color: descColor),
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

class _EtaChip extends StatelessWidget {
  const _EtaChip({
    required this.minutes,
    required this.theme,
  });

  final int minutes;
  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 11, color: theme.primary),
          const SizedBox(width: 4),
          Text(
            '~${minutes}min',
            style: theme.labelSmall.override(
              color: theme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: theme.secondaryText),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.bodySmall.override(
              color: theme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.bodySmall.override(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
}

class _BookingStage {
  const _BookingStage({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    this.estimatedMinutes,
  });

  final String key;
  final String label;
  final String description;
  final IconData icon;
  final int? estimatedMinutes;
}
