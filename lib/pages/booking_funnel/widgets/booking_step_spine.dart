import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

/// Compact horizontal step spine used across the booking funnel screens. Shows
/// one pill per funnel stage, marks completed stages with a check, highlights
/// the [currentStep], and leaves later stages muted.
class BookingStepSpine extends StatelessWidget {
  const BookingStepSpine({
    required this.steps,
    required this.currentStep,
    super.key,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          if (index > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index <= currentStep
                      ? theme.primary.withValues(alpha: 0.35)
                      : theme.alternate,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          Expanded(
            flex: 3,
            child: Center(
              child: _StepPill(
                title: steps[index],
                active: index == currentStep,
                done: index < currentStep,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.title,
    required this.active,
    required this.done,
  });

  final String title;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = done || active ? theme.primary : theme.alternate;
    final background = done || active
        ? theme.primary.withValues(alpha: active ? 0.14 : 0.08)
        : theme.secondaryBackground;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: done || active ? 0.5 : 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done)
            Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: theme.primary,
            )
          else
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: active ? theme.primary : theme.secondaryText,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.labelSmall.override(
                color: done || active ? theme.primary : theme.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

