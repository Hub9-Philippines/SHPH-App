import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import '/api/shph_api.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/token_refresh_manager.dart';
import '/router/app_router.dart';
import '/theme/app_theme.dart';
// Authentication imports - Using Supabase for auth
import 'auth/auth_manager_factory.dart';
import 'auth/supabase_auth/auth_util.dart';
import 'auth/supabase_auth/supabase_user_provider.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import 'l10n/app_localizations.dart';
import 'services/error_handler.dart';
import 'services/logging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  // Initialize Supabase
  await SupaFlow.initialize();

  // Initialize SHPH REST API client (OpenAPI-backed Dio layer)
  try {
    await initializeShphApi();
  } catch (e) {
    // API unreachable — all callers fall back to Supabase gracefully.
    LoggingService.debug('SHPH API init skipped: $e', tag: 'main');
  }

  // Restore current auth session from local storage
  final supabaseUser = Supabase.instance.client.auth.currentUser;
  if (supabaseUser != null) {
    // Set the global current user immediately so auth state is correct on app start
    currentUser = SerbisyoHubPHSupabaseUser(supabaseUser);
  }

  // Initialize Auth Manager - Using Supabase for authentication
  AuthManagerFactory.initialize(AuthProvider.supabase);

  await AppTheme.initialize();

  final appState = FFAppState();
  await appState.initializePersistedState();

  runApp(MyApp(appState: appState));
}

class MyApp extends StatefulWidget {
  const MyApp({
    required this.appState,
    super.key,
  });
  final FFAppState appState;

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = AppTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  Locale _locale = const Locale('en', '');

  String getRoute([RouteMatch? routeMatch]) {
    final lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e as RouteMatch?))
          .toList();
  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router =
        AppRouter.createRouter(_appStateNotifier, appState: widget.appState);

    // Use Supabase user stream for auth state management
    userStream = serbisyoHubPHSupabaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });

    // Start automatic token refresh monitoring (Fix #5: Token Refresh Interceptor)
    TokenRefreshManager().startTokenRefreshMonitoring();

    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );

    widget.appState.addListener(_onAppStateChanged);
    _syncLocale();
  }

  void _onAppStateChanged() {
    _syncLocale();
  }

  void _syncLocale() {
    final localeString = widget.appState.locale;
    final parts = localeString.split('_');
    final newLocale = Locale(parts.first, parts.length > 1 ? parts.last : '');
    if (newLocale != _locale) {
      safeSetState(() => _locale = newLocale);
    }
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        AppTheme.saveThemeMode(mode);
      });

  List<Locale> get _supportedLocales => const [
        Locale('en', ''),
        Locale('es', ''),
        Locale('fr', ''),
        Locale('de', ''),
        Locale('it', ''),
        Locale('pt', ''),
        Locale('zh', ''),
        Locale('ja', ''),
        Locale('ko', ''),
        Locale('ar', ''),
      ];

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<FFAppState>.value(
        value: widget.appState,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'SerbisyoHub PH',
          locale: _locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: _supportedLocales,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: false,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: false,
          ),
          themeMode: _themeMode,
          routerConfig: _router,
          scaffoldMessengerKey: ErrorHandler.scaffoldMessengerKey,
        ),
      );
}

class NavBarPage extends StatefulWidget {
  const NavBarPage({
    Key? key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  }) : super(key: key);

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'Home';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  Widget _buildMessagesIcon(BuildContext context) {
    final count = FFAppState().unreadConversations;
    if (count <= 0) {
      return const Icon(Icons.chat_outlined, size: 24);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.chat_outlined, size: 24),
        Positioned(
          top: -4,
          right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.of(context).error,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'Home': const HomeWidget(),
      'Category': const CategoryWidget(),
      'Bookings': const BookingsWidget(),
      'Messages': const MessagesWidget(),
      'Profile': const ProfileWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: ListenableBuilder(
        listenable: FFAppState(),
        builder: (context, _) => BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => safeSetState(() {
            _currentPage = null;
            _currentPageName = tabs.keys.toList()[i];
          }),
          backgroundColor: AppTheme.of(context).primaryBackground,
          selectedItemColor: AppTheme.of(context).primary,
          unselectedItemColor: AppTheme.of(context).secondaryText,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                size: 24,
              ),
              label: 'Home',
              tooltip: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.grid_view_outlined,
                size: 24,
              ),
              label: 'Category',
              tooltip: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.content_paste_rounded,
                size: 24,
              ),
              label: 'Bookings',
              tooltip: '',
            ),
            BottomNavigationBarItem(
              icon: _buildMessagesIcon(context),
              label: 'Messages',
              tooltip: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 24,
              ),
              label: 'Profile',
              tooltip: '',
            )
          ],
        ),
      ),
    );
  }
}
