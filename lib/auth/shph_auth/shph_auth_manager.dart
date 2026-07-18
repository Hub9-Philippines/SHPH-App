import 'dart:async';

import 'package:flutter/material.dart';

import '/api/resources/auth_api.dart';
import '/api/shph_token_storage.dart';
import '/app_state.dart';
import '/flutter_flow/auth_logger.dart';
import '/flutter_flow/otp_rate_limiter.dart';
import '/services/biometric_auth_service.dart';
import '/services/chat_service.dart';
import '/services/logging_service.dart';
import '../auth_manager.dart';
import 'shph_user_provider.dart';

/// Phone auth helper (mirrors [ShphPhoneAuthManager] pattern).
class ShphPhoneAuthManager extends ChangeNotifier {
  bool? _triggerOnCodeSent;
  String? phoneAuthError;
  void Function(BuildContext)? _onCodeSent;

  bool get triggerOnCodeSent => _triggerOnCodeSent ?? false;
  set triggerOnCodeSent(bool val) => _triggerOnCodeSent = val;

  void Function(BuildContext) get onCodeSent =>
      _onCodeSent == null ? (_) {} : _onCodeSent!;
  set onCodeSent(void Function(BuildContext) func) => _onCodeSent = func;

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}

/// Auth manager backed by the SHPH REST API.
///
/// All authentication operations go through
/// `/api/auth/*` endpoints via [ShphAuthApi].
class ShphAuthManager extends AuthManager
    with
        EmailSignInManager,
        GoogleSignInManager,
        AppleSignInManager,
        AnonymousSignInManager,
        GithubSignInManager,
        PhoneSignInManager {
  ShphPhoneAuthManager phoneAuthManager = ShphPhoneAuthManager();

  @override
  Future signOut() async {
    await ShphAuthApi.instance.logout();
    await BiometricAuthService.instance.disableBiometricLogin();
    ChatService.instance.closeWebSocket();
    currentUser = null;
    notifyShphAuthChanged(ShphUser({}));
  }

  /// Enable biometric login by storing the current refresh token in the
  /// keychain/keystore protected by device biometrics.
  Future<bool> enableBiometricLogin() async {
    try {
      final refreshToken = await ShphTokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        LoggingService.warning(
          'Cannot enable biometric login: no refresh token available',
          tag: 'BiometricAuth',
        );
        return false;
      }
      return BiometricAuthService.instance.enableBiometricLogin(refreshToken);
    } catch (e) {
      LoggingService.error(
        'Failed to enable biometric login',
        tag: 'BiometricAuth',
        error: e,
      );
      return false;
    }
  }

  /// Attempt to sign in using device biometrics. Returns the authenticated
  /// user on success, null otherwise.
  Future<BaseAuthUser?> signInWithBiometric(BuildContext context) async {
    if (!await BiometricAuthService.instance.isBiometricLoginEnabled) {
      return null;
    }

    final result = await BiometricAuthService.instance.authenticate(
      localizedReason: 'Authenticate to access SerbisyoHub',
    );
    if (result != BiometricAuthResult.success) {
      return null;
    }

    try {
      final refreshToken =
          await BiometricAuthService.instance.getRefreshTokenWithAuth();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      await ShphAuthApi.instance.refreshToken(refreshToken: refreshToken);
      final data = await ShphAuthApi.instance.getCurrentUser();
      if (data.isEmpty) {
        await ShphTokenStorage.clear();
        return null;
      }

      final user = ShphUser(data);
      notifyShphAuthChanged(user);
      await ChatService.instance.initializeWebSocket();
      return user;
    } catch (e) {
      LoggingService.error(
        'Biometric login failed',
        tag: 'BiometricAuth',
        error: e,
      );
      return null;
    }
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      if (!loggedIn || currentUser?.uid == null) {
        AuthLogger.debug('Delete user attempted with no logged in user',
            tag: 'DeleteUser');
        return;
      }

      await currentUser?.delete();
      await signOut();
    } catch (e) {
      if (!context.mounted) {
        return;
      }
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
      if (!loggedIn) {
        AuthLogger.debug('Update email attempted with no logged in user',
            tag: 'UpdateEmail');
        return;
      }

      await currentUser?.updateEmail(email);
    } catch (e) {
      AuthLogger.error('Email update failed', tag: 'UpdateEmail', error: e);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update email at this time. Please try again.',
          ),
        ),
      );
    }
  }

  Future updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        AuthLogger.debug('Update password attempted with no logged in user',
            tag: 'UpdatePassword');
        return;
      }

      await currentUser?.updatePassword(newPassword);

      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } catch (e) {
      AuthLogger.error('Password update failed',
          tag: 'UpdatePassword', error: e);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update password at this time. Please try again.',
          ),
        ),
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

      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      AuthLogger.error('Password reset failed', tag: 'ResetPassword', error: e);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'If an account exists with that email, you will receive password reset instructions.',
          ),
        ),
      );
    }
  }

  @override
  Future sendEmailVerification() async {
    if (!loggedIn || currentUser?.email == null) {
      throw Exception('No user or email to verify');
    }
    // The SHPH API handles email verification during registration.
    // No separate endpoint for resending verification.
    return true;
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final data = await ShphAuthApi.instance.login(
        email: email,
        password: password,
      );

      final user = ShphUser(data);
      notifyShphAuthChanged(user);

      await ChatService.instance.initializeWebSocket();
      return user;
    } catch (e) {
      AuthLogger.error('Authentication failed', tag: 'EMAIL', error: e);
      if (!context.mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Authentication failed. Please check your credentials and try again.',
          ),
        ),
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
      final roleToUse = FFAppState().tempsignuprole.isNotEmpty
          ? FFAppState().tempsignuprole
          : 'client';

      // Initiate registration — sends OTP to email
      await ShphAuthApi.instance.registerInitiate(
        payload: {
          'email': email,
          'password': password,
          'role': roleToUse,
        },
      );

      // Store credentials for the verify step
      _pendingRegistration = {
        'email': email,
        'password': password,
        'role': roleToUse,
      };

      // Return null — caller should navigate to OTP verification page
      return null;
    } catch (e) {
      AuthLogger.error('Registration failed', tag: 'EMAIL', error: e);
      if (!context.mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration failed. Please try again.',
          ),
        ),
      );
      return null;
    }
  }

  /// Complete email registration with OTP code.
  Future<BaseAuthUser?> verifyEmailRegistration(
    BuildContext context,
    String otpCode,
  ) async {
    try {
      final pending = _pendingRegistration;
      if (pending == null) {
        throw StateError('No pending registration to verify');
      }

      final data = await ShphAuthApi.instance.registerVerify(
        payload: {
          'email': pending['email'],
          'otp': otpCode,
        },
      );

      _pendingRegistration = null;

      final user = ShphUser(data);
      notifyShphAuthChanged(user);

      await ChatService.instance.initializeWebSocket();
      return user;
    } catch (e) {
      AuthLogger.error('Email verification failed', tag: 'EMAIL', error: e);
      if (!context.mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Verification failed. Please check the code and try again.'),
        ),
      );
      return null;
    }
  }

  Map<String, dynamic>? _pendingRegistration;

  @override
  Future<BaseAuthUser?> signInAnonymously(BuildContext context) async {
    // Anonymous sign-in is not supported by the SHPH API.
    AuthLogger.debug('Anonymous sign-in not supported', tag: 'AnonymousSignIn');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anonymous sign-in is not available.'),
        ),
      );
    }
    return null;
  }

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) async {
    try {
      // For Google sign-in, we'd use the google_sign_in package to get an ID token,
      // then exchange it with the SHPH API.
      // This requires platform-specific setup and is handled by the social auth bridge.
      final data = await _socialSignIn(context, 'google');
      if (data != null) {
        final user = ShphUser(data);
        notifyShphAuthChanged(user);
        await ChatService.instance.initializeWebSocket();
        return user;
      }
      return null;
    } catch (e) {
      AuthLogger.error('Google sign-in failed', tag: 'GoogleSignIn', error: e);
      if (!context.mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to sign in with Google. Please try again.'),
        ),
      );
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) async {
    try {
      final data = await _socialSignIn(context, 'apple');
      if (data != null) {
        final user = ShphUser(data);
        notifyShphAuthChanged(user);
        await ChatService.instance.initializeWebSocket();
        return user;
      }
      return null;
    } catch (e) {
      AuthLogger.error('Apple sign-in failed', tag: 'AppleSignIn', error: e);
      if (!context.mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to sign in with Apple. Please try again.'),
        ),
      );
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInWithGithub(BuildContext context) async {
    try {
      final data = await _socialSignIn(context, 'github');
      if (data != null) {
        final user = ShphUser(data);
        notifyShphAuthChanged(user);
        await ChatService.instance.initializeWebSocket();
        return user;
      }
      return null;
    } catch (e) {
      AuthLogger.error('GitHub sign-in failed', tag: 'GithubSignIn', error: e);
      if (!context.mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to sign in with GitHub. Please try again.'),
        ),
      );
      return null;
    }
  }

  /// Exchange a social provider ID token for SHPH API JWT tokens.
  Future<Map<String, dynamic>?> _socialSignIn(
    BuildContext context,
    String provider,
  ) async {
    // This is a placeholder — the actual implementation depends on the
    // platform-specific OAuth flow (google_sign_in, sign_in_with_apple, etc.)
    // The SHPH API endpoint is `/api/auth/social/<provider>/`.
    //
    // For now, we log and return null. The social sign-in flow will be
    // implemented separately when platform packages are configured.
    AuthLogger.debug('Social sign-in for $provider not yet implemented',
        tag: 'SocialSignIn');
    return null;
  }

  void handlePhoneAuthStateChanges(BuildContext context) {
    phoneAuthManager.addListener(() {
      if (!context.mounted) {
        return;
      }

      if (phoneAuthManager.triggerOnCodeSent) {
        if (context.mounted) {
          phoneAuthManager.onCodeSent(context);
        }
        phoneAuthManager
            .update(() => phoneAuthManager.triggerOnCodeSent = false);
      } else if (phoneAuthManager.phoneAuthError != null) {
        final e = phoneAuthManager.phoneAuthError!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
        phoneAuthManager.update(() => phoneAuthManager.phoneAuthError = null);
      }
    });
  }

  @override
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    final formattedPhoneNumber = _formatToE164(phoneNumber);

    if (!_isValidE164Format(formattedPhoneNumber)) {
      AuthLogger.error(
        'Invalid phone number format. Please use format: +639123456789 (with country code)',
        tag: 'PhoneAuth',
      );
      phoneAuthManager.update(() {
        phoneAuthManager.phoneAuthError =
            'Invalid phone number format. Please include country code (e.g., +639123456789 for Philippines)';
      });
      return;
    }

    final rateLimiter = OtpRateLimiter();
    final rateLimitError = rateLimiter.validateOtpRequest(formattedPhoneNumber);

    if (rateLimitError != null) {
      AuthLogger.debug(
        'OTP request blocked by rate limiter for $formattedPhoneNumber',
        tag: 'PhoneAuth',
      );
      phoneAuthManager.update(() {
        phoneAuthManager.phoneAuthError = rateLimitError;
      });
      return;
    }

    phoneAuthManager.update(() => phoneAuthManager.onCodeSent = onCodeSent);

    try {
      AuthLogger.debug(
        'Sending phone OTP request for: $formattedPhoneNumber',
        tag: 'PhoneAuth',
      );

      await ShphAuthApi.instance.sendOtpPin(
        payload: {'phone_number': formattedPhoneNumber},
      );

      rateLimiter.recordOtpRequest(formattedPhoneNumber);

      AuthLogger.debug(
        'Phone OTP sent successfully to $formattedPhoneNumber',
        tag: 'PhoneAuth',
      );

      phoneAuthManager.update(() {
        phoneAuthManager.phoneAuthError = null;
      });

      AuthLogger.debug('OTP sent successfully, calling onCodeSent callback',
          tag: 'PhoneAuth');
      if (context.mounted) {
        onCodeSent(context);
      }
    } catch (e) {
      AuthLogger.error('Phone OTP request failed', tag: 'PhoneAuth', error: e);
      phoneAuthManager.update(() {
        phoneAuthManager.phoneAuthError = e.toString();
      });
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
        AuthLogger.error(
          'No phone number available for SMS verification',
          tag: 'PhoneAuth',
        );
        throw Exception('Phone number is required for SMS verification');
      }

      final formattedPhone = _formatToE164(phone);

      AuthLogger.debug(
        'Verifying SMS code for phone: $formattedPhone',
        tag: 'PhoneAuth',
      );

      final data = await ShphAuthApi.instance.verifyOtpPin(
        payload: {'phone_number': formattedPhone, 'pin': smsCode},
      );

      if (data.isNotEmpty) {
        OtpRateLimiter().clearPhoneNumber(formattedPhone);
        final user = ShphUser(data);
        notifyShphAuthChanged(user);
        await ChatService.instance.initializeWebSocket();
        return user;
      }
      return null;
    } catch (e) {
      AuthLogger.error('SMS code verification failed',
          tag: 'PhoneAuth', error: e);
      if (!context.mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification failed. Please check the code and try again.',
          ),
        ),
      );
      return null;
    }
  }

  /// Restore auth session from stored JWT token on app start.
  Future<BaseAuthUser?> restoreSession() async {
    try {
      final hasToken = await ShphTokenStorage.hasAccessToken();
      if (!hasToken) {
        return null;
      }

      final data = await ShphAuthApi.instance.getCurrentUser();
      if (data.isEmpty) {
        await ShphTokenStorage.clear();
        return null;
      }

      final user = ShphUser(data);
      notifyShphAuthChanged(user);
      await ChatService.instance.initializeWebSocket();
      return user;
    } catch (e) {
      LoggingService.error('Session restore failed: $e',
          tag: 'ShphAuthManager');
      await ShphTokenStorage.clear();
      return null;
    }
  }

  String _formatToE164(String phoneNumber) {
    var cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.startsWith('+')) {
      return cleaned;
    }

    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    if (!cleaned.startsWith('63')) {
      cleaned = '63$cleaned';
    }

    return '+$cleaned';
  }

  bool _isValidE164Format(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) {
      return false;
    }

    final digitsOnly = phoneNumber.substring(1);
    return RegExp(r'^\d{7,15}$').hasMatch(digitsOnly);
  }
}
