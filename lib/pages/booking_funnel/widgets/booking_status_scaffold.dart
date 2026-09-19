import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/components/map_radar_scan.dart';
import '/theme/app_theme.dart';

const double _kDefaultSheetMaxFraction = 0.64;

class BookingStatusScaffold extends StatelessWidget {
  const BookingStatusScaffold({
    required this.location,
    required this.bottomSheet,
    this.topCard,
    this.center,
    this.showMap = true,
    this.markerHue = BitmapDescriptor.hueRed,
    this.markers,
    this.radarScan,
    this.isDraggable = false,
    this.sheetMaxFraction = _kDefaultSheetMaxFraction,
    this.sheetInitialFraction = 0.35,
    this.sheetMinFraction = 0.12,
    this.sheetMaxDraggableFraction = 0.75,
    super.key,
  });

  final LatLng location;
  final Widget? topCard;
  final Widget bottomSheet;
  final Widget? center;
  final bool showMap;
  final double markerHue;
  final Set<Marker>? markers;

  /// Optional native radar ripple driven by a [RadarScanController]. When
  /// non-null the map is rebuilt per tick with fresh circle data only.
  final RadarScanController? radarScan;
  final bool isDraggable;
  final double sheetMaxFraction;
  final double sheetInitialFraction;
  final double sheetMinFraction;
  final double sheetMaxDraggableFraction;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sheetMaxHeight = constraints.maxHeight * sheetMaxFraction;

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
              Positioned.fill(
                child: showMap
                    ? _RadarMapLayer(
                        location: location,
                        markerHue: markerHue,
                        markers: markers,
                        radarScan: radarScan,
                        bottomInset: bottomInset,
                      )
                    : const SizedBox.shrink(),
              ),
              if (center != null) Center(child: center!),
              if (isDraggable)
                _DraggableBottomSheet(
                  child: bottomSheet,
                  initialFraction: sheetInitialFraction,
                  minFraction: sheetMinFraction,
                  maxFraction: sheetMaxDraggableFraction,
                )
              else
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: sheetMaxHeight),
                    child: bottomSheet,
                  ),
                ),
              if (topCard != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: topCard!,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RadarMapLayer extends StatelessWidget {
  const _RadarMapLayer({
    required this.location,
    required this.markerHue,
    required this.bottomInset,
    this.markers,
    this.radarScan,
  });

  final LatLng location;
  final double markerHue;
  final Set<Marker>? markers;
  final RadarScanController? radarScan;
  final double bottomInset;

  Set<Marker> get _defaultMarkers => {
        Marker(
          markerId: const MarkerId('booking_location'),
          position: location,
          anchor: const Offset(0.5, 1),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
        ),
      };

  @override
  Widget build(BuildContext context) {
    final scan = radarScan;
    final mapMarkers = markers ?? _defaultMarkers;

    Widget map = GoogleMap(
      initialCameraPosition: CameraPosition(
        target: location,
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
      markers: mapMarkers,
    );

    if (scan != null) {
      // Rebuilds only the GoogleMap widget with fresh circle data per ripple
      // tick; markers/tiles/camera stay untouched.
      map = ValueListenableBuilder<Set<Circle>>(
        valueListenable: scan,
        builder: (context, circles, _) => GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
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
          markers: mapMarkers,
          circles: circles,
        ),
      );
    }

    return map;
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
