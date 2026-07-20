import 'package:flutter/material.dart';

import 'base_auth_user_provider.dart';

abstract class AuthManager {
  Future signOut();
  Future deleteUser(BuildContext context);
  Future updateEmail({required String email, required BuildContext context});
  Future resetPassword({required String email, required BuildContext context});
  Future sendEmailVerification() async => currentUser?.sendEmailVerification();
  Future refreshUser() async => currentUser?.refreshUser();

  // Sign-in methods (implemented by all auth managers)
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  );
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  );
  Future<BaseAuthUser?> signInAnonymously(BuildContext context);
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context);
  Future<BaseAuthUser?> signInWithApple(BuildContext context);
  Future<BaseAuthUser?> signInWithGithub(BuildContext context);
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  });
  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
    String? phoneNumber,
  });
}

mixin EmailSignInManager on AuthManager {
}

mixin AnonymousSignInManager on AuthManager {
}

mixin AppleSignInManager on AuthManager {
}

mixin GoogleSignInManager on AuthManager {
}

mixin JwtSignInManager on AuthManager {
  Future<BaseAuthUser?> signInWithJwtToken(
    BuildContext context,
    String jwtToken,
  );
}

mixin PhoneSignInManager on AuthManager {
}

mixin FacebookSignInManager on AuthManager {
  Future<BaseAuthUser?> signInWithFacebook(BuildContext context);
}

mixin MicrosoftSignInManager on AuthManager {
  Future<BaseAuthUser?> signInWithMicrosoft(
    BuildContext context,
    List<String> scopes,
    String tenantId,
  );
}

mixin GithubSignInManager on AuthManager {
}
