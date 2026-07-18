import 'package:flutter/material.dart';

/// Lightweight shimmer overlay that sweeps a subtle slate gradient
/// across its child.  Disposes the animation controller when unmounted
/// so no hidden rendering load persists.
class ExpressShimmer extends StatefulWidget {
  const ExpressShimmer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<ExpressShimmer> createState() => _ExpressShimmerState();
}

class _ExpressShimmerState extends State<ExpressShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Alignment> _alignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _alignment = AlignmentTween(
      begin: Alignment.centerLeft - const Alignment(0.8, 0),
      end: Alignment.centerRight + const Alignment(0.8, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey[300]!;
    final light = Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _alignment,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: _alignment.value,
          end: _alignment.value - const Alignment(0.6, 0),
          colors: [
            base,
            base,
            light,
            base,
            base,
          ],
          stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
        ).createShader(bounds),
        child: child!,
      ),
      child: widget.child,
    );
  }
}

/// Structural skeleton that mirrors the `ExpressCheckoutScreen` bottom-sheet
/// layout.  All dimensions and border radii match their real counterparts
/// so the shimmer maps cleanly to the final UI.
class ExpressCheckoutSkeleton extends StatelessWidget {
  const ExpressCheckoutSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey[300]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // drag handle
        Center(
          child: _shimmerBlock(
            width: 42,
            height: 5,
            borderRadius: 999,
            color: base,
          ),
        ),
        const SizedBox(height: 14),
        // header row (back button + title area)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBlock(width: 44, height: 44, borderRadius: 14, color: base),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBlock(
                      width: 160, height: 18, borderRadius: 6, color: base),
                  const SizedBox(height: 6),
                  _shimmerBlock(
                      width: 200, height: 14, borderRadius: 6, color: base),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Location section row (icon + text + chevron)
        _sectionRow(base),
        const SizedBox(height: 10),
        // Time section row
        _sectionRow(base),
        const SizedBox(height: 10),
        // Scope section row
        _sectionRow(base),
        const SizedBox(height: 18),
        // Payment method section title
        _shimmerBlock(width: 130, height: 16, borderRadius: 6, color: base),
        const SizedBox(height: 12),
        // Payment pills row (3 pills)
        Row(
          children: List.generate(
              3,
              (i) => Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                    child: _shimmerBlock(
                      width: 82,
                      height: 38,
                      borderRadius: 999,
                      color: base,
                    ),
                  )),
        ),
        const SizedBox(height: 18),
        // Total card row
        _shimmerBlock(
          width: double.infinity,
          height: 58,
          borderRadius: 22,
          color: base,
        ),
        const SizedBox(height: 16),
        // Confirm button
        _shimmerBlock(
          width: double.infinity,
          height: 58,
          borderRadius: 18,
          color: base,
        ),
      ],
    );
  }

  Widget _sectionRow(Color base) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            _shimmerBlock(width: 42, height: 42, borderRadius: 14, color: base),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBlock(
                      width: 120, height: 15, borderRadius: 6, color: base),
                  const SizedBox(height: 6),
                  _shimmerBlock(
                      width: 180, height: 13, borderRadius: 6, color: base),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _shimmerBlock(width: 18, height: 18, borderRadius: 4, color: base),
          ],
        ),
      );

  Widget _shimmerBlock({
    required double? width,
    required double height,
    required double borderRadius,
    required Color color,
  }) =>
      Container(
        width: width == double.infinity ? double.infinity : width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
}
