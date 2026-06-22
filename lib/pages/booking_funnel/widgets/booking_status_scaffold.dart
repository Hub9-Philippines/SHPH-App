import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/theme/app_theme.dart';

class BookingStatusScaffold extends StatelessWidget {
  const BookingStatusScaffold({
    required this.location,
    required this.bottomSheet,
    this.topCard,
    this.center,
    this.showMap = true,
    this.markerHue = BitmapDescriptor.hueRed,
    this.isDraggable = false,
    super.key,
  });

  final LatLng location;
  final Widget? topCard;
  final Widget bottomSheet;
  final Widget? center;
  final bool showMap;
  final double markerHue;
  final bool isDraggable;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: showMap
                ? GoogleMap(
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
                  )
                : DecoratedBox(
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
          if (center != null) Center(child: center!),
          if (isDraggable)
            _DraggableBottomSheet(child: bottomSheet)
          else
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
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

    return DraggableScrollableSheet(
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
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            children: [child],
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
      child: child,
    );
  }
}


