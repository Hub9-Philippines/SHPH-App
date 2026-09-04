import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

/// Priority levels offered by the "Get help" emergency modal.
enum EmergencyPriority { emergency, urgent }

/// Bottom sheet shown when the user taps "Get help" on the home screen (or
/// any other emergency entry point). It lets them choose between a true
/// emergency (immediate dispatch) and an urgent (expedited 15–30 min) job
/// before entering the booking flow.
///
/// Returns the selected [EmergencyPriority] via `showModalBottomSheet`.
class EmergencyModal extends StatelessWidget {
  const EmergencyModal({super.key});

  static Future<EmergencyPriority?> show(BuildContext context) =>
      showModalBottomSheet<EmergencyPriority>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const EmergencyModal(),
      );

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.alternate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppThemeData.destructiveSoft.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: AppThemeData.destructiveSoft,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.emGetHelp,
                          style: theme.titleLarge.override(
                            font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.emChoosePriority,
                          style: theme.bodyMedium.override(
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _PriorityCard(
                icon: Icons.bolt_rounded,
                title: l10n.emEmergency,
                subtitle: l10n.emEmergencyDesc,
                accent: AppThemeData.destructiveSoft,
                onTap: () =>
                    Navigator.of(context).pop(EmergencyPriority.emergency),
              ),
              const SizedBox(height: 12),
              _PriorityCard(
                icon: Icons.speed_rounded,
                title: l10n.emUrgent,
                subtitle: l10n.emUrgentDesc,
                accent: AppThemeData.accentYellow,
                onTap: () => Navigator.of(context).pop(EmergencyPriority.urgent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppThemeData.spaceLg),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.bodyLarge.override(
                        font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700),
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppThemeData.contrastOn(theme.secondaryBackground)
                    .withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
