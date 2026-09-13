import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/cupertino_ui/app_button.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import '../booking_models.dart';

class LocationConfirmationPanel extends StatelessWidget {
  const LocationConfirmationPanel({
    required this.address,
    required this.onEdit,
    required this.onConfirm,
    this.serviceTitle,
    this.serviceCategoryName,
    super.key,
  });

  final BookingAddress address;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;
  final String? serviceTitle;
  final String? serviceCategoryName;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: theme.alternate.withValues(alpha: 0.35)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.bfPinnedLocation,
              style: theme.labelMedium.override(
                color: theme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.bfConfirmServiceLocation,
            style: theme.titleMedium.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.bfConfirmRightPlace,
            style: theme.bodySmall.override(
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          if (serviceTitle != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.alternate),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.home_repair_service_rounded,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceTitle!,
                          style: theme.bodyLarge.override(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (serviceCategoryName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            serviceCategoryName!,
                            style: theme.bodySmall.override(
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.alternate),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.place_rounded,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.bfDropOffPoint,
                        style: theme.labelMedium.override(
                          color: theme.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.label,
                        style: theme.bodyLarge.override(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${address.line1}, ${address.city}',
                        style: theme.bodySmall.override(
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: onEdit,
                  variant: AppButtonVariant.outlined,
                  borderSide: BorderSide(color: theme.alternate),
                  height: 56,
                  borderRadius: 18,
                  child: Text(l10n.bfEditPin),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  onPressed: onConfirm,
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  height: 56,
                  borderRadius: 18,
                  child: Text(
                    l10n.bfContinue,
                    style: theme.titleSmall.override(
                      fontWeight: FontWeight.w700,
                      color: theme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
