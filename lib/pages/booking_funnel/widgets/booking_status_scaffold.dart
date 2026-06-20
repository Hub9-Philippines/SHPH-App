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
    super.key,
  });

  final LatLng location;
  final Widget topCard;
  final Widget bottomSheet;
  final Widget? center;
  final bool showMap;

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
                          BitmapDescriptor.hueRed,
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
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.28),
                    Colors.black.withValues(alpha: 0.38),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: BoxDecoration(
          color: theme.primaryBackground.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
