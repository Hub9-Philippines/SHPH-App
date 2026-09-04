import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/api/resources/bookings_api.dart';
import '/flutter_flow/flutter_flow_util.dart' hide LatLng;
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/main.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/user_avatar.dart';
import '/services/logging_service.dart';
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

  /// Optional SHPH booking id. When present the screen polls the real booking
  /// status from the API instead of advancing through a fabricated timeline.
  final String? bookingReference;
  final bool shouldPopToHome;

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage>
    with TickerProviderStateMixin {
  /// The bottom card is a fixed, non-collapsible anchor at 45% of the
  /// viewport height (spec: map-tracking-screen / non-collapsible sheet).
  static const double _sheetHeightFactor = 0.45;

  late final AnimationController _pulseController;

  GoogleMapController? _mapController;
  Timer? _statusPollTimer;
  bool _mapReady = false;

  LatLng _currentProviderLocation = const LatLng(14.5995, 120.9842);
  String _currentStatus = '';
  int _etaSeconds = 0;

  final Set<Polyline> _polylines = {};

  static const int _kStageCount = 5;

  List<_BookingStage> _buildStages(AppLocalizations l10n) => [
        _BookingStage(
          key: 'confirmed',
          label: l10n.bfStatusConfirmed,
          description: l10n.bfProviderAcceptedBooking,
          icon: Icons.check_circle_outline_rounded,
          estimatedMinutes: 2,
        ),
        _BookingStage(
          key: 'en_route',
          label: l10n.bfEnRoute,
          description: l10n.bfHeadingToLocation,
          icon: Icons.near_me_rounded,
          estimatedMinutes: 15,
        ),
        _BookingStage(
          key: 'on_site',
          label: l10n.bfOnSite,
          description: l10n.bfProviderArrived,
          icon: Icons.location_on_rounded,
          estimatedMinutes: 5,
        ),
        _BookingStage(
          key: 'in_progress',
          label: l10n.bfInProgress,
          description: l10n.bfProviderWorking,
          icon: Icons.build_circle_rounded,
          estimatedMinutes: 30,
        ),
        _BookingStage(
          key: 'completed',
          label: l10n.bfStatusCompleted,
          description: l10n.bfServiceCompleted,
          icon: Icons.task_alt_rounded,
          estimatedMinutes: null,
        ),
      ];

  bool get _isTerminal {
    final s = _currentStatus.toLowerCase();
    return s == 'completed' ||
        s == 'booking cancelled' ||
        s == 'cancelled';
  }

  bool get _isCompleted => _currentStatus.toLowerCase() == 'completed';

  int get _activeStageIndex => _stageIndexForStatus(_currentStatus);

  int _stageIndexForStatus(String s) {
    final lower = s.toLowerCase();
    if (lower == 'booking cancelled' || lower == 'cancelled') return -1;
    if (lower == 'completed') return _kStageCount - 1;
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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!_isTerminal) {
      _pulseController.repeat(reverse: true);
    }

    _startStatusPolling();
  }

  /// Polls the real booking record when a booking id is available. When none
  /// is provided the screen reflects only the caller-supplied status — it no
  /// longer advances through a fabricated timeline.
  void _startStatusPolling() {
    final bookingId = widget.bookingReference;
    if (bookingId == null || bookingId.isEmpty) {
      return;
    }

    Future<void> poll() async {
      if (!mounted) return;
      try {
        final booking = await ShphBookingsApi.instance.getBooking(bookingId);
        if (!mounted) return;

        final newStatus = booking.status;
        if (newStatus.isNotEmpty && newStatus != _currentStatus) {
          setState(() {
            _currentStatus = newStatus;

            if (newStatus == 'completed') {
              _pulseController.stop();
              _pulseController.value = 0;
            }
            // The booking's service location is the client location; when the
            // provider is reported as on-site/arrived move it there.
            if ((newStatus == 'on_site' ||
                    newStatus == 'arrived' ||
                    newStatus == 'in_progress') &&
                booking.serviceLat != null &&
                booking.serviceLng != null) {
              _currentProviderLocation =
                  LatLng(booking.serviceLat!, booking.serviceLng!);
            }
          });
        }
      } catch (e) {
        LoggingService.debug(
          'Status poll failed: $e',
          tag: 'StatusPage',
          error: e,
        );
      }
    }

    _statusPollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      poll();
    });
    poll();
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
    _statusPollTimer?.cancel();
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

  void _handleBack() {
    if (widget.shouldPopToHome) {
      _goHome();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _goHome();
    }
  }

  void _openContact() {
    context.pushNamed(
      ContactProviderWidget.routeName,
      extra: <String, dynamic>{
        'providerName': widget.providerName,
        'providerPhoto': widget.providerPhoto,
        'isVerified': false,
      },
    );
  }

  void _writeReview() {
    final reference = widget.bookingReference;
    if (reference == null || reference.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.bfReviewAfterSync),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    context.pushNamed(
      WriteReviewWidget.routeName,
      pathParameters: {'bookingId': reference},
      extra: <String, dynamic>{'serviceName': widget.serviceTitle},
    );
  }

  void _viewInvoice() {
    // No invoice surface exists client-side yet (web-only endpoint); degrade
    // gracefully instead of dead-tapping.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.bfInvoiceSoon),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final sheetHeight =
        MediaQuery.sizeOf(context).height * _sheetHeightFactor;
    final stages = _buildStages(l10n);

    final scaffold = Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Stack(
        children: [
          // Full-bleed map canvas behind every overlay.
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _clientLocation,
                zoom: 14,
              ),
              padding: EdgeInsets.only(bottom: sheetHeight + bottomPadding),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('client_location'),
                  position: _clientLocation,
                  anchor: const Offset(0.5, 1),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('provider_location'),
                  position: _currentProviderLocation,
                  anchor: const Offset(0.5, 1),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
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

          // Floating back + home buttons — top-left over the map.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FloatingCircleButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: l10n.bfBack,
                    onTap: _handleBack,
                  ),
                  const SizedBox(width: 10),
                  _FloatingCircleButton(
                    icon: Icons.home_rounded,
                    tooltip: l10n.bfHome,
                    onTap: _goHome,
                  ),
                ],
              ),
            ),
          ),

          // Floating provider card — near the top-center of the map.
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(116, 16, 16, 0),
                child: _ProviderCard(
                  providerName: widget.providerName,
                  providerPhoto: widget.providerPhoto,
                  status: _currentStatus,
                  serviceTitle: widget.serviceTitle,
                  onContact: _openContact,
                ),
              ),
            ),
          ),

          // Fixed, non-collapsible bottom sheet at 45% of the viewport.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _TrackingSheet(
              height: sheetHeight,
              bottomInset: bottomPadding,
              theme: theme,
              l10n: l10n,
              stages: stages,
              activeStageIndex: _activeStageIndex,
              pulseValue: _pulseController,
              isTerminal: _isTerminal,
              isCompleted: _isCompleted,
              providerName: widget.providerName,
              status: _currentStatus,
              bookingDate: widget.bookingDate,
              bookingReference: widget.bookingReference,
              etaSeconds: _etaSeconds,
              distanceKm: _distanceToClient(_currentProviderLocation),
              serviceTitle: widget.serviceTitle,
              onWriteReview: _writeReview,
              onViewInvoice: _viewInvoice,
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

class _FloatingCircleButton extends StatelessWidget {
  const _FloatingCircleButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.primaryBackground,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 24, color: theme.primaryText),
          ),
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.providerName,
    required this.status,
    required this.serviceTitle,
    required this.onContact,
    this.providerPhoto,
  });

  final String providerName;
  final String status;
  final String serviceTitle;
  final VoidCallback onContact;
  final String? providerPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        boxShadow: AppThemeData.shadowCard,
      ),
      child: Row(
        children: [
          UserAvatar(photoUrl: providerPhoto, name: providerName, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        providerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _BookingStatusChip(status: status, theme: theme),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  serviceTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.labelSmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _MapActionButton(
            icon: Icons.call_rounded,
            tooltip: l10n.bfCall,
            onTap: onContact,
          ),
          const SizedBox(width: 6),
          _MapActionButton(
            icon: Icons.chat_bubble_rounded,
            tooltip: l10n.bfMessage,
            onTap: onContact,
          ),
        ],
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.primary.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 18, color: theme.primary),
          ),
        ),
      ),
    );
  }
}

// SHEET_PLACEHOLDER

class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({
    required this.height,
    required this.bottomInset,
    required this.theme,
    required this.l10n,
    required this.stages,
    required this.activeStageIndex,
    required this.pulseValue,
    required this.isTerminal,
    required this.isCompleted,
    required this.providerName,
    required this.status,
    required this.bookingDate,
    required this.etaSeconds,
    required this.distanceKm,
    required this.serviceTitle,
    required this.onWriteReview,
    required this.onViewInvoice,
    this.bookingReference,
  });

  final double height;
  final double bottomInset;
  final AppThemeData theme;
  final AppLocalizations l10n;
  final List<_BookingStage> stages;
  final int activeStageIndex;
  final Animation<double> pulseValue;
  final bool isTerminal;
  final bool isCompleted;
  final String providerName;
  final String status;
  final DateTime bookingDate;
  final int etaSeconds;
  final double distanceKm;
  final String serviceTitle;
  final String? bookingReference;
  final VoidCallback onWriteReview;
  final VoidCallback onViewInvoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppThemeData.shadowCard,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes_rounded,
                    size: 20, color: theme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    serviceTitle,
                    style: theme.titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700),
                      color: theme.primaryText,
                    ),
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
                  l10n.bfApproxEta(_formatEta(etaSeconds)),
                  style: theme.bodySmall.override(
                    color: theme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ] else
              Text(
                l10n.bfBookingStatusText(status.toLowerCase()),
                style: theme.bodySmall.override(
                  color: theme.secondaryText,
                ),
              ),
            const SizedBox(height: AppThemeData.spaceLg),
            ...List.generate(stages.length, (i) => _StageRow(
              stage: stages[i],
              stageCount: stages.length,
              index: i,
              activeIndex: activeStageIndex,
              pulseValue: pulseValue,
              isTerminal: isTerminal,
              theme: theme,
            )),
            const SizedBox(height: AppThemeData.spaceLg),
            Wrap(
              spacing: AppThemeData.spaceSm,
              runSpacing: AppThemeData.spaceSm,
              children: [
                _InfoBadge(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.bfBookingDate,
                  value:
                      '${bookingDate.month}/${bookingDate.day}/${bookingDate.year}',
                ),
                if ((bookingReference ?? '').isNotEmpty)
                  _InfoBadge(
                    icon: Icons.tag_rounded,
                    label: l10n.bfReference,
                    value: bookingReference!.length > 8
                        ? bookingReference!.substring(0, 8).toUpperCase()
                        : bookingReference!,
                  ),
              ],
            ),
            if (isCompleted) ...[
              const SizedBox(height: AppThemeData.spaceLg),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: AppButton(
                  onPressed: onWriteReview,
                  backgroundColor: AppThemeData.successBrand,
                  foregroundColor: Colors.white,
                  borderRadius: AppThemeData.radiusMd,
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.rate_review_rounded,
                          size: 19, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        l10n.bfWriteAReview,
                        style: theme.titleSmall.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: AppButton(
                  onPressed: onViewInvoice,
                  variant: AppButtonVariant.text,
                  foregroundColor: theme.primary,
                  child: Text(
                    l10n.bfViewInvoice,
                    style: theme.labelLarge.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
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
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surfaceAlt,
        borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.secondaryText),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.labelSmall.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.labelSmall.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              color: theme.primaryText,
            ),
          ),
        ],
      ),
    );
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
                        // The one and only checkmark for a completed stage.
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
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isActive && !isTerminal
                        ? '${stage.description}�'
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
    final lower = status.toLowerCase();
    final Color bg;
    final Color fg;
    final String label;

    if (lower == 'completed') {
      bg = const Color(0xFF16A34A).withValues(alpha: 0.12);
      fg = const Color(0xFF16A34A);
      label = l10n.bfStatusCompleted;
    } else if (lower == 'en route' || lower == 'booking confirmed') {
      bg = theme.primary.withValues(alpha: 0.12);
      fg = theme.primary;
      label = l10n.bfEnRoute;
    } else if (lower == 'on site' || lower == 'arrived') {
      bg = const Color(0xFFE65100).withValues(alpha: 0.12);
      fg = const Color(0xFFE65100);
      label = l10n.bfOnSite;
    } else if (lower == 'in progress' || lower == 'in_progress') {
      bg = const Color(0xFF7B1FA2).withValues(alpha: 0.12);
      fg = const Color(0xFF7B1FA2);
      label = l10n.bfInProgress;
    } else if (lower == 'cancelled' || lower == 'booking cancelled') {
      bg = const Color(0xFFDC2626).withValues(alpha: 0.12);
      fg = const Color(0xFFDC2626);
      label = l10n.bfStatusCancelled;
    } else {
      bg = theme.secondaryText.withValues(alpha: 0.12);
      fg = theme.secondaryText;
      label = l10n.bfStatusConfirmed;
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
