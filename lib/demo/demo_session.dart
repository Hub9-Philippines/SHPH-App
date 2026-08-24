import 'package:go_router/go_router.dart';

import '/demo/demo_data.dart';
import '/services/auth_service.dart';

class DemoSession {
  DemoSession._();

  static GoRouter? router;

  static void install(AuthService auth) {
    if (!auth.isAuthenticated) {
      auth.adoptUser(DemoData.clientUser);
    } else {
      DemoData.currentRole = auth.isProvider ? 'provider' : 'client';
    }
  }

  static void switchRole(String role) {
    if (role != 'client' && role != 'provider') return;
    DemoData.currentRole = role;
    AuthService.instance.adoptUser(
      role == 'provider' ? DemoData.providerUser : DemoData.clientUser,
    );
    router?.go('/');
  }
}
