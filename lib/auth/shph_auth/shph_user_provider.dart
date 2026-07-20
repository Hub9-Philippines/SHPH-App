import '/api/shph_api.dart';
import '../base_auth_user_provider.dart';

class SerbisyoHubPHShphUser extends BaseAuthUser {
  SerbisyoHubPHShphUser(this._data);

  final Map<String, dynamic> _data;

  @override
  bool get loggedIn => _data.isNotEmpty;

  @override
  bool get emailVerified => _data['is_email_verified'] == true;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: _data['id']?.toString(),
        email: _data['email'] as String?,
        displayName: _data['display_name'] as String? ??
            _data['displayName'] as String?,
        photoUrl: _data['photo_url'] as String? ??
            _data['photoUrl'] as String?,
        phoneNumber: _data['phone_number'] as String? ??
            _data['phoneNumber'] as String?,
      );

  @override
  Future? delete() async {
    try {
      await ShphUsersApi.instance.deleteMe();
    } catch (_) {}
  }

  @override
  Future? updateEmail(String email) async {
    await ShphUsersApi.instance.updateMe({'email': email});
    await refreshUser();
  }

  @override
  Future? updatePassword(String newPassword) async {
    await ShphAuthApi.instance.confirmPasswordReset(
      payload: {'password': newPassword, 'confirm_password': newPassword},
    );
  }

  @override
  Future? sendEmailVerification() async {
    // SHPH API handles verification on registration; no separate endpoint.
  }

  @override
  Future refreshUser() async {
    try {
      final data = await ShphUsersApi.instance.getMe();
      _data.clear();
      _data.addAll(data);
    } catch (_) {}
  }

  factory SerbisyoHubPHShphUser.fromData(Map<String, dynamic> data) =>
      SerbisyoHubPHShphUser(Map<String, dynamic>.from(data));
}

Stream<BaseAuthUser> serbisyoHubPHShphUserStream() async* {
  try {
    final hasToken = await ShphTokenStorage.hasAccessToken();
    if (!hasToken) {
      yield SerbisyoHubPHShphUser({});
      return;
    }

    final data = await ShphUsersApi.instance.getMe();
    yield SerbisyoHubPHShphUser.fromData(data);
  } catch (_) {
    yield SerbisyoHubPHShphUser({});
  }

  // Poll every 60s for token state changes (no push stream from REST API).
  await for (final _ in Stream.periodic(const Duration(seconds: 60))) {
    final hasToken = await ShphTokenStorage.hasAccessToken();
    if (!hasToken) {
      yield SerbisyoHubPHShphUser({});
      return;
    }
  }
}
