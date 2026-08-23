import 'package:flutter/material.dart';

import '../api/resources/users_api.dart';
import '../flutter_flow/auth_logger.dart';
import '../flutter_flow/nav/nav.dart';
import '../index.dart';
import '../services/auth_service.dart';

/// Placeholder store URL for the standalone Provider app.
/// Replace with the real Play Store / App Store link once published.
const String kProviderAppStoreUrl = 'https://serbisyohubph.com/provider-app';

/// Handles post-authentication navigation for the **client-only** app.
///
/// All accounts land on Home. Provider-capable accounts receive a notice
/// directing them to the standalone Provider app (spec: provider sign-in
/// guidance, mixed-capability continuation).
class PostAuthNavigationFlow {
  factory PostAuthNavigationFlow() => _instance;

  PostAuthNavigationFlow._internal();
  static final PostAuthNavigationFlow _instance =
      PostAuthNavigationFlow._internal();

  Future<Map<String, dynamic>?> _ensureUser() async {
    final authService = AuthService.instance;
    if (authService.currentUser != null) {
      return authService.currentUser;
    }
    try {
      final data = await ShphUsersApi.instance.getMe();
      final profile = data['profile'] is Map<String, dynamic>
          ? data['profile'] as Map<String, dynamic>
          : data;
      authService.adoptUser(profile);
      return profile;
    } catch (e) {
      AuthLogger.error(
        'Failed to load user for post-auth navigation: $e',
        tag: 'PostAuthNavigationFlow',
        error: e,
      );
      return null;
    }
  }

  Future<void> _showProviderNotice(BuildContext context) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Provider account detected'),
        content: const Text(
          'Provider tools have moved to the SerbisyoHub Provider app. '
          'You can continue using this app as a client, or sign out.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(false);
              await AuthService.instance.logout();
              if (!context.mounted) return;
              context.goNamedAuth(SigninWidget.routeName, context.mounted);
            },
            child: const Text('Sign out'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue as client'),
          ),
        ],
      ),
    );

    // If user dismissed without picking, treat as continue.
    if (confirmed == false) return;
    if (!context.mounted) return;
    // Continue as client – land on Home.
    context.goNamedAuth(HomeWidget.routeName, context.mounted);
  }

  Future<void> handlePostAuthNavigation({
    required BuildContext context,
    required String userId,
  }) async {
    try {
      AuthLogger.debug(
        'Handling post-auth navigation for user: $userId',
        tag: 'PostAuthNavigationFlow',
      );

      final authService = AuthService.instance;
      final user = await _ensureUser();

      if (user == null) {
        AuthLogger.warning(
          'No user profile available. Routing to Home.',
          tag: 'PostAuthNavigationFlow',
        );
        if (context.mounted) {
          context.goNamedAuth(HomeWidget.routeName, context.mounted);
        }
        return;
      }

      if (authService.isProvider == true) {
        AuthLogger.info(
          'Provider-capable account signed in on client app. Showing provider notice.',
          tag: 'PostAuthNavigationFlow',
        );
        if (!context.mounted) return;
        await _showProviderNotice(context);
        return;
      }

      AuthLogger.info(
        'Client account. Routing to Home.',
        tag: 'PostAuthNavigationFlow',
      );
      if (context.mounted) {
        context.goNamedAuth(HomeWidget.routeName, context.mounted);
      }
    } catch (e) {
      AuthLogger.error(
        'Error handling post-auth navigation: $e',
        tag: 'PostAuthNavigationFlow',
        error: e,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigation error. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
        context.goNamedAuth(HomeWidget.routeName, context.mounted);
      }
    }
  }

  /// Client-only: always ready for Home (provider lifecycle removed).
  Future<String> checkProfileStatus(String userId) async {
    try {
      final user = await _ensureUser();
      if (user == null) return 'needs_profile';
      return 'ready_home';
    } catch (e) {
      AuthLogger.error(
        'Error checking profile status: $e',
        tag: 'PostAuthNavigationFlow',
        error: e,
      );
      return 'ready_home';
    }
  }
}
