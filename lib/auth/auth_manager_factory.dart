import 'auth_manager.dart';
import 'shph_auth/shph_auth_manager.dart';
import 'supabase_auth/supabase_auth_manager.dart';

enum AuthProvider {
  supabase,
  shph,
}

class AuthManagerFactory {
  static late AuthManager _instance;
  static AuthProvider _currentProvider = AuthProvider.shph;

  static void initialize(AuthProvider provider) {
    _currentProvider = provider;
    switch (provider) {
      case AuthProvider.supabase:
        _instance = SupabaseAuthManager();
        break;
      case AuthProvider.shph:
        _instance = ShphAuthManager();
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
