import 'package:flutter/foundation.dart';

import '/api/resources/auth_api.dart';
import '/api/resources/users_api.dart';
import '/api/shph_token_storage.dart';
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
    final data = await _authApi.login(email: email, password: password);
    _currentUser = data;
    _status = AuthStatus.authenticated;
    notifyListeners();
    return data;
  }

  Future<Map<String, dynamic>> registerInitiate({
    required Map<String, dynamic> payload,
  }) =>
      _authApi.registerInitiate(payload: payload);

  Future<Map<String, dynamic>> registerVerify({
    required Map<String, dynamic> payload,
  }) async {
    final data = await _authApi.registerVerify(payload: payload);
    _currentUser = data;
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
