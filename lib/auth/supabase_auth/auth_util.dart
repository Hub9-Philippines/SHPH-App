// Authentication Utilities
// Provides auth helper functions and getters for the app

import 'package:flutter/material.dart';
import '../auth_manager.dart';
import '../auth_manager_factory.dart';
import '../base_auth_user_provider.dart';

export '../base_auth_user_provider.dart';
export '../shph_auth/shph_user_provider.dart';

/// Get the current auth manager instance
AuthManager get authManager => AuthManagerFactory.instance;

/// Get the current logged-in user's UID
String get currentUserUid => currentUser?.uid ?? '';

/// Get the current logged-in user's email
String get currentUserEmail => currentUser?.email ?? '';

/// Check if a user is currently logged in
bool get loggedIn => currentUser?.loggedIn ?? false;

/// Get the current user's display name
String get currentUserDisplayName => currentUser?.displayName ?? '';

/// Get the current user's photo URL
String get currentUserPhoto => currentUser?.photoUrl ?? '';

/// Get the current user's phone number
String get currentPhoneNumber => currentUser?.phoneNumber ?? '';

/// Check if the current user's email is verified
bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;

/// Alias for checking if user is logged in (compatibility)
bool get userLoggedIn => loggedIn;

/// Sign out the current user
Future<void> signOutUser(BuildContext context) async {
  try {
    await authManager.signOut();
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error signing out: $e')),
    );
  }
}

/// Verify current user email
Future<void> verifyCurrentUserEmail(BuildContext context) async {
  try {
    await authManager.sendEmailVerification();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email sent')),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

/// Kept for generated screen compatibility. API phone auth has no listener.
void handlePhoneAuthStateChanges(BuildContext context) {}

/// Begin phone authentication
Future<void> beginPhoneAuth({
  required BuildContext context,
  required String phoneNumber,
  required void Function(BuildContext) onCodeSent,
}) async {
  if (authManager is PhoneSignInManager) {
    await (authManager as PhoneSignInManager).beginPhoneAuth(
      context: context,
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
    );
  }
}

/// Verify SMS code
Future<dynamic> verifySmsCode({
  required BuildContext context,
  required String smsCode,
  String? phoneNumber,
}) async {
  if (authManager is PhoneSignInManager) {
    return (authManager as PhoneSignInManager).verifySmsCode(
      context: context,
      smsCode: smsCode,
      phoneNumber: phoneNumber,
    );
  }
  return null;
}
