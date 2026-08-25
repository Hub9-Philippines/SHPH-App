import 'package:flutter/material.dart';

import '/demo/demo_mode.dart';
import '/theme/app_theme.dart';

export '/demo/demo_mode.dart' show kDemoMode;

class DemoMapPlaceholder extends StatelessWidget {
  const DemoMapPlaceholder({super.key, this.label = 'Map preview'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      color: theme.secondaryBackground,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.map_outlined, color: theme.primary, size: 28),
          ),
          const SizedBox(height: 12),
          Text(label, style: theme.titleSmall, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            'Interactive maps are disabled in this demo preview.',
            style: theme.bodySmall.override(color: theme.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
