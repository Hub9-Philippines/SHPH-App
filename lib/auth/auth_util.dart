import 'package:flutter/material.dart';
import 'auth_manager.dart';
import 'auth_manager_factory.dart';
import 'base_auth_user_provider.dart';
import 'shph_auth/shph_auth_manager.dart';
import 'shph_auth/shph_user_provider.dart';

export 'base_auth_user_provider.dart';
export 'shph_auth/shph_user_provider.dart';

AuthManager get authManager => AuthManagerFactory.instance;

String get currentUserUid => currentUser?.uid ?? '';
String get currentUserEmail => currentUser?.email ?? '';
bool get loggedIn => currentUser?.loggedIn ?? false;
String get currentUserDisplayName => currentUser?.displayName ?? '';
String get currentUserPhoto => currentUser?.photoUrl ?? '';
String get currentPhoneNumber => currentUser?.phoneNumber ?? '';
bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;
bool get userLoggedIn => loggedIn;

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

Future<void> beginPhoneAuth({
  required BuildContext context,
  required String phoneNumber,
  required void Function(BuildContext) onCodeSent,
}) async {
  await (authManager as ShphAuthManager).beginPhoneAuth(
    context: context,
    phoneNumber: phoneNumber,
    onCodeSent: onCodeSent,
  );
}

Future<dynamic> verifySmsCode({
  required BuildContext context,
  required String smsCode,
  String? phoneNumber,
}) async {
  return (authManager as ShphAuthManager).verifySmsCode(
    context: context,
    smsCode: smsCode,
    phoneNumber: phoneNumber,
  );
}
