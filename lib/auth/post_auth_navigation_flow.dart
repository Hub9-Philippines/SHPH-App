import 'package:flutter/material.dart';

import '../api/resources/users_api.dart';
import '../flutter_flow/auth_logger.dart';
import '../flutter_flow/nav/nav.dart';
import '../index.dart';
import '../services/auth_service.dart';
import '../services/provider_verification_service.dart';

/// Handles post-authentication navigation based on profile completeness and
/// account type (web `usePostAuthNavigation` parity).
///
/// This flow handles routing after a successful login/verification:
/// 1. Client account → Home.
/// 2. Provider account → the 4-state lifecycle resolved by
///    [ProviderVerificationService]: profile → KYC intro → review → dashboard.
class PostAuthNavigationFlow {
  factory PostAuthNavigationFlow() => _instance;

  PostAuthNavigationFlow._internal();
  static final PostAuthNavigationFlow _instance =
      PostAuthNavigationFlow._internal();

  /// Ensure [AuthService] carries the session user (reads `/auth/me/`).
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

  /// Check profile completeness and route to the appropriate page.
  ///
  /// Returns:
  ///   - Does not return; handles routing internally
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

      // Client (and non-provider) accounts land on Home.
      if (authService.isProvider != true) {
        AuthLogger.info(
          'Client account. Routing to Home.',
          tag: 'PostAuthNavigationFlow',
        );
        if (context.mounted) {
          context.goNamedAuth(HomeWidget.routeName, context.mounted);
        }
        return;
      }

      // Provider: resolve the 4-state lifecycle.
      final redirect = await ProviderVerificationService.instance
          .resolveProviderRedirect(user);
      AuthLogger.info(
        'Provider verification state resolved to: $redirect',
        tag: 'PostAuthNavigationFlow',
      );
      if (!context.mounted) return;

      switch (redirect) {
        case '/createProfile':
          context.goNamed(CreateProfileWidget.routeName);
        case '/eKYCBegin':
          context.goNamed(EKYCBeginWidget.routeName);
        case '/pro-verification-progress':
          context.goNamed(VerificationReviewingWidget.routeName);
        default:
          context.goNamed(ProDashboardWidget.routeName);
      }
    } catch (e) {
      AuthLogger.error(
        'Error handling post-auth navigation: $e',
        tag: 'PostAuthNavigationFlow',
        error: e,
      );

      // On error, fallback to home
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

  /// Alternative method: Check if profile is complete without routing.
  ///
  /// Useful if you want to handle routing elsewhere.
  ///
  /// Returns:
  ///   - 'needs_profile': User needs to complete profile
  ///   - 'needs_kyc': User profile is complete but needs KYC (provider)
  ///   - 'ready_pro_dashboard': User is a verified (or KYC-skipped) provider
  ///   - 'ready_home': User can proceed to home
  Future<String> checkProfileStatus(String userId) async {
    try {
      final authService = AuthService.instance;
      final user = await _ensureUser();
      if (user == null) return 'needs_profile';

      if (authService.isProvider != true) {
        return 'ready_home';
      }

      final redirect = await ProviderVerificationService.instance
          .resolveProviderRedirect(user);
      switch (redirect) {
        case '/createProfile':
          return 'needs_profile';
        case '/eKYCBegin':
          return 'needs_kyc';
        default:
          return 'ready_pro_dashboard';
      }
    } catch (e) {
      AuthLogger.error(
        'Error checking profile status: $e',
        tag: 'PostAuthNavigationFlow',
        error: e,
      );
      return 'ready_home'; // Allow to proceed on error
    }
  }
}
