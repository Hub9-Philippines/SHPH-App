import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

/// Persistent quick-book scaffold area: urgency micro-copy beside the
/// high-priority "Urgent Assistance" emergency entry (spec:
/// service-search-workflow / quick book scaffold area).
class QuickBookBar extends StatelessWidget {
  const QuickBookBar({super.key, required this.onUrgentAssistance});

  final VoidCallback onUrgentAssistance;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final _l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(top: BorderSide(color: theme.border)),
        boxShadow: AppThemeData.shadowSoft,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _l10n.ccEmergenciesWait,
                    style: theme.labelLarge.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                      color: theme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _l10n.ccVerifiedPro,
                    style: theme.bodySmall.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppThemeData.spaceMd),
            FilledButton.icon(
              onPressed: onUrgentAssistance,
              icon: const Icon(Icons.bolt_rounded, size: 19),
              label: Text(
                _l10n.ccUrgentAssistance,
                style: theme.labelLarge.override(
                  font:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: Colors.white,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeData.spaceLg,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
