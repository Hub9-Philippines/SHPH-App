import 'package:flutter/material.dart';

import '/theme/app_theme.dart';
import '../booking_models.dart';

/// Tappable banner showing the booking draft's pickup/drop-off address with an
/// edit affordance. Used by the funnel's Location stage.
class AddressBanner extends StatelessWidget {
  const AddressBanner({
    required this.address,
    required this.onTap,
    super.key,
  });

  final BookingAddress address;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.alternate),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.place_rounded, color: theme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: theme.bodyMedium.override(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${address.line1}, ${address.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_rounded, color: theme.secondaryText, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
