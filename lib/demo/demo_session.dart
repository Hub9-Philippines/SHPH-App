import '/demo/demo_data.dart';
import '/services/auth_service.dart';

class DemoSession {
  DemoSession._();

  static void install(AuthService auth) {
    DemoData.currentRole = 'client';
    if (!auth.isAuthenticated) {
      auth.adoptUser(DemoData.clientUser);
    }
  }
}
