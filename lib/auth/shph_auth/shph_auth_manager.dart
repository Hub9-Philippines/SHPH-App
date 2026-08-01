import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import '/services/device_info_service.dart';
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
    final mapped = _mapSignupRole(role);
    final deviceInfo = await DeviceInfoService.instance.getDeviceInfo();
    await _authService.registerInitiate(
      payload: {
        if (firstName != null) 'first_name': firstName,
        if (middleName != null && middleName.isNotEmpty) 'middle_name': middleName,
        if (lastName != null) 'last_name': lastName,
        'email': email,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        'password': password,
        'role': mapped.role,
        if (mapped.isProvider != null) 'is_provider': mapped.isProvider,
        if (mapped.isClient != null) 'is_client': mapped.isClient,
        'device_info': deviceInfo,
      },
    );
    // Session completes only after the OTP verify step (registerVerify).
    return null;
  }

  /// Maps the SignOptions selection (`client`/`pro`/`provider`/`both`) onto the
  /// backend register payload, matching web `RegisterPage.vue`:
  ///   - client   → role: client
  ///   - provider → role: provider
  ///   - both     → role: provider + is_provider + is_client flags
  ({String role, bool? isProvider, bool? isClient}) _mapSignupRole(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'pro':
      case 'provider':
        return (role: 'provider', isProvider: null, isClient: null);
      case 'both':
        return (role: 'provider', isProvider: true, isClient: true);
      case 'client':
      default:
        return (role: 'client', isProvider: null, isClient: null);
    }
  }

  @override
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  }) async {
    await _authService.authApi.phoneLoginSend(
      phoneNumber: phoneNumber,
    );
    onCodeSent(context);
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
}
