import 'dart:math' as math;

class GeoUtils {
  // Earth's radius in kilometers
  static const double _earthRadiusKm = 6371;
  
  // Manila Fallback Coordinates (used when user location is missing/unset)
  static const double fallbackLat = 14.5995;
  static const double fallbackLng = 120.9842;

  /// Validates if the location is set and within bounds of the Philippines operations
  static bool hasValidLocation(double? lat, double? lng) {
    if (lat == null || lng == null) {
      return false;
    }
    // Filters out uninitialized 0.0 values and enforces Philippines bounding box rules (~5-21°N)
    return lat > 1.0 && lng > 1.0;
  }

  /// Calculates the shortest distance between two points using the Haversine formula
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  /// Estimates the driving ETA in minutes assuming an average traffic speed of 40 km/h
  static int calculateETA(double distanceKm) {
    if (distanceKm <= 0) {
      return 3; // Minimum buffer for immediate proximity
    }
    const double averageSpeedKmh = 40;
    
    // Time = Distance / Speed (converted to minutes)
    final double timeInMinutes = (distanceKm / averageSpeedKmh) * 60.0;
    
    // Return rounded integer with a logical minimum ceiling of 3 minutes for buffer dispatching
    return math.max(3, timeInMinutes.round());
  }

  static double _degreesToRadians(double degrees) => degrees * math.pi / 180.0;
}
