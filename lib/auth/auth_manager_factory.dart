import 'auth_manager.dart';
import 'supabase_auth/supabase_auth_manager.dart';

enum AuthProvider {
  supabase,
}

class AuthManagerFactory {
  static late AuthManager _instance;
  static AuthProvider _currentProvider = AuthProvider.supabase;

  static void initialize(AuthProvider provider) {
    _currentProvider = provider;
    switch (provider) {
      case AuthProvider.supabase:
        _instance = SupabaseAuthManager();
        break;
    }
  }

  static AuthManager get instance => _instance;

  static AuthProvider get currentProvider => _currentProvider;

  static bool get isSupabase => _currentProvider == AuthProvider.supabase;

  static void setProvider(AuthProvider provider) {
    initialize(provider);
  }
}
