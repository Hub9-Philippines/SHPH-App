import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

/// One step of the booking progress timeline.
class BookingStep {
  const BookingStep({
    required this.label,
    required this.icon,
    this.timestamp,
  });

  final String label;
  final IconData icon;

  /// Printed next to the label once the step is completed.
  final String? timestamp;
}

/// Vertical timeline stepper for booking progress.
///
/// Completed steps render a glowing teal checkmark with their timestamp,
/// the current step is highlighted in teal, and pending steps show muted
/// gray dots.
class BookingStepIndicator extends StatelessWidget {
  const BookingStepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<BookingStep> steps;

  /// Index of the furthest completed step. Values below zero mean nothing
  /// has happened yet (all dots pending).
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            _Connector(done: i <= currentStep),
          _StepRow(
            step: steps[i],
            state: _stepState(i),
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }

  _StepState _stepState(int index) {
    if (index < currentStep) return _StepState.done;
    if (index == currentStep) return _StepState.current;
    return _StepState.pending;
  }
}

enum _StepState { done, current, pending }

class _Connector extends StatelessWidget {
  const _Connector({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 22),
      child: Container(
        width: 2,
        height: 26,
        decoration: BoxDecoration(
          color: done ? AppThemeData.successTeal : theme.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.state,
  });

  final BookingStep step;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final done = state == _StepState.done;
    final isCurrent = state == _StepState.current;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: done || isCurrent
                  ? AppThemeData.successTeal
                  : theme.surfaceAlt,
              shape: BoxShape.circle,
              boxShadow: done
                  ? [
                      BoxShadow(
                        // Glow ring for completed checkmarks.
                        color:
                            AppThemeData.successTeal.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : isCurrent
                      ? [
                          BoxShadow(
                            color: AppThemeData.successTeal
                                .withValues(alpha: 0.16),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
            ),
            child: done
                ? const Icon(
                    Icons.check_rounded,
                    size: 22,
                    color: Colors.white,
                  )
                : Icon(
                    step.icon,
                    size: 20,
                    color: isCurrent
                        ? Colors.white
                        : theme.textTertiary,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: theme.titleSmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                    ),
                    color: done || isCurrent
                        ? theme.primaryText
                        : theme.textTertiary,
                  ),
                ),
                if (done && (step.timestamp?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.timestamp!,
                    style: theme.labelSmall.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppThemeData.successTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
              ),
              child: Text(
                'In progress',
                style: theme.labelSmall.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                  ),
                  color: AppThemeData.successTeal,
                ),
              ),
            ),
        ],
        ),
      );
  }
}
