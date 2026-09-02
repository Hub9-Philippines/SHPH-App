import 'package:flutter/material.dart';

/// Material-styled activity indicator used across the app for loading
/// states. Uses Android-style circular spinner.
class AppActivityIndicator extends StatelessWidget {
  const AppActivityIndicator({
    super.key,
    this.radius,
    this.color,
    this.animating = true,
  });

  final double? radius;
  final Color? color;
  final bool animating;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (radius ?? 14) * 2,
      height: (radius ?? 14) * 2,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color?>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
