import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/theme/app_theme.dart';

const double _kDefaultMapVisibleFraction = 0.42;
const double _kDefaultSheetMaxFraction = 0.64;
const double _kMinimumMapHeight = 220;

class BookingStatusScaffold extends StatelessWidget {
  const BookingStatusScaffold({
    required this.location,
    required this.bottomSheet,
    this.topCard,
    this.center,
    this.showMap = true,
    this.markerHue = BitmapDescriptor.hueRed,
    this.isDraggable = false,
    this.mapVisibleFraction = _kDefaultMapVisibleFraction,
    this.sheetMaxFraction = _kDefaultSheetMaxFraction,
    super.key,
  });

  final LatLng location;
  final Widget? topCard;
  final Widget bottomSheet;
  final Widget? center;
  final bool showMap;
  final double markerHue;
  final bool isDraggable;
  final double mapVisibleFraction;
  final double sheetMaxFraction;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mapHeight = (constraints.maxHeight * mapVisibleFraction)
              .clamp(_kMinimumMapHeight, constraints.maxHeight);
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
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: mapHeight,
                child: showMap
                    ? ClipRect(
                        child: GoogleMap(
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
                          markers: {
                            Marker(
                              markerId: const MarkerId('booking_location'),
                              position: location,
                              anchor: const Offset(0.5, 1),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                markerHue,
                              ),
                            ),
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (center != null) Center(child: center!),
              if (isDraggable)
                _DraggableBottomSheet(child: bottomSheet)
              else
                Align(
                  alignment: Alignment.bottomCenter,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeBottom: true,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: sheetMaxHeight),
                      child: bottomSheet,
                    ),
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

class _DraggableBottomSheet extends StatelessWidget {
  const _DraggableBottomSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: DraggableScrollableSheet(
        initialChildSize: 0.35,
        minChildSize: 0.12,
        maxChildSize: 0.75,
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
