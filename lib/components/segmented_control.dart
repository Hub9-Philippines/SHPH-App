import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/theme/app_theme.dart';

/// Theme-driven segmented control for tab-style pickers (Messages, Bookings,
/// and other list filters). Single source so every screen shares the same
/// pill/track look instead of drifting via bespoke FlutterFlow widgets.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.value,
    required this.onChanged,
    required this.segments,
    this.height = 48,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<SegmentedOption<T>> segments;
  final double height;
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.surfaceAlt,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++)
            Expanded(
              child: _SegmentButton(
                label: segments[i].label,
                icon: segments[i].icon,
                selected: segments[i].value == value,
                onTap: () => onChanged(segments[i].value),
              ),
            ),
        ],
      ),
    );
  }
}

class SegmentedOption<T> {
  const SegmentedOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.primaryBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
          boxShadow: selected ? AppThemeData.shadowSoft : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? theme.primary : theme.secondaryText,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? theme.primary : theme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
