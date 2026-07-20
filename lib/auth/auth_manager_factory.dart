import 'auth_manager.dart';
import 'shph_auth/shph_auth_manager.dart';

enum AuthProvider { shph }

class AuthManagerFactory {
  static late AuthManager _instance;
  static AuthProvider _currentProvider = AuthProvider.shph;

  static void initialize(AuthProvider provider) {
    _currentProvider = provider;
    _instance = ShphAuthManager();
  }

  static AuthManager get instance => _instance;

  static AuthProvider get currentProvider => _currentProvider;

  static void setProvider(AuthProvider provider) {
    initialize(provider);
  }
}
