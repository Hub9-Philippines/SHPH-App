import 'package:flutter/material.dart';

import '../api/resources/users_api.dart';
import '../flutter_flow/auth_logger.dart';
import '../flutter_flow/nav/nav.dart';
import '../index.dart';
import '../l10n/app_localizations.dart';
import '../pages/create_profile/create_profile_widget.dart';
import '../services/auth_service.dart';
import '../services/client_kyc_service.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.pfProviderDetected),
        content: Text(
          l10n.panProviderAppBody,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(false);
              await AuthService.instance.logout();
              if (!context.mounted) return;
              context.goNamedAuth(SigninWidget.routeName, context.mounted);
            },
            child: Text(l10n.panSignOut),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.panContinueAsClient),
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
        'Client account. Resolving profile-completion status.',
        tag: 'PostAuthNavigationFlow',
      );
      final status = await checkProfileStatus(userId);
      if (!context.mounted) return;
      if (status == 'needs_profile') {
        AuthLogger.info(
          'Profile incomplete. Routing to profile creation.',
          tag: 'PostAuthNavigationFlow',
        );
        context.goNamedAuth(CreateProfileWidget.routeName, context.mounted);
      } else if (status == 'needs_kyc') {
        AuthLogger.info(
          'Profile complete, KYC not started. Routing to KYC onboarding.',
          tag: 'PostAuthNavigationFlow',
        );
        context.goNamedAuth(KycOnboardingWidget.routeName, context.mounted);
      } else {
        AuthLogger.info(
          'Profile complete. Routing to Home.',
          tag: 'PostAuthNavigationFlow',
        );
        context.goNamedAuth(HomeWidget.routeName, context.mounted);
      }
    } catch (e) {
      AuthLogger.error(
        'Error handling post-auth navigation: $e',
        tag: 'PostAuthNavigationFlow',
        error: e,
      );
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.panNavigationError),
            duration: const Duration(seconds: 3),
          ),
        );
        context.goNamedAuth(HomeWidget.routeName, context.mounted);
      }
    }
  }

  /// Resolves the signed-in client's next step. Returns:
  /// - `needs_profile` when the profile is missing or not yet marked complete
  ///   (`is_profile_complete != true`);
  /// - `needs_kyc` when the profile is complete but KYC is `not_submitted`
  ///   and the user has not skipped verification;
  /// - otherwise `ready_home`.
  /// KYC lookups never trap the user: if the KYC check itself fails the
  /// status falls back to `ready_home` and the skip path stays available.
  /// [kycService] is injectable for tests.
  Future<String> checkProfileStatus(
    String userId, {
    ClientKycService? kycService,
  }) async {
    try {
      final user = await _ensureUser();
      if (user == null) return 'needs_profile';
      final isComplete = user['is_profile_complete'] == true ||
          (user['display_name'] != null &&
              user['display_name'].toString().trim().isNotEmpty) ||
          (user['name'] != null &&
              user['name'].toString().trim().isNotEmpty) ||
          (user['full_name'] != null &&
              user['full_name'].toString().trim().isNotEmpty) ||
          (user['first_name'] != null &&
              user['first_name'].toString().trim().isNotEmpty) ||
          AuthService.instance.isProfileComplete;
      if (!isComplete) return 'needs_profile';
      final kyc = await (kycService ?? ClientKycService()).status();
      if (kyc.status == 'not_submitted' && !kyc.skipped) return 'needs_kyc';
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
