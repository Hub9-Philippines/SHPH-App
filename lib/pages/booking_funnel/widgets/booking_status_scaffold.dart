import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/components/map_radar_scan.dart';
import '/theme/app_theme.dart';
import 'booking_map_sheet_host.dart';

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

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      // The host paints the map `Positioned.fill` in every mode, so the map's
      // bottom edge can never be bounded by a layout box — that bounded map was
      // what left a band of background between the map and the sheet. The camera
      // padding is derived from the measured sheet height, or from the sheet's
      // live drag extent when [isDraggable].
      body: BookingMapSheetHost(
        maxSheetFraction: sheetMaxFraction,
        fallbackSheetFraction: sheetMaxFraction,
        topCameraPadding: 0,
        bottomCameraPadding: 0,
        horizontalCameraPadding: 0,
        // The sheet is expected to handle its own bottom safe-area inset
        // (`BookingStatusBottomSheet` and the draggable sheet both apply a
        // `SafeArea(top: false)`), so the measured height must not have the
        // inset added again.
        includeBottomSafeArea: false,
        includeTopSafeArea: false,
        resizable: isDraggable
            ? BookingResizableSheet(
                initialFraction: sheetInitialFraction,
                minFraction: sheetMinFraction,
                maxFraction: sheetMaxDraggableFraction,
              )
            : null,
        // Painted under the map. An opaque map hides it, so it only shows
        // through on the map-free path.
        background: DecoratedBox(
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
        // The map-free path must not construct a map widget at all, so this
        // resolves to an empty box instead of a GoogleMap.
        mapBuilder: (context, cameraPadding) => showMap
            ? _RadarMapLayer(
                location: location,
                markerHue: markerHue,
                markers: markers,
                radarScan: radarScan,
                padding: cameraPadding,
              )
            : const SizedBox.shrink(),
        overlays: [
          if (center != null) Center(child: center!),
        ],
        sheet: bottomSheet,
        aboveSheet: [
          if (topCard != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: topCard!,
            ),
        ],
      ),
    );
  }
}

class _RadarMapLayer extends StatelessWidget {
  const _RadarMapLayer({
    required this.location,
    required this.markerHue,
    required this.padding,
    this.markers,
    this.radarScan,
  });

  final LatLng location;
  final double markerHue;
  final EdgeInsets padding;
  final Set<Marker>? markers;
  final RadarScanController? radarScan;

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

    Widget map = _CameraReframingMap(
      padding: padding,
      target: location,
      mapMarkers: mapMarkers,
      circles: const <Circle>{},
    );

    if (scan != null) {
      // Rebuilds only the GoogleMap widget with fresh circle data per ripple
      // tick; markers/tiles/camera stay untouched.
      map = ValueListenableBuilder<Set<Circle>>(
        valueListenable: scan,
        builder: (context, circles, _) => _CameraReframingMap(
          padding: padding,
          target: location,
          mapMarkers: mapMarkers,
          circles: circles,
        ),
      );
    }

    return map;
  }
}

/// GoogleMap with the sheet-derived camera padding. Padding shapes the
/// camera's framing so the marker stays centered in the visible band above
/// the sheet.
class _CameraReframingMap extends StatelessWidget {
  const _CameraReframingMap({
    required this.padding,
    required this.target,
    required this.mapMarkers,
    required this.circles,
  });

  /// Visible band above the sheet, expressed as map-style insets (top inset
  /// from the screen's top edge, bottom inset from the screen's bottom edge).
  final EdgeInsets padding;
  final LatLng target;
  final Set<Marker> mapMarkers;
  final Set<Circle> circles;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: target,
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
      padding: padding,
      markers: mapMarkers,
      circles: circles,
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
