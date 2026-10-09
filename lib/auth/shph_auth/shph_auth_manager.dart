import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../auth_manager.dart';
import '/auth/base_auth_user_provider.dart';

import '/services/auth_service.dart';
import '/api/resources/auth_api.dart';
import '/api/api_config.dart';
import 'shph_user_provider.dart';

export '/auth/base_auth_user_provider.dart';

class ShphAuthManager extends AuthManager with EmailSignInManager, PhoneSignInManager {
  ShphAuthManager._();

  static final ShphAuthManager instance = ShphAuthManager._();

  factory ShphAuthManager() => instance;

  final AuthService _authService = AuthService.instance;

  @override
  Future signOut() async {
    await _authService.logout();
    currentUser = null;
  }

  @override
  Future deleteUser(BuildContext context) async {
    // Account deletion handled via profile endpoint
  }

  @override
  Future updateEmail({required String email, required BuildContext context}) async {
    // Email update handled via profile edit
  }

  @override
  Future resetPassword({required String email, required BuildContext context}) async {
    await _authService.authApi.requestPasswordReset(email: email);
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    final data = await _authService.login(email: email, password: password);
    final userMap = data['user'] as Map<String, dynamic>? ?? data;
    final user = SerbisyoHubPHShphUser(userMap);
    currentUser = user;
    return user;
  }

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context, {
    required String email,
    required String password,
    String? firstName,
    String? middleName,
    String? lastName,
    String? phoneNumber,
    String role = 'client',
  }) async {
    final res = await initiateRegistration(
      firstName: firstName ?? '',
      middleName: middleName,
      lastName: lastName ?? '',
      email: email,
      phoneNumber: phoneNumber ?? '',
      password: password,
      role: role,
    );
    final userMap = res['user'] as Map<String, dynamic>? ?? res;
    if (res['token'] != null || res['access'] != null) {
      final user = SerbisyoHubPHShphUser(userMap);
      currentUser = user;
      return user;
    }
    return null;
  }

  /// Initiates the two-step registration flow.
  Future<Map<String, dynamic>> initiateRegistration({
    required String firstName,
    String? middleName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    String role = 'client',
  }) async {
    return _authService.registerInitiate(
      payload: {
        'first_name': firstName,
        if (middleName != null && middleName.isNotEmpty) 'middle_name': middleName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'role': role,
      },
    );
  }

  /// Completes the two-step registration by verifying the OTP pin.
  Future<BaseAuthUser?> verifyRegistration({
    required String phoneNumber,
    required String pin,
  }) async {
    final data = await _authService.registerVerify(
      payload: {'phone_number': phoneNumber, 'pin': pin},
    );
    final userMap = data['user'] as Map<String, dynamic>? ?? data;
    final user = SerbisyoHubPHShphUser(userMap);
    currentUser = user;
    return user;
  }

  @override
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    await _authService.authApi.sendOtpPin(phoneNumber: phoneNumber);
    if (context.mounted) {
      onCodeSent(context);
    }
  }

  @override
  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
    String? phoneNumber,
  }) async {
    final data = await _authService.authApi.phoneLoginVerify(
      phoneNumber: phoneNumber ?? '',
      pin: smsCode,
    );
    final userMap = data['user'] as Map<String, dynamic>? ?? data;
    _authService.adoptUser(userMap);
    final user = SerbisyoHubPHShphUser(userMap);
    currentUser = user;
    return user;
  }

  bool _isGoogleInitialized = false;

  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) async {
    try {
      if (!_isGoogleInitialized) {
        final serverClientId = ApiConfig.googleServerClientId;
        await GoogleSignIn.instance.initialize(
          serverClientId: serverClientId.isNotEmpty ? serverClientId : null,
        );
        _isGoogleInitialized = true;
      }
      final googleUser = await GoogleSignIn.instance.authenticate();

      final email = googleUser.email;
      final name = googleUser.displayName ?? 'Google User';

      final check = await _authService.authApi.checkAccount(identifier: email);
      if (check['exists'] == true) {
        final data = await _authService.authApi.authGoogle(email: email, name: name);
        final userMap = data['user'] as Map<String, dynamic>? ?? data;
        _authService.adoptUser(userMap);
        final user = SerbisyoHubPHShphUser(userMap);
        currentUser = user;
        return user;
      } else {
        return SerbisyoHubPHShphUser({
          'pending_oauth': true,
          'email': email,
          'name': name,
          'method': 'google',
        });
      }
    } catch (e) {
      debugPrint('[GoogleSignIn] Error: $e');
      return null;
    }
  }

  Future<BaseAuthUser?> signInWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final email = credential.email ?? 'user_${DateTime.now().millisecondsSinceEpoch}@privaterelay.appleid.com';
      final givenName = credential.givenName ?? '';
      final familyName = credential.familyName ?? '';
      final name = '$givenName $familyName'.trim();
      final displayName = name.isNotEmpty ? name : 'Apple User';

      final check = await _authService.authApi.checkAccount(identifier: email);
      if (check['exists'] == true) {
        final data = await _authService.authApi.authApple(email: email, name: displayName);
        final userMap = data['user'] as Map<String, dynamic>? ?? data;
        _authService.adoptUser(userMap);
        final user = SerbisyoHubPHShphUser(userMap);
        currentUser = user;
        return user;
      } else {
        return SerbisyoHubPHShphUser({
          'pending_oauth': true,
          'email': email,
          'name': displayName,
          'method': 'apple',
        });
      }
    } catch (e) {
      debugPrint('[AppleSignIn] Error: $e');
      return null;
    }
  }
}
