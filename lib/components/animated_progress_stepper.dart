import 'package:flutter/material.dart';
import '/theme/app_theme.dart';

/// Animated step progress bar for the lazy onboarding flow.
class AnimatedProgressStepper extends StatelessWidget {
  const AnimatedProgressStepper({
    super.key,
    required this.currentStep,
    this.totalSteps = 2,
    this.height = 4.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  });

  /// 1-indexed current active step
  final int currentStep;
  final int totalSteps;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final clampedStep = currentStep.clamp(1, totalSteps);
    final progress = clampedStep / totalSteps;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $clampedStep of $totalSteps',
                style: theme.labelSmall.copyWith(
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.labelSmall.copyWith(
                  color: theme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Container(
              height: height,
              width: double.infinity,
              color: theme.alternate.withOpacity(0.4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primary,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
