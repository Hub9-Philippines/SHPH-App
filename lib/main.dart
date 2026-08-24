import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import '/api/shph_api.dart';
import '/flutter_flow/token_refresh_manager.dart';
import '/router/app_router.dart';
import '/theme/app_theme.dart';
// Authentication imports - Using SHPH API for auth
import 'auth/auth_manager_factory.dart';
import 'auth/auth_util.dart';
import 'auth/shph_auth/shph_user_provider.dart';
import 'components/connectivity_banner.dart';
import 'components/demo_role_switcher.dart';
import 'demo/demo_mode.dart';
import 'demo/demo_session.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'index.dart';
import 'l10n/app_localizations.dart';
import 'services/auth_service.dart';
import 'services/connectivity_service.dart';
import 'services/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  // Initialize SHPH REST API client (OpenAPI-backed Dio layer)
  await initializeShphApi();

  // Initialize Auth Manager - Using SHPH API for authentication
  AuthManagerFactory.initialize(AuthProvider.shph);

  // Restore current auth session from local storage
  final shphAuth = AuthService.instance;
  await shphAuth.initialize();
  if (kDemoMode) {
    DemoSession.install(shphAuth);
  }
  if (shphAuth.isAuthenticated) {
    currentUser = SerbisyoHubPHShphUser(shphAuth.currentUser);
  }

  await AppTheme.initialize();

  final appState = FFAppState();
  await appState.initializePersistedState();

  final connectivityService = ConnectivityService();

  runApp(
    MyApp(
      appState: appState,
      connectivityService: connectivityService,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    required this.appState,
    this.connectivityService,
    super.key,
  });
  final FFAppState appState;
  final ConnectivityService? connectivityService;

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


  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router =
        AppRouter.createRouter(_appStateNotifier, appState: widget.appState);
    if (kDemoMode) {
      DemoSession.router = _router;
    }

    // Listen to SHPH API auth state changes
    AuthService.instance.addListener(_onAuthChanged);
    _emitCurrentUser();

    // Start automatic token refresh monitoring (Fix #5: Token Refresh Interceptor)
    TokenRefreshManager().startTokenRefreshMonitoring();

    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );

    widget.appState.addListener(_onAppStateChanged);
    _syncLocale();
  }

  void _onAuthChanged() {
    _emitCurrentUser();
  }

  void _emitCurrentUser() {
    final svc = AuthService.instance;
    FFAppState().isProvider = svc.isProvider;
    currentUser = svc.isAuthenticated
        ? SerbisyoHubPHShphUser(svc.currentUser) as BaseAuthUser
        : SerbisyoHubPHShphUser(null);
    _appStateNotifier.update(currentUser!);
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
    AuthService.instance.removeListener(_onAuthChanged);
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
        child: ChangeNotifierProvider<ConnectivityService>.value(
          value: widget.connectivityService ?? ConnectivityService(),
          child: Consumer<ConnectivityService>(
            builder: (context, connectivity, _) {
              return MaterialApp.router(
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
                builder: (context, child) {
                  return Stack(
                    children: [
                      child ?? const SizedBox.shrink(),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ConnectivityBanner(
                          isOffline: connectivity.isOffline,
                        ),
                      ),
                      if (kDemoMode)
                        const Positioned(
                          left: 0,
                          bottom: 0,
                          child: DemoRoleSwitcher(),
                        ),
                    ],
                  );
                },
              );
            },
          ),
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

  Map<String, Widget> get _tabs => const {
        'Home': HomeWidget(),
        'Explore': ExploreWidget(),
        'Bookings': BookingsWidget(),
        'Messages': MessagesWidget(),
        'Profile': ProfileWidget(),
      };

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

  List<BottomNavigationBarItem> _buildNavItems(BuildContext context) =>
      const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          label: 'Home',
          tooltip: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined, size: 24),
          label: 'Explore',
          tooltip: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.content_paste_outlined, size: 24),
          label: 'Bookings',
          tooltip: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_outlined, size: 24),
          label: 'Messages',
          tooltip: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          label: 'Profile',
          tooltip: '',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: ListenableBuilder(
        listenable: FFAppState(),
        builder: (context, _) {
          final currentTabs = _tabs;
          return _currentPage ??
              (currentTabs[_currentPageName] ?? currentTabs.values.first);
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: FFAppState(),
        builder: (context, _) {
          final currentTabs = _tabs;
          final idx = currentTabs.keys.toList().indexOf(_currentPageName);
          final items = _buildNavItems(context);
          return BottomNavigationBar(
            currentIndex: idx.clamp(0, items.length - 1),
            onTap: (i) => safeSetState(() {
              _currentPage = null;
              _currentPageName = currentTabs.keys.toList()[i];
            }),
            backgroundColor: AppTheme.of(context).primaryBackground,
            selectedItemColor: AppTheme.of(context).primary,
            unselectedItemColor: AppTheme.of(context).secondaryText,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: items,
          );
        },
      ),
    );
  }
}
