import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/components/cupertino_ui/app_button.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';

class AuthPromptModal extends StatelessWidget {
  const AuthPromptModal({
    super.key,
    required this.isOpen,
    required this.onDismiss,
    this.message,
  });

  final bool isOpen;
  final VoidCallback onDismiss;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final _l10n = AppLocalizations.of(context)!;

    if (!isOpen) return const SizedBox.shrink();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.lock_open, color: theme.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? _l10n.ccSignInTitle,
            style: theme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _l10n.ccSignInSubtitle,
            style: theme.bodySmall?.copyWith(color: theme.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        AppButton(
          onPressed: onDismiss,
          variant: AppButtonVariant.text,
          child: Text(_l10n.ccCancel),
        ),
        AppButton(
          onPressed: () {
            onDismiss();
            GoRouter.of(context).go('/signin');
          },
          variant: AppButtonVariant.primary,
          child: Text(_l10n.ccSignIn),
        ),
      ],
    );
  }
}
