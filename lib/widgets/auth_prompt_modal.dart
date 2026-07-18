import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class AuthPromptModal extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;

  const AuthPromptModal({
    this.title,
    this.message,
    this.onLogin,
    this.onRegister,
    super.key,
  });

  static Future<void> show(BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onLogin,
    VoidCallback? onRegister,
  }) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AuthPromptModal(
        title: title,
        message: message,
        onLogin: onLogin,
        onRegister: onRegister,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(Icons.lock_outline, size: 48, color: theme.primary),
            const SizedBox(height: 16),
            Text(
              title ?? 'Login Required',
              style: theme.titleLarge.override(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message ??
                  'Please log in or create an account to access this feature.',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onLogin?.call();
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Log In'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRegister?.call();
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
