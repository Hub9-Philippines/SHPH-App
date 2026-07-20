import 'package:rxdart/rxdart.dart';
import '/auth/base_auth_user_provider.dart';
import '/backend/supabase/supabase.dart';

export '../base_auth_user_provider.dart';

class SerbisyoHubPHSupabaseUser extends BaseAuthUser {
  SerbisyoHubPHSupabaseUser(this.user);

  final User? user;

  @override
  bool get loggedIn => user != null;

  @override
  bool get emailVerified => user?.emailConfirmedAt != null;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: user?.id,
        email: user?.email,
        displayName: user?.userMetadata?['display_name'],
        photoUrl: user?.userMetadata?['avatar_url'],
        phoneNumber: user?.phone,
      );

  @override
  Future? delete() async {
    if (user == null) return null;
    return Supabase.instance.client.auth.admin.deleteUser(user!.id);
  }

  @override
  Future? updateEmail(String email) async {
    if (user == null) return null;
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: email),
      );
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  @override
  Future? updatePassword(String newPassword) async {
    if (user == null) return null;
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  @override
  Future? sendEmailVerification() async {
    if (user == null || user!.email == null) {
      throw Exception('No email to verify');
    }

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: user!.email!,
      );
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  @override
  Future refreshUser() async {
    if (user == null) return;
    try {
      await Supabase.instance.client.auth.refreshSession();
    } catch (e) {
      throw Exception('Failed to refresh user session: $e');
    }
  }

  static BaseAuthUser fromUser(User? user) => SerbisyoHubPHSupabaseUser(user);
}

Stream<BaseAuthUser> serbisyoHubPHSupabaseUserStream() => Supabase.instance.client
    .auth
    .onAuthStateChange
    .debounce((event) => event.session?.user == null
        ? TimerStream(true, const Duration(seconds: 1))
        : Stream.value(event))
    .map<BaseAuthUser>((event) {
      currentUser = SerbisyoHubPHSupabaseUser(event.session?.user);
      return currentUser!;
    });
