import 'package:flutter/material.dart';

import '../flutter_flow/auth_logger.dart';
import '../flutter_flow/nav/nav.dart';
import '../index.dart';
import '../services/profiles_service.dart';

/// Handles post-authentication navigation based on profile completeness and account type
///
/// This flow handles routing after successful phone verification:
/// 1. If name not populated → CreateProfile
/// 2. If name exists and account type is 'pro' or 'both' → EKYCBegin
/// 3. Otherwise → Home
class PostAuthNavigationFlow {
  factory PostAuthNavigationFlow() => _instance;

  PostAuthNavigationFlow._internal();
  static final PostAuthNavigationFlow _instance =
      PostAuthNavigationFlow._internal();

  Future<void> handlePostAuthNavigation({
    required BuildContext context,
    required String userId,
  }) async {
    try {
      AuthLogger.debug(
        'Handling post-auth navigation for user: $userId',
        tag: 'PostAuthNavigationFlow',
      );

      // Fetch user profile via ProfilesService (SHPH API with Supabase fallback)
      final profile = await ProfilesService.instance.getProfile();

      if (profile == null) {
        AuthLogger.warning(
          'No profile found for user $userId. Routing to CreateProfile.',
          tag: 'PostAuthNavigationFlow',
        );
        if (context.mounted) {
          context.goNamed(CreateProfileWidget.routeName);
        }
        return;
      }

      final displayName = profile.displayName ?? '';
      final firstName = profile.firstName ?? '';
      final lastName = profile.lastName ?? '';
      final accountType = profile.role;
      final isVerified = profile.isVerified ?? false;
      final isFaceVerified = profile.isFaceVerified ?? false;
      final verificationStatus = profile.verificationStatus ?? 'unverified';

      // Check if user has any name set (displayName or firstName/lastName)
      final hasName = displayName.isNotEmpty ||
          (firstName.isNotEmpty || lastName.isNotEmpty);

      // If no name set, user needs to create/complete profile
      if (!hasName) {
        AuthLogger.info(
          'No name populated for user $userId. Routing to CreateProfile.',
          tag: 'PostAuthNavigationFlow',
        );
        if (context.mounted) {
          context.goNamed(CreateProfileWidget.routeName);
        }
        return;
      }

      if (accountType == 'pro' || accountType == 'both') {
        final isFullyVerified =
            isVerified && isFaceVerified && verificationStatus == 'verified';

        if (isFullyVerified) {
          AuthLogger.info(
            'Profile complete and fully verified. Routing to ProDashboard.',
            tag: 'PostAuthNavigationFlow',
          );
          if (context.mounted) {
            context.goNamed(ProDashboardWidget.routeName);
          }
        } else {
          AuthLogger.info(
            'Profile complete but not fully verified (verified: $isVerified, face: $isFaceVerified, status: $verificationStatus). Routing to EKYCBegin.',
            tag: 'PostAuthNavigationFlow',
          );
          if (context.mounted) {
            await context.pushNamed(EKYCBeginWidget.routeName);
          }
        }
      } else {
        AuthLogger.info(
          'Profile complete and account type is $accountType. Routing to Home.',
          tag: 'PostAuthNavigationFlow',
        );
        if (context.mounted) {
          context.goNamedAuth(HomeWidget.routeName, context.mounted);
        }
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

  Future<String> checkProfileStatus(String userId) async {
    try {
      final profile = await ProfilesService.instance.getProfile();

      if (profile == null) {
        return 'needs_profile';
      }

      final displayName = profile.displayName ?? '';
      final firstName = profile.firstName ?? '';
      final lastName = profile.lastName ?? '';
      final accountType = profile.role;
      final isVerified = profile.isVerified ?? false;
      final isFaceVerified = profile.isFaceVerified ?? false;
      final verificationStatus = profile.verificationStatus ?? 'unverified';

      final hasName = displayName.isNotEmpty ||
          (firstName.isNotEmpty || lastName.isNotEmpty);

      if (!hasName) {
        return 'needs_profile';
      }

      if (accountType == 'pro' || accountType == 'both') {
        final isFullyVerified =
            isVerified && isFaceVerified && verificationStatus == 'verified';

        if (isFullyVerified) {
          return 'ready_pro_dashboard';
        }
        return 'needs_kyc';
      }

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
