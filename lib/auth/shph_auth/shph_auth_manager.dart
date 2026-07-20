import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '/api/shph_api.dart';
import '/auth/test_phone_accounts.dart';
import '../../app_state.dart';
import '../../flutter_flow/auth_logger.dart';
import '../../flutter_flow/otp_rate_limiter.dart';
import '../auth_manager.dart';
import '../base_auth_user_provider.dart';
import 'shph_user_provider.dart';

class ShphAuthManager extends AuthManager
    with
        EmailSignInManager,
        GoogleSignInManager,
        AppleSignInManager,
        AnonymousSignInManager,
        GithubSignInManager,
        PhoneSignInManager {
  static Future<void>? _googleInitialization;

  @override
  Future signOut() async {
    try {
      await ShphAuthApi.instance.logout();
    } catch (_) {
      await ShphTokenStorage.clear();
    }
    currentUser = SerbisyoHubPHShphUser({});
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      if (!loggedIn || currentUser?.uid == null) return;
      await ShphUsersApi.instance.deleteMe();
      await signOut();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Unable to delete user')),
      );
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) return;
      await ShphUsersApi.instance.updateMe({'email': email});
      await currentUser?.refreshUser();
    } catch (e) {
      AuthLogger.error('Email update failed', tag: 'UpdateEmail', error: e);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to update email. Please try again.')),
      );
    }
  }

  Future updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) return;
      await ShphAuthApi.instance.confirmPasswordReset(
        payload: {'password': newPassword, 'confirm_password': newPassword},
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } catch (e) {
      AuthLogger.error('Password update failed',
          tag: 'UpdatePassword', error: e);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to update password. Please try again.')),
      );
    }
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await ShphAuthApi.instance.requestPasswordReset(email: email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      AuthLogger.error('Password reset failed', tag: 'ResetPassword', error: e);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'If an account exists with that email, you will receive password reset instructions.',
        )),
      );
    }
  }

  @override
  Future sendEmailVerification() async {
    if (!loggedIn || currentUser?.email == null) {
      throw Exception('No user or email to verify');
    }
    // SHPH API sends verification on register; no separate resend endpoint.
    return true;
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      await ShphAuthApi.instance.login(
        email: email,
        password: password,
      );
      final user = await ShphUsersApi.instance.getMe();
      final shphUser = SerbisyoHubPHShphUser.fromData(user);
      currentUser = shphUser;
      return shphUser;
    } catch (e) {
      AuthLogger.error('Email sign-in failed', tag: 'EmailSignIn', error: e);
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'Authentication failed. Please check your credentials and try again.',
        )),
      );
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final selectedRole = FFAppState().tempsignuprole.isNotEmpty
          ? FFAppState().tempsignuprole
          : 'client';
      final role = TestPhoneAccounts.apiRole(selectedRole);
      await ShphAuthApi.instance.registerInitiate(payload: {
        'email': email,
        'password': password,
        'role': role,
      });
      // Registration completes via OTP verification; navigate to verify screen.
      return null;
    } catch (e) {
      AuthLogger.error('Email sign-up failed', tag: 'EmailSignUp', error: e);
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInAnonymously(BuildContext context) async {
    // SHPH API doesn't support anonymous auth.
    return null;
  }

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) async {
    try {
      _googleInitialization ??= GoogleSignIn.instance.initialize();
      await _googleInitialization;
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google did not return an ID token.');
      }
      await ShphAuthApi.instance.socialGoogle(idToken: idToken);
      final data = await ShphUsersApi.instance.getMe();
      final user = SerbisyoHubPHShphUser.fromData(data);
      currentUser = user;
      return user;
    } catch (e) {
      AuthLogger.error('Google sign-in failed', tag: 'GoogleSignIn', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in was not completed.')),
        );
      }
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) async {
    return null;
  }

  @override
  Future<BaseAuthUser?> signInWithGithub(BuildContext context) async {
    return null;
  }

  @override
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    final formattedPhone = _formatToE164(phoneNumber);
    if (!_isValidE164Format(formattedPhone)) {
      AuthLogger.error(
        'Invalid phone number format. Please use format: +639123456789',
        tag: 'PhoneAuth',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'Invalid phone number format. Please include country code (e.g., +639123456789 for Philippines)',
        )),
      );
      return;
    }

    final rateLimiter = OtpRateLimiter();
    final rateLimitError = rateLimiter.validateOtpRequest(formattedPhone);
    if (rateLimitError != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(rateLimitError)),
      );
      return;
    }

    try {
      if (FFAppState().phoneLoginMode) {
        await ShphAuthApi.instance
            .sendPhoneLoginOtp(phoneNumber: formattedPhone);
      } else {
        await ShphAuthApi.instance.sendOtpPin(
          payload: {
            'phone_number': formattedPhone,
            'role': TestPhoneAccounts.apiRole(FFAppState().tempsignuprole),
          },
        );
      }
      rateLimiter.recordOtpRequest(formattedPhone);
      AuthLogger.debug('Phone OTP sent to $formattedPhone', tag: 'PhoneAuth');
      if (context.mounted) {
        onCodeSent(context);
      }
    } catch (e) {
      AuthLogger.error('Phone OTP send failed', tag: 'PhoneAuth', error: e);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP. Please try again.')),
      );
    }
  }

  @override
  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
    String? phoneNumber,
  }) async {
    try {
      final phone =
          phoneNumber ?? currentUser?.phoneNumber ?? FFAppState().phone;
      if (phone.isEmpty) {
        throw Exception('Phone number is required');
      }

      final formattedPhone = _formatToE164(phone);
      final data = FFAppState().phoneLoginMode
          ? await ShphAuthApi.instance.verifyPhoneLoginOtp(
              phoneNumber: formattedPhone,
              code: smsCode,
            )
          : await ShphAuthApi.instance.verifyOtpPin(
              payload: {
                'phone_number': formattedPhone,
                'pin': smsCode,
                'role': TestPhoneAccounts.apiRole(
                  FFAppState().tempsignuprole,
                ),
              },
            );

      // On success, tokens are auto-persisted by verifyOtpPin.
      // Fetch user data to set currentUser.
      Map<String, dynamic> userData;
      try {
        userData = await ShphUsersApi.instance.getMe();
      } catch (_) {
        // User data endpoint might not be available immediately after registration.
        // Build a minimal user from the verify response.
        userData = {
          'id': data['user_id'] ?? data['id'],
          'phone_number': formattedPhone,
        };
      }

      final shphUser = SerbisyoHubPHShphUser.fromData(userData);
      currentUser = shphUser;
      OtpRateLimiter().clearPhoneNumber(formattedPhone);

      return shphUser;
    } catch (e) {
      AuthLogger.error('SMS verify failed', tag: 'PhoneAuth', error: e);
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'Verification failed. Please check the code and try again.',
        )),
      );
      return null;
    }
  }

  String _formatToE164(String phoneNumber) {
    var cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
    if (!cleaned.startsWith('63')) cleaned = '63$cleaned';
    return '+$cleaned';
  }

  bool _isValidE164Format(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) return false;
    final digitsOnly = phoneNumber.substring(1);
    return RegExp(r'^\d{7,15}$').hasMatch(digitsOnly);
  }
}
