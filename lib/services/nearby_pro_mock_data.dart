import 'dart:math';

import '/app_state.dart';
import '/services/logging_service.dart';

class NearbyProMockData {
  NearbyProMockData._();
  static final NearbyProMockData instance = NearbyProMockData._();

  static const double _nearbyRadiusKm = 5;

  final List<_MockProProfile> _mockPros = const [
    _MockProProfile(
        'Eduardo Ramirez',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
        4.9,
        187),
    _MockProProfile(
        'Fatima Gonzales',
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
        4.8,
        142),
    _MockProProfile(
        'Ramon Dela Cruz',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
        4.9,
        231),
    _MockProProfile(
        'Sofia Villanueva',
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
        4.7,
        98),
    _MockProProfile(
        'Miguel Santos',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        165),
    _MockProProfile(
        'Angela Mercado',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
        4.9,
        204),
    _MockProProfile(
        'Pedro Lim',
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100',
        4.6,
        76),
    _MockProProfile(
        'Carmen Navarro',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
        4.8,
        119),
    _MockProProfile(
        'Antonio Reyes',
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100',
        4.7,
        153),
    _MockProProfile(
        'Isabella Torres',
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100',
        4.9,
        276),
  ];

  List<Map<String, dynamic>> generateNearbyPros({
    required int serviceId,
    required String category,
    required int count,
  }) {
    final appState = FFAppState();
    final lat = appState.selectedLatitude;
    final lng = appState.selectedLongitude;

    if (lat == null || lng == null) {
      LoggingService.debug(
        'No pinned location set, using default Metro Manila coords',
        tag: 'NearbyProMockData',
      );
      return _generateForLocation(
        serviceId: serviceId,
        category: category,
        count: count,
        centerLat: 14.5995,
        centerLng: 120.9842,
      );
    }

    return _generateForLocation(
      serviceId: serviceId,
      category: category,
      count: count,
      centerLat: lat,
      centerLng: lng,
    );
  }

  static double haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degree) => degree * pi / 180.0;

  List<Map<String, dynamic>> _generateForLocation({
    required int serviceId,
    required String category,
    required int count,
    required double centerLat,
    required double centerLng,
  }) {
    final random = Random(serviceId + category.length);

    final selected = [..._mockPros]..shuffle(random);
    final pros = selected.take(count.clamp(1, _mockPros.length)).toList();

    return List.generate(pros.length, (i) {
      final bearing = random.nextDouble() * 2 * pi;
      final distanceKm = 0.3 + random.nextDouble() * (_nearbyRadiusKm - 0.3);
      final offset = _latLngOffset(centerLat, centerLng, bearing, distanceKm);

      return {
        'providerId': 'mock_${serviceId}_$i',
        'providerName': pros[i].name,
        'providerPhoto': pros[i].photo,
        'providerLatitude': offset.lat,
        'providerLongitude': offset.lng,
        'distanceKm': double.parse(distanceKm.toStringAsFixed(1)),
        'distanceText': _formatDistance(distanceKm),
        'rating': pros[i].rating,
        'completedJobs': pros[i].completedJobs,
        'etaMinutes': (distanceKm / 30 * 60).round().clamp(5, 45),
      };
    });
  }

  _LatLngOffset _latLngOffset(
      double lat, double lng, double bearing, double distanceKm) {
    const R = 6371.0;
    final latRad = _toRadians(lat);
    final lngRad = _toRadians(lng);
    final d = distanceKm / R;

    final newLat =
        asin(sin(latRad) * cos(d) + cos(latRad) * sin(d) * cos(bearing));
    final newLng = lngRad +
        atan2(sin(bearing) * sin(d) * cos(latRad),
            cos(d) - sin(latRad) * sin(newLat));

    return _LatLngOffset(
      double.parse(_toDegrees(newLat).toStringAsFixed(6)),
      double.parse(_toDegrees(newLng).toStringAsFixed(6)),
    );
  }

  double _toDegrees(double rad) => rad * 180.0 / pi;

  String _formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()} m away';
    }
    return '${km.toStringAsFixed(1)} km away';
  }
}

class _MockProProfile {

  const _MockProProfile(this.name, this.photo, this.rating, this.completedJobs);
  final String name;
  final String photo;
  final double rating;
  final int completedJobs;
}

class _LatLngOffset {
  const _LatLngOffset(this.lat, this.lng);
  final double lat;
  final double lng;
}
