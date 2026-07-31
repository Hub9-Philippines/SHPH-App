import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import '/auth/auth_manager.dart';
import 'shph_user_provider.dart';

class ShphAuthManager extends AuthManager
    with EmailSignInManager, PhoneSignInManager {
  final _authService = AuthService.instance;

  @override
  Future signOut() async {
    await _authService.logout();
  }

  @override
  Future deleteUser(BuildContext context) async {
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _authService.authApi.requestPasswordReset(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final data = await _authService.login(email: email, password: password);
      final userMap = data['user'] as Map<String, dynamic>? ?? data;
      final user = SerbisyoHubPHShphUser(userMap);
      currentUser = user;
      return user;
    } catch (e) {
      debugPrint('Sign in failed: $e');
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
      final data = await _authService.authApi.registerInitiate(
        payload: {'email': email, 'password': password},
      );
      final userMap = data['user'] as Map<String, dynamic>? ?? data;
      final user = SerbisyoHubPHShphUser(userMap);
      currentUser = user;
      return user;
    } catch (e) {
      debugPrint('Create account failed: $e');
      return null;
    }
  }

  @override
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    await _authService.authApi.sendOtpPin(
      payload: {'phone': phoneNumber},
    );
    onCodeSent(context);
  }

  @override
  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
    String? phoneNumber,
  }) async {
    try {
      final data = await _authService.authApi.verifyOtpPin(
        payload: {
          'pin': smsCode,
          if (phoneNumber != null) 'phone': phoneNumber,
        },
      );
      final userMap = data['user'] as Map<String, dynamic>? ?? data;
      final user = SerbisyoHubPHShphUser(userMap);
      currentUser = user;
      return user;
    } catch (e) {
      debugPrint('SMS verify failed: $e');
      return null;
    }
  }
}
