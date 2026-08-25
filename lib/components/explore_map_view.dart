import 'package:flutter/material.dart';
import '/components/demo_map_placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExploreMapMarker {
  const ExploreMapMarker({
    required this.id,
    required this.latLng,
    this.title,
    this.snippet,
    this.photoUrl,
  });

  final String id;
  final LatLng latLng;
  final String? title;
  final String? snippet;
  final String? photoUrl;
}

class ExploreMapView extends StatefulWidget {
  const ExploreMapView({
    super.key,
    this.initialLocation,
    this.markers = const [],
    this.showUserLocation = true,
    this.radiusMeters,
    this.onMarkerTap,
    this.onMapTap,
  });

  final LatLng? initialLocation;
  final List<ExploreMapMarker> markers;
  final bool showUserLocation;
  final double? radiusMeters;
  final void Function(String id)? onMarkerTap;
  final void Function(LatLng latLng)? onMapTap;

  @override
  State<ExploreMapView> createState() => _ExploreMapViewState();
}

class _ExploreMapViewState extends State<ExploreMapView> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  static const _defaultLocation = LatLng(14.5995, 120.9842);

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(ExploreMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markers != widget.markers) _updateMarkers();
  }

  void _updateMarkers() {
    _markers = widget.markers.map((m) {
      return Marker(
        markerId: MarkerId(m.id),
        position: m.latLng,
        infoWindow: InfoWindow(
          title: m.title ?? '',
          snippet: m.snippet ?? '',
        ),
        onTap: () => widget.onMarkerTap?.call(m.id),
      );
    }).toSet();

    if (widget.radiusMeters != null && widget.initialLocation != null) {
      _circles = {
        Circle(
          circleId: const CircleId('radius'),
          center: widget.initialLocation!,
          radius: widget.radiusMeters!,
          fillColor: Colors.blue.withValues(alpha: 0.08),
          strokeColor: Colors.blue.withValues(alpha: 0.3),
          strokeWidth: 2,
        ),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return kDemoMode ? const DemoMapPlaceholder(label: 'Explore map') : GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialLocation ?? _defaultLocation,
        zoom: 14,
      ),
      markers: _markers,
      circles: _circles,
      myLocationEnabled: widget.showUserLocation,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (ctrl) => _controller = ctrl,
      onTap: (latLng) => widget.onMapTap?.call(latLng),
    );
  }
}
