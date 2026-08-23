import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            message ?? 'Sign in to continue',
            style: theme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'You need to be signed in to access this feature.',
            style: theme.bodySmall?.copyWith(color: theme.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            onDismiss();
            GoRouter.of(context).go('/signin');
          },
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}
