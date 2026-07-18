import 'auth_manager.dart';
import 'shph_auth/shph_auth_manager.dart';

enum AuthProvider {
  shph,
}

// ignore: avoid_classes_with_only_static_members
class AuthManagerFactory {
  static late AuthManager _instance;
  static AuthProvider _currentProvider = AuthProvider.shph;

  static void initialize(AuthProvider provider) {
    _currentProvider = provider;
    switch (provider) {
      case AuthProvider.shph:
        _instance = ShphAuthManager();
        break;
    }
  }

  static AuthManager get instance => _instance;

  static AuthProvider get currentProvider => _currentProvider;

  static bool get isShph => _currentProvider == AuthProvider.shph;

  static void setProvider(AuthProvider provider) {
    initialize(provider);
  }
}
