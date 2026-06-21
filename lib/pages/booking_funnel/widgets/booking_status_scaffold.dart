import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/theme/app_theme.dart';

class BookingStatusScaffold extends StatelessWidget {
  const BookingStatusScaffold({
    required this.location,
    required this.topCard,
    required this.bottomSheet,
    this.center,
    this.showMap = true,
    this.markerHue = BitmapDescriptor.hueRed,
    this.overlayOpacityTop = 0.10,
    this.overlayOpacityMiddle = 0.18,
    this.overlayOpacityBottom = 0.28,
    super.key,
  });

  final LatLng location;
  final Widget topCard;
  final Widget bottomSheet;
  final Widget? center;
  final bool showMap;
  final double markerHue;
  final double overlayOpacityTop;
  final double overlayOpacityMiddle;
  final double overlayOpacityBottom;

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
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: overlayOpacityTop),
                    Colors.black.withValues(alpha: overlayOpacityMiddle),
                    Colors.black.withValues(alpha: overlayOpacityBottom),
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
            child: topCard,
          ),
          if (center != null) Center(child: center!),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: bottomSheet,
            ),
          ),
        ],
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
