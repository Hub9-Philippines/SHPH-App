import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/theme/app_theme.dart';

const double _kDefaultMapVisibleFraction = 0.42;
const double _kDefaultSheetMaxFraction = 0.64;
const double _kMinimumMapHeight = 220;

class BookingStatusScaffold extends StatefulWidget {
  const BookingStatusScaffold({
    required this.location,
    required this.bottomSheet,
    this.topCard,
    this.center,
    this.showMap = true,
    this.markerHue = BitmapDescriptor.hueRed,
    this.markers,
    this.polylines,
    this.isDraggable = false,
    this.mapVisibleFraction = _kDefaultMapVisibleFraction,
    this.sheetMaxFraction = _kDefaultSheetMaxFraction,
    this.sheetInitialFraction = 0.35,
    this.sheetMinFraction = 0.12,
    this.sheetMaxDraggableFraction = 0.75,
    this.onMapCreated,
    super.key,
  });

  final LatLng location;
  final Widget? topCard;
  final Widget bottomSheet;
  final Widget? center;
  final bool showMap;
  final double markerHue;
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final bool isDraggable;
  final double mapVisibleFraction;
  final double sheetMaxFraction;
  final double sheetInitialFraction;
  final double sheetMinFraction;
  final double sheetMaxDraggableFraction;
  final void Function(GoogleMapController)? onMapCreated;

  @override
  State<BookingStatusScaffold> createState() => _BookingStatusScaffoldState();
}

class _BookingStatusScaffoldState extends State<BookingStatusScaffold> {
  Set<Marker>? _markers;
  Set<Polyline>? _polylines;

  @override
  void initState() {
    super.initState();
    _markers = widget.markers;
    _polylines = widget.polylines;
  }

  @override
  void didUpdateWidget(covariant BookingStatusScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.markers != oldWidget.markers) {
      _markers = widget.markers;
    }
    if (widget.polylines != oldWidget.polylines) {
      _polylines = widget.polylines;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapHeight = (constraints.maxHeight * widget.mapVisibleFraction)
              .clamp(_kMinimumMapHeight, constraints.maxHeight);
          final sheetMaxHeight = constraints.maxHeight * widget.sheetMaxFraction;

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryBackground,
                        theme.secondaryBackground,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: mapHeight,
                child: widget.showMap
                    ? ClipRect(
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: widget.location,
                            zoom: 16,
                          ),
                          zoomControlsEnabled: false,
                          compassEnabled: false,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                          rotateGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          scrollGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          padding: EdgeInsets.only(bottom: 48 + bottomInset),
                          markers: widget.markers ??
                            {
                              Marker(
                                markerId: const MarkerId('booking_location'),
                                position: widget.location,
                                anchor: const Offset(0.5, 1),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  widget.markerHue,
                                ),
                              ),
                            },
                          polylines: widget.polylines ?? const {},
                          onMapCreated: widget.onMapCreated,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (widget.center != null) Center(child: widget.center!),
              if (widget.isDraggable)
                _DraggableBottomSheet(
                  child: widget.bottomSheet,
                  initialFraction: widget.sheetInitialFraction,
                  minFraction: widget.sheetMinFraction,
                  maxFraction: widget.sheetMaxDraggableFraction,
                )
              else
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: sheetMaxHeight),
                    child: widget.bottomSheet,
                  ),
                ),
              if (widget.topCard != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: widget.topCard!,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DraggableBottomSheet extends StatelessWidget {
  const _DraggableBottomSheet({
    required this.child,
    this.initialFraction = 0.35,
    this.minFraction = 0.12,
    this.maxFraction = 0.75,
  });

  final Widget child;
  final double initialFraction;
  final double minFraction;
  final double maxFraction;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: initialFraction,
      minChildSize: minFraction,
      maxChildSize: maxFraction,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.primaryBackground.withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            children: [child],
          ),
        ),
      ),
    );
  }
}

class BookingStatusBottomSheet extends StatelessWidget {
  const BookingStatusBottomSheet({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }
}
