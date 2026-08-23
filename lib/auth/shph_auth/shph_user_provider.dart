import '/auth/base_auth_user_provider.dart';

export '../base_auth_user_provider.dart';

class SerbisyoHubPHShphUser extends BaseAuthUser {
  SerbisyoHubPHShphUser(this.userData);

  final Map<String, dynamic>? userData;

  @override
  bool get loggedIn => userData != null;

  @override
  bool get emailVerified => userData?['email_verified'] == true;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: userData?['id']?.toString(),
        email: userData?['email'] as String?,
        displayName: userData?['display_name'] as String?,
        photoUrl: userData?['photo_url'] as String?,
        phoneNumber: userData?['phone'] as String?,
      );

  @override
  Future? delete() async {
    // SHPH API user deletion not implemented yet
    return null;
  }

  @override
  Future? updateEmail(String email) async {
    // SHPH API email update not implemented yet
    return null;
  }

  @override
  Future? updatePassword(String newPassword) async {
    // SHPH API password update not implemented yet
    return null;
  }

  @override
  Future? sendEmailVerification() async {
    // SHPH API email verification not implemented yet
    return null;
  }

  @override
  Future refreshUser() async {
    // SHPH API refresh would re-fetch /api/auth/me/
    return;
  }

  static BaseAuthUser fromMap(Map<String, dynamic>? data) =>
      SerbisyoHubPHShphUser(data);
}
