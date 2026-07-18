import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '/api/resources/auth_api.dart';
import '/api/resources/users_api.dart';
import '/api/shph_token_storage.dart';
import '/services/logging_service.dart';
import '../base_auth_user_provider.dart';

export '../base_auth_user_provider.dart';

/// User model backed by the SHPH REST API.
///
/// Wraps the user data map returned by
/// `/api/auth/me/` and delegates profile mutations to the SHPH API.
class ShphUser extends BaseAuthUser {
  ShphUser(this._data);

  final Map<String, dynamic> _data;

  @override
  bool get loggedIn => _data.isNotEmpty;

  @override
  bool get emailVerified =>
      (_data['is_email_verified'] as bool?) ??
      (_data['email_verified'] as bool?) ??
      true;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: (_data['id'] ?? _data['user_id'])?.toString(),
        email: _data['email'] as String?,
        displayName: _data['display_name'] as String?,
        photoUrl: _data['photo_url'] as String?,
        phoneNumber: _data['phone_number'] as String?,
      );

  @override
  Future? delete() async {
    try {
      await ShphUsersApi.instance.deleteMe();
      await ShphTokenStorage.clear();
    } catch (e) {
      LoggingService.error('Failed to delete user: $e', tag: 'ShphUser');
      rethrow;
    }
  }

  @override
  Future? updateEmail(String email) async {
    try {
      await ShphUsersApi.instance.updateMe({'email': email});
      _data['email'] = email;
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  @override
  Future? updatePassword(String newPassword) async {
    try {
      await ShphUsersApi.instance.updateMe({'password': newPassword});
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  @override
  Future? sendEmailVerification() async {
    // The SHPH API handles email verification during registration.
    // This is a no-op for existing users in the current API.
  }

  @override
  Future refreshUser() async {
    try {
      final fresh = await ShphAuthApi.instance.getCurrentUser();
      _data
        ..clear()
        ..addAll(fresh);
    } catch (e) {
      LoggingService.error('Failed to refresh user: $e', tag: 'ShphUser');
    }
  }

  static BaseAuthUser fromData(Map<String, dynamic> data) => ShphUser(data);
}

/// Auth state stream backed by SHPH API token storage.
///
/// Emits [ShphUser] instances when the token state changes (login/logout).
/// Replaces [shphUserStream].
final _shphAuthController = StreamController<BaseAuthUser>.broadcast();

void notifyShphAuthChanged(BaseAuthUser user) {
  currentUser = user;
  _shphAuthController.add(user);
}

Stream<BaseAuthUser> shphUserStream() =>
    _shphAuthController.stream.debounce((user) => user.loggedIn
        ? Stream.value(user)
        : TimerStream(user, const Duration(seconds: 1)));
