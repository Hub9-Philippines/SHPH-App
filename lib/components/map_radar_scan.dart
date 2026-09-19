import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Native-geometry radar scan ripple for Google Maps.
///
/// Replaces screen-pixel CustomPainter pulses with real map `Circle`s so the
/// rings stay anchored to the pinned location, scale with the map tiles and
/// never clip or shear under zoom/rotation. The outermost ring expands from
/// 0 to 3000 ground-meters over exactly 30 seconds, looping indefinitely,
/// with staggered rings that fade out as they approach the maximum radius.
class MapRadarScan {
  const MapRadarScan._();

  /// Ground distance the outermost ring reaches at the end of a cycle.
  static const double defaultMaxRadiusMeters = 3000;

  /// Number of staggered rings visible at any instant.
  static const int defaultRingCount = 3;

  /// Below this radius a ring would render as a degenerate speck; clamped so
  /// a phase-0 ring still reads as a small dot.
  static const double _minRingRadiusMeters = 80;

  /// Radius of the solid center dot marking the pinned location.
  static const double _centerDotRadiusMeters = 60;

  /// Per-ring base opacities (radar fade: inner rings strongest).
  static const List<double> _strokeOpacities = [0.42, 0.30, 0.20];
  static const List<double> _fillOpacities = [0.10, 0.06, 0.03];

  static double _opacityFor(List<double> table, int index) =>
      index < table.length ? table[index] : table.last;

  /// Builds the full circle layer for animation fraction [t] in [0, 1).
  ///
  /// Pure function: the same inputs always produce an equivalent circle set.
  /// Rings use `consumeTapEvents: false` and no `onTap` so they never steal
  /// gestures from the map.
  static Set<Circle> buildCircles(
    LatLng center,
    double t, {
    required Color ringColor,
    double maxRadiusMeters = defaultMaxRadiusMeters,
    int ringCount = defaultRingCount,
  }) {
    final circles = <Circle>{
      Circle(
        circleId: const CircleId('radar_center_dot'),
        center: center,
        radius: _centerDotRadiusMeters,
        strokeWidth: 2,
        strokeColor: ringColor,
        fillColor: ringColor,
        consumeTapEvents: false,
      ),
    };

    for (var i = 0; i < ringCount; i++) {
      final phase = (t + i / ringCount) % 1.0;
      final eased = Curves.easeOutCubic.transform(phase);
      final radius = (eased * maxRadiusMeters)
          .clamp(_minRingRadiusMeters, maxRadiusMeters)
          .toDouble();

      circles.add(
        Circle(
          circleId: CircleId('radar_ring_$i'),
          center: center,
          radius: radius,
          strokeWidth: 2 + ((1 - eased) * 2).round(),
          strokeColor: ringColor.withValues(
            alpha: _opacityFor(_strokeOpacities, i) * (1 - eased),
          ),
          fillColor: ringColor.withValues(
            alpha: _opacityFor(_fillOpacities, i) * (1 - eased),
          ),
          consumeTapEvents: false,
        ),
      );
    }

    return circles;
  }
}

/// Owns the 30 s looping radar animation and publishes the current circle
/// layer as a [ValueNotifier] so a `ValueListenableBuilder` can rebuild only
/// the GoogleMap's circle data each tick — never the whole map widget tree.
class RadarScanController extends ValueNotifier<Set<Circle>> {
  RadarScanController({
    required TickerProvider vsync,
    required LatLng center,
    required Color ringColor,
    double maxRadiusMeters = MapRadarScan.defaultMaxRadiusMeters,
    int ringCount = MapRadarScan.defaultRingCount,
  })  : _center = center,
        _ringColor = ringColor,
        _maxRadiusMeters = maxRadiusMeters,
        _ringCount = ringCount,
        super(const <Circle>{}) {
    _animation = AnimationController(
      vsync: vsync,
      duration: cycleDuration,
    )
      ..addListener(_onTick)
      ..repeat();
    _onTick();
  }

  /// Full ripple cycle duration (spec: exactly 30 seconds).
  static const Duration cycleDuration = Duration(seconds: 30);

  late final AnimationController _animation;
  LatLng _center;
  final Color _ringColor;
  final double _maxRadiusMeters;
  final int _ringCount;

  LatLng get center => _center;
  Color get ringColor => _ringColor;

  /// Whether the ripple is currently looping.
  bool get isAnimating => _animation.isAnimating;

  /// Re-pins the ripple (e.g. the draft location resolved after init). No-op
  /// when the center is unchanged; otherwise the layer is recomputed at once.
  void updateCenter(LatLng center) {
    if (center == _center) {
      return;
    }
    _center = center;
    if (isAnimating) {
      _onTick();
    }
  }

  void _onTick() {
    value = MapRadarScan.buildCircles(
      _center,
      _animation.value,
      ringColor: _ringColor,
      maxRadiusMeters: _maxRadiusMeters,
      ringCount: _ringCount,
    );
  }

  /// Stops the ripple and removes its circles from the map (terminal states:
  /// matched, timed out, or failed). Releases the ticker until [restart].
  void stop() {
    _animation.stop();
    value = const <Circle>{};
  }

  /// (Re)starts the looping ripple.
  void restart() {
    _animation.repeat();
  }

  @override
  void dispose() {
    _animation
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }
}
