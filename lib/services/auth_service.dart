import 'package:flutter/foundation.dart';

import '/api/resources/auth_api.dart';
import '/api/resources/users_api.dart';
import '/api/shph_token_storage.dart';
import '/services/device_info_service.dart';
import '/services/logging_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ShphAuthApi _authApi = ShphAuthApi.instance;
  final _usersApi = ShphUsersApi.instance;

  ShphAuthApi get authApi => _authApi;

  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get userId => _currentUser?['id']?.toString();
  String? get email => _currentUser?['email'] as String?;
  String? get displayName => _currentUser?['display_name'] as String?;

  /// Pending two-step registration state (set by [registerInitiate], consumed
  /// by the OTP/verify step).
  String? _pendingDeliveryMethod;
  String? _pendingPhone;
  String? _pendingEmail;
  String? get pendingDeliveryMethod => _pendingDeliveryMethod;
  String? get pendingPhone => _pendingPhone;
  String? get pendingEmail => _pendingEmail;

  /// Clears the pending two-step registration state after verification (or
  /// logout), so later phone-login flows are not mistaken for registration.
  void clearPendingRegistration() {
    _pendingDeliveryMethod = null;
    _pendingPhone = null;
    _pendingEmail = null;
  }

  Future<void> initialize() async {
    final token = await ShphTokenStorage.getAccessToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      return;
    }
    try {
      _currentUser = await _authApi.getCurrentUser();
      _status = AuthStatus.authenticated;
    } catch (e) {
      await ShphTokenStorage.clear();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final deviceInfo = await DeviceInfoService.instance.getDeviceInfo();
    final data = await _authApi.login(
      email: email,
      password: password,
      deviceInfo: deviceInfo,
    );
    _currentUser = data['user'] as Map<String, dynamic>? ?? data;
    _status = AuthStatus.authenticated;
    notifyListeners();
    return data;
  }

  Future<Map<String, dynamic>> registerInitiate({
    required Map<String, dynamic> payload,
  }) async {
    final data = await _authApi.registerInitiate(payload: payload);
    _pendingDeliveryMethod = data['delivery_method'] as String?;
    _pendingPhone = payload['phone_number'] as String?;
    _pendingEmail = payload['email'] as String?;
    return data;
  }

  Future<Map<String, dynamic>> registerVerify({
    required Map<String, dynamic> payload,
  }) async {
    final data = await _authApi.registerVerify(payload: payload);
    _currentUser = data['user'] as Map<String, dynamic>? ?? data;
    _status = AuthStatus.authenticated;
    notifyListeners();
    return data;
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (e) {
      LoggingService.info('Logout API call failed (may already be logged out): $e');
    }
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    clearPendingRegistration();
    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    try {
      _currentUser = await _authApi.getCurrentUser();
      notifyListeners();
    } catch (e) {
      LoggingService.error('Failed to refresh current user: $e');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _usersApi.updateMe(data);
    await refreshCurrentUser();
  }

  Future<String?> uploadPhoto(List<int> fileBytes, String fileName) async {
    final result = await _usersApi.uploadPhoto(fileBytes, fileName);
    await refreshCurrentUser();
    return result['photo_url'] as String?;
  }
}
