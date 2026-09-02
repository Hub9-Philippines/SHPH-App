import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title,
    this.message,
    this.onRetry,
  });

  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final _l10n = AppLocalizations.of(context)!;
    final effectiveTitle = title ?? _l10n.ccSomethingWrong;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.error_outline_rounded,
                  color: theme.error, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: theme.titleMedium.override(
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(color: theme.textTertiary),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(_l10n.ccTryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
