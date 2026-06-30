import 'package:flutter_test/flutter_test.dart';

import 'package:serbisyohubph/utils/geo_utils.dart';

/// Replicates the scoring formula from TM repository _providerScore().
///
/// FinalScore = max(0, baseSkillScore - distanceKm * 1.5)
double computeProviderScore({
  required int skillMatchPoints,
  required double distanceKm,
}) {
  const penaltyPerKm = 1.5;
  final raw = skillMatchPoints - distanceKm * penaltyPerKm;
  return raw.clamp(0.0, double.infinity);
}

void main() {
  group('GeoUtils.calculateETA — minimum cap', () {
    test('returns at least 3 for zero distance', () {
      final eta = GeoUtils.calculateETA(0);
      expect(eta, greaterThanOrEqualTo(3));
    });

    test('returns at least 3 for negative distance', () {
      final eta = GeoUtils.calculateETA(-5);
      expect(eta, greaterThanOrEqualTo(3));
    });

    test('returns at least 3 for very small distance (0.01 km)', () {
      final eta = GeoUtils.calculateETA(0.01);
      expect(eta, greaterThanOrEqualTo(3));
    });

    test('returns reasonable value for 10 km', () {
      // At 40 km/h, 10 km = 15 min
      final eta = GeoUtils.calculateETA(10);
      expect(eta, inInclusiveRange(12, 20));
    });

    test('returns scaled value for 100 km', () {
      // At 40 km/h, 100 km = 150 min
      final eta = GeoUtils.calculateETA(100);
      expect(eta, greaterThan(100));
    });
  });

  group('_providerScore — linear distance penalty', () {
    test('no penalty at zero distance', () {
      // 6 + 4 + 3 + 2 = 15 (all skill matches + verified)
      const baseScore = 15;
      final result = computeProviderScore(
        skillMatchPoints: baseScore,
        distanceKm: 0,
      );
      expect(result, equals(15.0));
    });

    test('drops by exactly 1.5 per km', () {
      const baseScore = 15;
      // 15 - (10 * 1.5) = 15 - 15 = 0
      final result = computeProviderScore(
        skillMatchPoints: baseScore,
        distanceKm: 10,
      );
      expect(result, equals(0.0));
    });

    test('linear decay at 5 km', () {
      const baseScore = 15;
      // 15 - (5 * 1.5) = 15 - 7.5 = 7.5
      final result = computeProviderScore(
        skillMatchPoints: baseScore,
        distanceKm: 5,
      );
      expect(result, equals(7.5));
    });

    test('linear decay at 2 km', () {
      const baseScore = 15;
      // 15 - (2 * 1.5) = 15 - 3 = 12
      final result = computeProviderScore(
        skillMatchPoints: baseScore,
        distanceKm: 2,
      );
      expect(result, equals(12.0));
    });
  });

  group('_providerScore — clamp at zero', () {
    test('clamps to 0.0 when distance far exceeds score', () {
      const baseScore = 6; // Only sub-category match
      final result = computeProviderScore(
        skillMatchPoints: baseScore,
        distanceKm: 50,
      );
      expect(result, equals(0.0));
    });

    test('clamps to 0.0 at extreme distance (100 km)', () {
      const baseScore = 15;
      final result = computeProviderScore(
        skillMatchPoints: baseScore,
        distanceKm: 100,
      );
      expect(result, equals(0.0));
    });

    test('clamps to 0.0 at extreme distance (200 km)', () {
      const baseScore = 15;
      final result = computeProviderScore(
        skillMatchPoints: baseScore,
        distanceKm: 200,
      );
      expect(result, equals(0.0));
    });

    test('never returns negative regardless of inputs', () {
      for (final km in [1.0, 5.0, 10.0, 50.0, 100.0, 1000.0]) {
        for (final skill in [0, 2, 6, 15]) {
          final result = computeProviderScore(
            skillMatchPoints: skill,
            distanceKm: km,
          );
          expect(result, greaterThanOrEqualTo(0.0),
              reason: 'Score went negative at skill=$skill, distance=$km km');
        }
      }
    });
  });

  group('GeoUtils.calculateDistance — Haversine accuracy', () {
    test('zero distance for same point', () {
      final dist = GeoUtils.calculateDistance(14.5995, 120.9842, 14.5995, 120.9842);
      expect(dist, closeTo(0, 0.001));
    });

    test('Manila to Makati is roughly 6-7 km', () {
      // Manila (14.5995, 120.9842) to Makati (14.5547, 121.0244)
      final dist = GeoUtils.calculateDistance(14.5995, 120.9842, 14.5547, 121.0244);
      expect(dist, inInclusiveRange(5, 8));
    });

    test('Manila to Quezon City is roughly 10-14 km', () {
      // Manila (14.5995, 120.9842) to Quezon City (14.6760, 121.0437)
      final dist = GeoUtils.calculateDistance(14.5995, 120.9842, 14.6760, 121.0437);
      expect(dist, inInclusiveRange(10, 15));
    });

    test('Manila to Cebu is roughly 560-580 km', () {
      // Manila (14.5995, 120.9842) to Cebu (10.3157, 123.8854)
      final dist = GeoUtils.calculateDistance(14.5995, 120.9842, 10.3157, 123.8854);
      expect(dist, inInclusiveRange(560, 580));
    });
  });

  group('GeoUtils.hasValidLocation', () {
    test('rejects null values', () {
      expect(GeoUtils.hasValidLocation(null, null), isFalse);
      expect(GeoUtils.hasValidLocation(14.5, null), isFalse);
      expect(GeoUtils.hasValidLocation(null, 120.9), isFalse);
    });

    test('rejects zero/uninitialized coordinates', () {
      expect(GeoUtils.hasValidLocation(0.0, 0.0), isFalse);
      expect(GeoUtils.hasValidLocation(0, 120.9), isFalse);
      expect(GeoUtils.hasValidLocation(14.5, 0), isFalse);
    });

    test('accepts valid Philippine coordinates', () {
      expect(GeoUtils.hasValidLocation(14.5995, 120.9842), isTrue);
      expect(GeoUtils.hasValidLocation(10.3157, 123.8854), isTrue);
    });
  });
}
