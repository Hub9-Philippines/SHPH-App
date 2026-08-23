import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class WaitingForClientModal extends StatelessWidget {
  const WaitingForClientModal({
    super.key,
    this.clientName,
    this.distanceKm,
    this.onDismiss,
  });

  final String? clientName;
  final double? distanceKm;
  final VoidCallback? onDismiss;

  static Future<void> show(
    BuildContext context, {
    String? clientName,
    double? distanceKm,
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => WaitingForClientModal(
        clientName: clientName,
        distanceKm: distanceKm,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: theme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 72, height: 72,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: theme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text('Waiting for selection\u2026', style: theme.titleMedium),
          const SizedBox(height: 8),
          if (clientName != null || distanceKm != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (clientName != null) ...[
                  Icon(Icons.person_rounded, size: 16, color: theme.secondaryText),
                  const SizedBox(width: 4),
                  Text(clientName!, style: TextStyle(color: theme.secondaryText, fontSize: 14)),
                  const SizedBox(width: 16),
                ],
                if (distanceKm != null) ...[
                  Icon(Icons.near_me_rounded, size: 16, color: theme.secondaryText),
                  const SizedBox(width: 4),
                  Text('${distanceKm!.toStringAsFixed(1)} km', style: TextStyle(color: theme.secondaryText, fontSize: 14)),
                ],
              ],
            )
          else
            Text(
              'The client is reviewing available providers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.secondaryText, fontSize: 14),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                onDismiss?.call();
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
