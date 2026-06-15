import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../flutter_flow/auth_logger.dart';
import '../services/face_verification/face_verification_service.dart';

/// Helper class for managing face verification in authentication flows
///
/// Usage:
/// 1. After user successfully authenticates (email/password, OAuth, etc.)
/// 2. Call [checkAndEnforceFaceVerification] before navigating to home
/// 3. If not verified, user will be redirected to FaceScannerView
/// 4. After face verification, user proceeds to home
class FaceVerificationAuthFlow {
  factory FaceVerificationAuthFlow() => _instance;

  FaceVerificationAuthFlow._internal();
  static final FaceVerificationAuthFlow _instance =
      FaceVerificationAuthFlow._internal();

  final _faceService = FaceVerificationService();

  /// Main method: Check if user needs face verification and enforce it
  ///
  /// Call this in your login success handlers (email, password, OAuth, etc.)
  ///
  /// Example usage in auth_util.dart or your auth callback:
  /// ```dart
  /// // After successful email/password login
  /// final phoneVerifiedUser = await verifySmsCode(...);
  /// if (phoneVerifiedUser != null) {
  ///   final shouldRedirect = await FaceVerificationAuthFlow()
  ///       .checkAndEnforceFaceVerification(
  ///     context: context,
  ///     userId: phoneVerifiedUser.uid,
  ///     homeRouteName: 'Home',
  ///     faceScannerRouteName: 'FaceScanner',
  ///   );
  ///   // Don't navigate yet - the method handles routing
  /// }
  /// ```
  ///
  /// Returns:
  ///   - true: User already verified, can proceed to home
  ///   - false: User redirected to face scanner (don't navigate home)
  Future<bool> checkAndEnforceFaceVerification({
    required BuildContext context,
    required String userId,
    required String homeRouteName,
    required String faceScannerRouteName,
  }) async {
    try {
      AuthLogger.debug(
        'Checking face verification for user: $userId',
        tag: 'FaceVerificationAuthFlow',
      );

      // Get current verification status
      final status = await _faceService.getFaceVerificationStatus(userId);
      final isVerified = status['isVerified'] as bool? ?? false;

      if (isVerified) {
        AuthLogger.debug(
          'User $userId already verified. Proceeding to home.',
          tag: 'FaceVerificationAuthFlow',
        );
        return true; // Caller should navigate to home
      }

      // User not verified - redirect to face scanner
      AuthLogger.info(
        'User $userId not face verified. Redirecting to face scanner.',
        tag: 'FaceVerificationAuthFlow',
      );

      // Navigate to face scanner with user ID as parameter
      if (context.mounted) {
        context.goNamed(
          faceScannerRouteName,
          extra: {
            'userId': userId,
            'returnRoute': homeRouteName,
          },
        );
      }

      return false; // Redirected to face scanner
    } catch (e) {
      AuthLogger.error(
        'Error checking face verification: $e',
        tag: 'FaceVerificationAuthFlow',
        error: e,
      );

      // On error, allow user to proceed (don't block)
      // But log for monitoring
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Issues with face verification, please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      return true; // Proceed to home on error
    }
  }

  /// Integration point: Add this method to your phone verification success handler
  ///
  /// In [lib/pages/phone_verify_user/phone_verify_user_widget.dart],
  /// modify the "Verify" button's onPressed to use this:
  ///
  /// Example:
  /// ```dart
  /// onPressed: () async {
  ///   final smsCodeVal = _model.pinCodeController!.text;
  ///   final phoneVerifiedUser = await verifySmsCode(
  ///     context: context,
  ///     smsCode: smsCodeVal,
  ///   );
  ///
  ///   if (phoneVerifiedUser == null) return;
  ///
  ///   // Use the face verification flow
  ///   final shouldProceedHome = await FaceVerificationAuthFlow()
  ///       .checkAndEnforceFaceVerification(
  ///         context: context,
  ///         userId: phoneVerifiedUser.uid,
  ///         homeRouteName: HomeWidget.routeName,
  ///         faceScannerRouteName: FaceVerificationScreen.routeName,
  ///       );
  ///
  ///   if (shouldProceedHome) {
  ///     if (loggedIn) {
  ///       context.goNamedAuth(HomeWidget.routeName, context.mounted);
  ///     } else {
  ///       context.goNamedAuth(CreateProfileWidget.routeName, context.mounted);
  ///     }
  ///   }
  /// }
  /// ```
}

/// Extension on GoRouter context for convenience
extension FaceVerificationRoute on BuildContext {
  /// Convenience method to check face verification before navigating
  ///
  /// Usage:
  /// ```dart
  /// if (await context.verifyFaceBeforeNavigation(userId, 'Home')) {
  ///   context.goNamed('Home');
  /// }
  /// ```
  Future<bool> verifyFaceBeforeNavigation(
    String userId,
    String homeRouteName, {
    String faceScannerRouteName = 'FaceVerification',
  }) async =>
      FaceVerificationAuthFlow().checkAndEnforceFaceVerification(
        context: this,
        userId: userId,
        homeRouteName: homeRouteName,
        faceScannerRouteName: faceScannerRouteName,
      );
}
