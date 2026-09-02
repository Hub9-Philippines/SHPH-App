import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

/// Inline expedited-dispatch options shown when an emergency category is
/// selected. Windows guarantee a 15–30 minute provider arrival.
class InstantDispatchSection extends StatelessWidget {
  const InstantDispatchSection({
    super.key,
    required this.categoryName,
    required this.onDispatch,
  });

  final String categoryName;
  final ValueChanged<String> onDispatch;

  static const List<String> _windows = ['0-15', '15-30'];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final _l10n = AppLocalizations.of(context)!;
    final windowLabels = [_l10n.ccWithin15, _l10n.cc15to30];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppThemeData.spaceLg),
      margin: const EdgeInsets.only(top: AppThemeData.spaceMd),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.35),
          width: 1.4,
        ),
        boxShadow: AppThemeData.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  size: 20,
                  color: theme.primary,
                ),
              ),
              const SizedBox(width: AppThemeData.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _l10n.ccInstantDispatch,
                      style: theme.titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                        ),
                        color: theme.primaryText,
                      ),
                    ),
                    Text(
                      _l10n.ccDispatchDesc(categoryName),
                      style: theme.bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemeData.spaceMd),
          Row(
            children: [
              for (var i = 0; i < _windows.length; i++) ...[
                if (i > 0) const SizedBox(width: AppThemeData.spaceSm),
                Expanded(
                  child: _DispatchChip(
                    label: windowLabels[i],
                    window: _windows[i],
                    onTap: () => onDispatch(_windows[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DispatchChip extends StatelessWidget {
  const _DispatchChip({
    required this.label,
    required this.window,
    required this.onTap,
  });

  final String label;
  final String window;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: theme.primary,
      borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.labelMedium.override(
                  font:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
