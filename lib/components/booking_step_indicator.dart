import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

class BookingStep {
  const BookingStep({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class BookingStepIndicator extends StatelessWidget {
  const BookingStepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTap,
  });

  final List<BookingStep> steps;
  final int currentStep;
  final void Function(int)? onStepTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final isComplete = currentStep > stepIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isComplete
                    ? theme.primary
                    : theme.border,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = currentStep == stepIndex;
          final isComplete = currentStep > stepIndex;

          return GestureDetector(
            onTap: onStepTap != null ? () => onStepTap!(stepIndex) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isComplete || isActive
                    ? theme.primary.withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isComplete || isActive
                          ? theme.primary
                          : theme.border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isComplete ? Icons.check : steps[stepIndex].icon,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isActive || isComplete)
                    Text(
                      steps[stepIndex].label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.primary,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
