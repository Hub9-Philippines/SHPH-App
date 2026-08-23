import 'base_auth_user_provider.dart';

class TestAuthUser extends BaseAuthUser {
  TestAuthUser({required this.testUid, this.testPhone});

  final String testUid;
  final String? testPhone;

  @override
  bool get loggedIn => true;

  @override
  bool get emailVerified => true;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: testUid,
        phoneNumber: testPhone,
      );

  @override
  Future? delete() => null;

  @override
  Future? updateEmail(String email) => null;

  @override
  Future? updatePassword(String newPassword) => null;

  @override
  Future? sendEmailVerification() => null;
}