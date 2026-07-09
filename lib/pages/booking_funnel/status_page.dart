import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/main.dart';
import '/theme/app_theme.dart';
import 'widgets/booking_status_scaffold.dart';

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
  late final AnimationController _pulseController;

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

  int get _activeStageIndex {
    final status = widget.bookingStatus.toLowerCase();
    if (status == 'booking cancelled' || status == 'cancelled') {
      return -1;
    }
    if (status == 'completed') {
      return _stages.length - 1;
    }
    if (status == 'in progress' || status == 'in_progress') {
      return 3;
    }
    if (status == 'on site' || status == 'arrived') {
      return 2;
    }
    if (status == 'en route' || status == 'booking confirmed') {
      return 1;
    }
    return 0;
  }

  bool get _isTerminal =>
      widget.bookingStatus.toLowerCase() == 'completed' ||
      widget.bookingStatus.toLowerCase() == 'booking cancelled' ||
      widget.bookingStatus.toLowerCase() == 'cancelled';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!_isTerminal) {
      _pulseController.repeat(reverse: true);
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
    super.dispose();
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (widget.clientLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('client_location'),
          position: widget.clientLocation!,
          anchor: const Offset(0.5, 1),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }
    if (widget.providerLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('provider_location'),
          position: widget.providerLocation!,
          anchor: const Offset(0.5, 1),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final location = widget.clientLocation ??
        widget.providerLocation ??
        const LatLng(14.5995, 120.9842);

    final scaffold = BookingStatusScaffold(
      location: location,
      showMap: true,
      markerHue: BitmapDescriptor.hueAzure,
      markers: _buildMarkers(),
      isDraggable: true,
      topCard: _StatusTopBar(
        status: widget.bookingStatus,
        serviceTitle: widget.serviceTitle,
        providerName: widget.providerName,
        providerPhoto: widget.providerPhoto,
        theme: theme,
      ),
      bottomSheet: _StatusSheetContent(
        stages: _stages,
        activeStageIndex: _activeStageIndex,
        pulseValue: _pulseController,
        isTerminal: _isTerminal,
        providerName: widget.providerName,
        status: widget.bookingStatus,
        bookingDate: widget.bookingDate,
        bookingReference: widget.bookingReference,
        theme: theme,
      ),
    );

    if (!widget.shouldPopToHome) return scaffold;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
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
      },
      child: scaffold,
    );
  }
}

class _StatusTopBar extends StatelessWidget {
  const _StatusTopBar({
    required this.status,
    required this.serviceTitle,
    required this.providerName,
    required this.theme,
    this.providerPhoto,
  });

  final String status;
  final String serviceTitle;
  final String providerName;
  final String? providerPhoto;
  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isTerminal = status.toLowerCase() == 'completed' ||
        status.toLowerCase() == 'booking cancelled' ||
        status.toLowerCase() == 'cancelled';

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.primaryBackground.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.primary.withValues(alpha: 0.12),
                backgroundImage: providerPhoto != null &&
                        providerPhoto!.trim().isNotEmpty
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleSmall.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTerminal ? 'Booking $status' : 'Booking in progress',
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
      ),
    );
  }
}

class _StatusSheetContent extends StatelessWidget {
  const _StatusSheetContent({
    required this.stages,
    required this.activeStageIndex,
    required this.pulseValue,
    required this.isTerminal,
    required this.providerName,
    required this.status,
    required this.bookingDate,
    required this.theme,
    this.bookingReference,
  });

  final List<_BookingStage> stages;
  final int activeStageIndex;
  final Animation<double> pulseValue;
  final bool isTerminal;
  final String providerName;
  final String status;
  final DateTime bookingDate;
  final String? bookingReference;
  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    final title = serviceTitleFromStatus(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 18),
        Text(
          title,
          style: theme.titleMedium.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 4),
        if (isTerminal)
          Text(
            'This booking has been ${status.toLowerCase()}.',
            style: theme.bodySmall.override(color: theme.secondaryText),
          )
        else
          Text(
            'Tracking $providerName\'s progress',
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
        const SizedBox(height: 20),
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
      ],
    );
  }

  String serviceTitleFromStatus(String s) {
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
                      if (_isActive && !isTerminal && stage.estimatedMinutes != null)
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
                        ? '${stage.description}…'
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
