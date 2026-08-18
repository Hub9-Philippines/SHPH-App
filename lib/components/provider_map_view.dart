import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '/theme/app_theme.dart';

class ProviderMapView extends StatefulWidget {
  const ProviderMapView({
    super.key,
    this.providerLocation,
    this.clientLocation,
    this.polylinePoints,
    this.providerLabel = 'You',
    this.clientLabel = 'Client',
  });

  final LatLng? providerLocation;
  final LatLng? clientLocation;
  final List<LatLng>? polylinePoints;
  final String providerLabel;
  final String clientLabel;

  @override
  State<ProviderMapView> createState() => _ProviderMapViewState();
}

class _ProviderMapViewState extends State<ProviderMapView> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  static const _manila = LatLng(14.5995, 120.9842);

  @override
  void initState() {
    super.initState();
    _updateOverlays();
  }

  @override
  void didUpdateWidget(ProviderMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateOverlays();
  }

  void _updateOverlays() {
    final markers = <Marker>{};

    if (widget.providerLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('provider'),
        position: widget.providerLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: widget.providerLabel),
      ));
    }

    if (widget.clientLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('client'),
        position: widget.clientLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.clientLabel),
      ));
    }

    _markers = markers;

    if (widget.polylinePoints != null && widget.polylinePoints!.length >= 2) {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: widget.polylinePoints!,
          color: const Color(0xFF368EFF),
          width: 4,
          jointType: JointType.round,
        ),
      };
    } else {
      _polylines = {};
    }
  }

  LatLng _center() {
    if (widget.providerLocation != null && widget.clientLocation != null) {
      return LatLng(
        (widget.providerLocation!.latitude + widget.clientLocation!.latitude) / 2,
        (widget.providerLocation!.longitude + widget.clientLocation!.longitude) / 2,
      );
    }
    return widget.providerLocation ?? widget.clientLocation ?? _manila;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _center(),
            zoom: 14,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (ctrl) {
            _controller = ctrl;
            if (widget.providerLocation != null && widget.clientLocation != null) {
              _fitBounds();
            }
          },
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppThemeData.shadowMd,
            ),
            child: IconButton(
              icon: const Icon(Icons.my_location_rounded),
              onPressed: () {
                _controller?.animateCamera(
                  CameraUpdate.newLatLngZoom(_center(), 14),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _fitBounds() {
    if (widget.providerLocation == null || widget.clientLocation == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        widget.providerLocation!.latitude < widget.clientLocation!.latitude
            ? widget.providerLocation!.latitude
            : widget.clientLocation!.latitude,
        widget.providerLocation!.longitude < widget.clientLocation!.longitude
            ? widget.providerLocation!.longitude
            : widget.clientLocation!.longitude,
      ),
      northeast: LatLng(
        widget.providerLocation!.latitude > widget.clientLocation!.latitude
            ? widget.providerLocation!.latitude
            : widget.clientLocation!.latitude,
        widget.providerLocation!.longitude > widget.clientLocation!.longitude
            ? widget.providerLocation!.longitude
            : widget.clientLocation!.longitude,
      ),
    );
    _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }
}
