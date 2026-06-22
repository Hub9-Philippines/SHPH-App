import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/api/bridges/shph_auth_bridge.dart';
import '../../app_state.dart';
import '../../flutter_flow/auth_logger.dart';
import '../../flutter_flow/otp_rate_limiter.dart';
import '../auth_manager.dart';
import 'supabase_user_provider.dart';

/// Supabase Phone Auth Manager
class SupabasePhoneAuthManager extends ChangeNotifier {
  bool? _triggerOnCodeSent;
  AuthException? phoneAuthError;
  String? phoneAuthToken;
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

class SupabaseAuthManager extends AuthManager
    with
        EmailSignInManager,
        GoogleSignInManager,
        AppleSignInManager,
        AnonymousSignInManager,
        GithubSignInManager,
        PhoneSignInManager {
  SupabasePhoneAuthManager phoneAuthManager = SupabasePhoneAuthManager();

  @override
  Future signOut() async {
    await ShphAuthBridge.instance.clearOnSignOut();
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      if (!loggedIn || currentUser?.uid == null) {
        AuthLogger.debug('Delete user attempted with no logged in user',
            tag: 'DeleteUser');
        return;
      }

      await Supabase.instance.client.rpc('delete_user', params: {
        'user_id': currentUser!.uid,
      });

      await signOut();
    } catch (e) {
      if (!context.mounted) return;
      if (e is AuthException) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Unable to delete user')),
        );
      }
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

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: email),
      );

      await currentUser?.refreshUser();
    } on AuthException catch (e) {
      AuthLogger.error('Email update failed', tag: 'UpdateEmail', error: e);
      if (!context.mounted) return;
      if (e.message.contains('Token has expired') ||
          e.message.contains('Auth session missing')) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your session has expired. Please sign in again to update your email.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Unable to update email at this time. Please try again.')),
        );
      }
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

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } on AuthException catch (e) {
      AuthLogger.error('Password update failed',
          tag: 'UpdatePassword', error: e);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (e.message.contains('Token has expired') ||
          e.message.contains('Auth session missing')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Your session has expired. Please sign in again to update your password.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Unable to update password at this time. Please try again.')),
        );
      }
    }
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } on AuthException catch (e) {
      AuthLogger.error('Password reset failed', tag: 'ResetPassword', error: e);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'If an account exists with that email, you will receive password reset instructions.')),
      );
    }
  }

  @override
  Future sendEmailVerification() async {
    if (!loggedIn || currentUser?.email == null) {
      throw Exception('No user or email to verify');
    }

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: currentUser!.email!,
      );
      return true;
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    final user = await _signInOrCreateAccount(
      context,
      () => Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      ),
      'EMAIL',
    );
    if (user != null) {
      await ShphAuthBridge.instance.syncAfterEmailSignIn(
        email: email,
        password: password,
      );
    }
    return user;
  }

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    final user = await _signInOrCreateAccount(
      context,
      () => Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      ),
      'EMAIL',
    );

    if (user != null && user.uid != null) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.uid!)
            .single();
      } catch (_) {
        final roleToUse = FFAppState().tempsignuprole.isNotEmpty
            ? FFAppState().tempsignuprole
            : 'client';
        await Supabase.instance.client.from('profiles').insert({
          'id': user.uid!,
          'role': roleToUse,
          'email': email,
          'is_profile_complete': false,
        });
      }
    }

    return user;
  }

  @override
  Future<BaseAuthUser?> signInAnonymously(
    BuildContext context,
  ) =>
      _signInOrCreateAccount(
        context,
        () => Supabase.instance.client.auth.signInAnonymously(),
        'ANONYMOUS',
      );

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        final response = await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: '${Uri.base.origin}/auth/callback',
        );
        if (response) {
          // Trigger SHPH token sync after OAuth completes (async to avoid BuildContext issues)
          _syncShphTokenAfterSocialLogin('google');
          return currentUser;
        }
        return null;
      } else {
        await Supabase.instance.client.auth
            .signInWithOAuth(OAuthProvider.google);
        // Trigger SHPH token sync after OAuth completes
        _syncShphTokenAfterSocialLogin('google');
        return null;
      }
    } catch (e) {
      AuthLogger.error('Google sign-in failed', tag: 'GoogleSignIn', error: e);
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to sign in with Google. Please try again.')),
      );
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) async {
    try {
      if (kIsWeb) {
        final response = await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: '${Uri.base.origin}/auth/callback',
        );
        if (response) {
          // Trigger SHPH token sync after OAuth completes (async to avoid BuildContext issues)
          _syncShphTokenAfterSocialLogin('apple');
          return currentUser;
        }
        return null;
      } else {
        await Supabase.instance.client.auth
            .signInWithOAuth(OAuthProvider.apple);
        // Trigger SHPH token sync after OAuth completes
        _syncShphTokenAfterSocialLogin('apple');
        return null;
      }
    } catch (e) {
      AuthLogger.error('Apple sign-in failed', tag: 'AppleSignIn', error: e);
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to sign in with Apple. Please try again.')),
      );
      return null;
    }
  }

  @override
  Future<BaseAuthUser?> signInWithGithub(BuildContext context) async {
    try {
      if (kIsWeb) {
        final response = await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.github,
          redirectTo: '${Uri.base.origin}/auth/callback',
        );
        if (response) {
          // Trigger SHPH token sync after OAuth completes (async to avoid BuildContext issues)
          _syncShphTokenAfterSocialLogin('github');
          return currentUser;
        }
        return null;
      } else {
        await Supabase.instance.client.auth
            .signInWithOAuth(OAuthProvider.github);
        // Trigger SHPH token sync after OAuth completes
        _syncShphTokenAfterSocialLogin('github');
        return null;
      }
    } catch (e) {
      AuthLogger.error('GitHub sign-in failed', tag: 'GithubSignIn', error: e);
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to sign in with GitHub. Please try again.')),
      );
      return null;
    }
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
          content: Text('Error: ${e.message}'),
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
    // Format phone number to E.164 format (required by Supabase)
    final formattedPhoneNumber = _formatToE164(phoneNumber);

    // Validate E.164 format
    if (!_isValidE164Format(formattedPhoneNumber)) {
      AuthLogger.error(
        'Invalid phone number format. Please use format: +639123456789 (with country code)',
        tag: 'PhoneAuth',
      );
      phoneAuthManager.update(() {
        phoneAuthManager.phoneAuthError = const AuthException(
          'Invalid phone number format. Please include country code (e.g., +639123456789 for Philippines)',
        );
      });
      return;
    }

    // Fix #4: Rate Limiting on Phone OTP - Check if request is allowed
    final rateLimiter = OtpRateLimiter();
    final rateLimitError = rateLimiter.validateOtpRequest(formattedPhoneNumber);

    if (rateLimitError != null) {
      AuthLogger.debug(
        'OTP request blocked by rate limiter for $formattedPhoneNumber',
        tag: 'PhoneAuth',
      );
      phoneAuthManager.update(() {
        phoneAuthManager.phoneAuthError = AuthException(rateLimitError);
      });
      return;
    }

    phoneAuthManager.update(() => phoneAuthManager.onCodeSent = onCodeSent);

    try {
      AuthLogger.debug(
        'Sending phone OTP request for: $formattedPhoneNumber (NO PASSWORD required)',
        tag: 'PhoneAuth',
      );

      await Supabase.instance.client.auth.signInWithOtp(
        phone: formattedPhoneNumber,
      );

      // Record successful OTP request for rate limiting
      rateLimiter.recordOtpRequest(formattedPhoneNumber);

      AuthLogger.debug(
        'Phone OTP sent successfully to $formattedPhoneNumber',
        tag: 'PhoneAuth',
      );

      phoneAuthManager.update(() {
        phoneAuthManager.phoneAuthError = null;
      });

      // CRITICAL: Call the onCodeSent callback to navigate to verification page
      AuthLogger.debug('OTP sent successfully, calling onCodeSent callback',
          tag: 'PhoneAuth');
      if (context.mounted) {
        onCodeSent(context);
      }
    } on AuthException catch (e) {
      AuthLogger.error('Phone OTP request failed', tag: 'PhoneAuth', error: e);

      // Log the specific exception type
      if (e is AuthWeakPasswordException) {
        AuthLogger.error(
          'ERROR: Password validation triggered for phone OTP (this should not happen). '
          'Please check Supabase project authentication settings. '
          'Phone OTP authentication should NOT require passwords.',
          tag: 'PhoneAuth',
        );
      }

      phoneAuthManager.update(() {
        phoneAuthManager.phoneAuthError = e;
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
      // Use provided phoneNumber, or fallback to currentUser's phone, or from app state
      final phone =
          phoneNumber ?? currentUser?.phoneNumber ?? FFAppState().phone;

      if (phone.isEmpty) {
        AuthLogger.error(
          'No phone number available for SMS verification',
          tag: 'PhoneAuth',
        );
        throw Exception('Phone number is required for SMS verification');
      }

      AuthLogger.debug(
        'Verifying SMS code for phone: $phone',
        tag: 'PhoneAuth',
      );

      final response = await Supabase.instance.client.auth.verifyOTP(
        phone: phone,
        token: smsCode,
        type: OtpType.sms,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        // Ensure a profile exists for this user
        // Check if profile already exists
        try {
          await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', userId)
              .single();

          AuthLogger.debug('Profile already exists for user $userId',
              tag: 'PhoneAuth');

          // If this is a new sign-in (not from signup flow), no need to update
          // The profile should already have the correct role
        } catch (e) {
          // Profile doesn't exist, create one
          AuthLogger.debug('Creating new profile for user $userId',
              tag: 'PhoneAuth');

          try {
            // Use the role from signup flow (tempsignuprole), default to 'client'
            final roleToUse = FFAppState().tempsignuprole.isNotEmpty
                ? FFAppState().tempsignuprole
                : 'client';

            await Supabase.instance.client.from('profiles').insert({
              'id': userId,
              'role': roleToUse,
              'phone_number':
                  phone, // Use the input phone, not response.user!.phone
              'is_profile_complete': false,
            });

            AuthLogger.debug(
                'Profile created successfully for $userId with role: $roleToUse',
                tag: 'PhoneAuth');
          } catch (insertError) {
            AuthLogger.error(
                'Failed to create profile after phone verification',
                tag: 'PhoneAuth',
                error: insertError);
            // Don't fail the auth - the profile will be created on next update
          }
        }

        // Clear rate limit data after successful verification
        if (response.user?.phone != null) {
          OtpRateLimiter().clearPhoneNumber(response.user!.phone!);
        }
        // Sync SHPH API tokens for REST mode (if enabled)
        try {
          await ShphAuthBridge.instance.syncAfterPhoneSignIn(phone, smsCode);
        } catch (_) {}
        return currentUser;
      }
      return null;
    } on AuthException catch (e) {
      AuthLogger.error('SMS code verification failed',
          tag: 'PhoneAuth', error: e);
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Verification failed. Please check the code and try again.')),
      );
      return null;
    }
  }

  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<AuthResponse> Function() signInFunc,
    String authProvider,
  ) async {
    try {
      final response = await signInFunc();

      if (response.user != null) {
        final user = SerbisyoHubPHSupabaseUser.fromUser(response.user);
        currentUser = user;
        return user;
      }
      return null;
    } on AuthException catch (e) {
      AuthLogger.error('Authentication failed', tag: authProvider, error: e);

      /// Use generic error messages to prevent email enumeration attacks and
      /// information disclosure about account existence or auth state
      const errorMsg =
          'Authentication failed. Please check your credentials and try again.';

      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(errorMsg)),
      );
      return null;
    } catch (e) {
      AuthLogger.error('Unexpected error during authentication',
          tag: authProvider, error: e);
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An unexpected error occurred. Please try again.')),
      );
      return null;
    }
  }

  /// Formats phone number to E.164 format (required by Supabase)
  /// Examples:
  ///   9123456789 -> +639123456789 (Philippines default)
  ///   09123456789 -> +639123456789 (removes leading 0)
  ///   +639123456789 -> +639123456789 (already formatted)
  String _formatToE164(String phoneNumber) {
    // Remove all non-numeric characters except leading +
    var cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // If it starts with +, assume it's already in E.164 format
    if (cleaned.startsWith('+')) {
      return cleaned;
    }

    // If it starts with 0 (common in Philippines), replace with country code
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // Add Philippines country code (+63) if not present
    // This is a default for your use case; adjust as needed
    if (!cleaned.startsWith('63')) {
      cleaned = '63$cleaned';
    }

    return '+$cleaned';
  }

  /// Validates if a phone number is in valid E.164 format
  /// E.164 format: +[country code][number]
  /// - Must start with +
  /// - Must have country code (1-3 digits)
  /// - Must have at least 6-15 digits total (excluding +)
  bool _isValidE164Format(String phoneNumber) {
    // Check if starts with +
    if (!phoneNumber.startsWith('+')) {
      return false;
    }

    // Remove + and check if all remaining are digits
    final digitsOnly = phoneNumber.substring(1);
    if (!RegExp(r'^\d{7,15}$').hasMatch(digitsOnly)) {
      return false;
    }

    return true;
  }

  /// Syncs SHPH API tokens after successful social OAuth login.
  ///
  /// Calls ShphAuthBridge to exchange Supabase session for SHPH JWT tokens.
  /// Errors are silently caught to not disrupt the login flow.
  void _syncShphTokenAfterSocialLogin(String provider) {
    // Schedule on next frame to avoid async gaps with BuildContext
    Future.microtask(() {
      try {
        // For social OAuth, we use the Supabase JWT to authenticate with SHPH API
        ShphAuthBridge.instance.syncAfterSocialSignIn(provider);
      } catch (e) {
        // Log but don't fail - SHPH sync is optional for authentication
        AuthLogger.debug(
          'SHPH token sync failed after $provider OAuth: $e',
          tag: 'SocialSignInSync',
        );
      }
    });
  }
}
