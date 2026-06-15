import 'package:flutter/material.dart';

import '../backend/supabase/database/database.dart';
import '../flutter_flow/auth_logger.dart';
import '../flutter_flow/nav/nav.dart';
import '../index.dart';

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

  /// Check profile completeness and route to appropriate page
  ///
  /// Returns:
  ///   - Does not return; handles routing internally
  ///
  /// Routes to:
  ///   - CreateProfile: if displayName is not populated
  ///   - EKYCBegin: if profile complete and account type is pro or both
  ///   - Home: if profile complete and account type is not pro/both
  Future<void> handlePostAuthNavigation({
    required BuildContext context,
    required String userId,
  }) async {
    try {
      AuthLogger.debug(
        'Handling post-auth navigation for user: $userId',
        tag: 'PostAuthNavigationFlow',
      );

      // Fetch user profile to check completion status
      final profiles = await ProfilesTable().queryRows(
        queryFn: (q) => q.eq('id', userId),
        limit: 1,
      );

      if (profiles.isEmpty) {
        AuthLogger.warning(
          'No profile found for user $userId. Routing to CreateProfile.',
          tag: 'PostAuthNavigationFlow',
        );
        if (context.mounted) {
          context.goNamed(CreateProfileWidget.routeName);
        }
        return;
      }

      final profile = profiles.first;
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

      // Profile name exists, check account type and verification status
      if (accountType == 'pro' || accountType == 'both') {
        // Check if fully verified - route to ProDashboard
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
            context.pushNamed(EKYCBeginWidget.routeName);
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

  /// Alternative method: Check if profile is complete without routing
  ///
  /// Useful if you want to handle routing elsewhere
  ///
  /// Returns:
  ///   - 'needs_profile': User needs to complete profile
  ///   - 'needs_kyc': User profile is complete but needs KYC (pro/both account)
  ///   - 'ready_pro_dashboard': User is fully verified pro, ready for dashboard
  ///   - 'ready_home': User can proceed to home
  Future<String> checkProfileStatus(String userId) async {
    try {
      final profiles = await ProfilesTable().queryRows(
        queryFn: (q) => q.eq('id', userId),
        limit: 1,
      );

      if (profiles.isEmpty) {
        return 'needs_profile';
      }

      final profile = profiles.first;
      final displayName = profile.displayName ?? '';
      final firstName = profile.firstName ?? '';
      final lastName = profile.lastName ?? '';
      final accountType = profile.role;
      final isVerified = profile.isVerified ?? false;
      final isFaceVerified = profile.isFaceVerified ?? false;
      final verificationStatus = profile.verificationStatus ?? 'unverified';

      // Check if user has any name set
      final hasName = displayName.isNotEmpty ||
          (firstName.isNotEmpty || lastName.isNotEmpty);

      if (!hasName) {
        return 'needs_profile';
      }

      if (accountType == 'pro' || accountType == 'both') {
        // Check if fully verified
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
      return 'ready_home'; // Allow to proceed on error
    }
  }
}
