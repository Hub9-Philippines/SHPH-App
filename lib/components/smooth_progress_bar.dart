import 'package:flutter/material.dart';

/// Glides a progress value toward its target so per-second updates never
/// snap. Wraps any progress rendering via [builder], receiving the smoothed
/// value.
///
/// Used by the proximity-search screens (booking live matching + TM
/// broadcast) where the countdown drives progress in whole-second steps.
class SmoothProgress extends StatelessWidget {
  const SmoothProgress({
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  /// Target progress, clamped to [0, 1].
  final double value;
  final Widget Function(BuildContext context, double smoothedValue) builder;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: curve,
      builder: (context, smoothed, _) => builder(context, smoothed),
    );
  }
}
