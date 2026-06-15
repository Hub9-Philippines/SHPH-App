import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/auth/base_auth_user_provider.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/main.dart';

export 'package:go_router/go_router.dart';

export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

// Helper function to fetch user profile for role-based routing
Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
  try {
    final response = await Supabase.instance.client
        .from('profiles')
        .select(
            'role, verification_status, email, display_name, is_profile_complete, first_name, last_name')
        .eq('id', userId)
        .single();
    return response;
  } catch (e) {
    print('Error fetching user profile: $e');
    return null;
  }
}

// Determine pro user verification state based on 4-state lifecycle
String? _getProUserRedirect(Map<String, dynamic> profile, String currentPath) {
  final role = profile['role'] as String?;
  final verificationStatus = profile['verification_status'] as String?;
  final email = profile['email'] as String?;
  final displayName = profile['display_name'] as String?;
  final firstName = profile['first_name'] as String?;
  final lastName = profile['last_name'] as String?;
  final isProfileComplete = profile['is_profile_complete'] as bool?;

  if (role != 'pro') {
    return null; // Not a pro user, no special redirect
  }

  // Allow access to verification-related pages without redirecting
  final allowedVerificationPaths = [
    '/pro-unverified-landing',
    '/pro-verify-face',
    '/pro-verify-doc',
    '/pro-verification-progress',
    '/pro-profile-setup-form',
    '/face-verification',
  ];
  if (allowedVerificationPaths.any((path) => currentPath.startsWith(path))) {
    return null;
  }

  // State 1: incomplete - missing essential profile fields
  final hasName = (displayName != null && displayName.isNotEmpty) ||
      (firstName != null && firstName.isNotEmpty) ||
      (lastName != null && lastName.isNotEmpty);
  if (email == null || !hasName || isProfileComplete != true) {
    return '/pro-profile-setup-form';
  }

  // State 2: unverified
  if (verificationStatus == null || verificationStatus == 'unverified') {
    return '/pro-unverified-landing';
  }

  // State 3: pending
  if (verificationStatus == 'pending') {
    return '/pro-verification-progress';
  }

  // State 4: verified - allow access to dashboard
  if (verificationStatus == 'verified') {
    return null;
  }

  // Default to unverified if status is unknown
  return '/pro-unverified-landing';
}

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(
  AppStateNotifier appStateNotifier, {
  FFAppState? appState,
}) =>
    GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) {
        print('[ROUTER] Error builder triggered: ${state.error}');
        final page = appStateNotifier.loggedIn
            ? const NavBarPage()
            : const SplashWidget();
        print('[ROUTER] Error fallback showing: ${page.runtimeType}');
        return page;
      },
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) {
            // If user is logged in, go to home (pro redirect handled in redirect guard)
            if (appStateNotifier.loggedIn) {
              print(
                  '[ROUTER] Initialize route showing: NavBarPage, loggedIn: true');
              return const NavBarPage();
            }

            // If not logged in, check if onboarding has been completed
            final hasCompletedOnboarding =
                appState?.hasCompletedOnboarding ?? false;
            print(
                '[ROUTER] Initialize route - loggedIn: false, hasCompletedOnboarding: $hasCompletedOnboarding');

            // First time user without account - show onboarding
            if (!hasCompletedOnboarding) {
              print('[ROUTER] Initialize route showing: OnboardingWidget');
              return const OnboardingWidget();
            }

            // Returning user without account - show splash
            print('[ROUTER] Initialize route showing: SplashWidget');
            return const SplashWidget();
          },
        ),
        FFRoute(
          name: OnboardingWidget.routeName,
          path: OnboardingWidget.routePath,
          builder: (context, params) {
            print('[ROUTER] Building Onboarding page');
            return const OnboardingWidget();
          },
        ),
        FFRoute(
          name: SplashWidget.routeName,
          path: SplashWidget.routePath,
          builder: (context, params) => const SplashWidget(),
        ),
        FFRoute(
          name: SigninWidget.routeName,
          path: SigninWidget.routePath,
          builder: (context, params) => const SigninWidget(),
        ),
        FFRoute(
          name: SignOptionsWidget.routeName,
          path: SignOptionsWidget.routePath,
          builder: (context, params) => const SignOptionsWidget(),
        ),
        FFRoute(
          name: HomeWidget.routeName,
          path: HomeWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? const NavBarPage(
                  initialPage: 'Home',
                  disableResizeToAvoidBottomInset: true,
                )
              : const HomeWidget(),
        ),
        FFRoute(
          name: BookingsWidget.routeName,
          path: BookingsWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? const NavBarPage(initialPage: 'Bookings')
              : const BookingsWidget(),
        ),
        FFRoute(
          name: MessagesWidget.routeName,
          path: MessagesWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? const NavBarPage(initialPage: 'Messages')
              : const MessagesWidget(),
        ),
        FFRoute(
          name: SignupWidget.routeName,
          path: SignupWidget.routePath,
          builder: (context, params) => const SignupWidget(),
        ),
        FFRoute(
          name: PhoneVerifyUserWidget.routeName,
          path: PhoneVerifyUserWidget.routePath,
          builder: (context, params) => const PhoneVerifyUserWidget(),
        ),
        FFRoute(
          name: ProfileWidget.routeName,
          path: ProfileWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? const NavBarPage(initialPage: 'Profile')
              : const ProfileWidget(),
        ),
        FFRoute(
          name: CategoryWidget.routeName,
          path: CategoryWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? const NavBarPage(initialPage: 'Category')
              : const CategoryWidget(),
        ),
        FFRoute(
          name: EKYCBeginWidget.routeName,
          path: EKYCBeginWidget.routePath,
          builder: (context, params) => const EKYCBeginWidget(),
        ),
        FFRoute(
          name: 'FaceVerification',
          path: '/face-verification',
          builder: (context, params) => const FaceVerificationScreen(),
        ),
        FFRoute(
          name: IDVerifyWidget.routeName,
          path: IDVerifyWidget.routePath,
          builder: (context, params) => const IDVerifyWidget(),
        ),
        FFRoute(
          name: SearchPageWidget.routeName,
          path: SearchPageWidget.routePath,
          builder: (context, params) => const SearchPageWidget(),
        ),
        FFRoute(
          name: ProductPageWidget.routeName,
          path: ProductPageWidget.routePath,
          builder: (context, params) => ProductPageWidget(
            serviceName: params.getParam(
              'serviceName',
              ParamType.String,
            ),
            category: params.getParam(
              'category',
              ParamType.String,
            ),
            price: params.getParam(
              'price',
              ParamType.String,
            ),
            rating: params.getParam(
              'rating',
              ParamType.double,
            ),
            reviewCount: params.getParam(
              'reviewCount',
              ParamType.int,
            ),
            imageUrl: params.getParam(
              'imageUrl',
              ParamType.String,
            ),
            description: params.getParam(
              'description',
              ParamType.String,
            ),
            providerId: params.getParam(
                  'providerId',
                  ParamType.String,
                ) ??
                '',
            providerName: params.getParam(
                  'providerName',
                  ParamType.String,
                ) ??
                '',
            providerPhoto: params.getParam(
              'providerPhoto',
              ParamType.String,
            ),
            providerCategory: params.getParam(
                  'providerCategory',
                  ParamType.String,
                ) ??
                '',
          ),
        ),
        FFRoute(
          name: CategoriesWidget.routeName,
          path: CategoriesWidget.routePath,
          builder: (context, params) => const CategoriesWidget(),
        ),
        FFRoute(
          name: AddressesWidget.routeName,
          path: AddressesWidget.routePath,
          builder: (context, params) => const AddressesWidget(),
        ),
        FFRoute(
          name: PinLocationWidget.routeName,
          path: PinLocationWidget.routePath,
          builder: (context, params) => PinLocationWidget(
            latlong: params.getParam(
              'latlong',
              ParamType.LatLng,
            ),
          ),
        ),
        FFRoute(
          name: CreateProfileWidget.routeName,
          path: CreateProfileWidget.routePath,
          builder: (context, params) => const CreateProfileWidget(),
        ),
        FFRoute(
          name: 'ProProfileSetup',
          path: '/pro-profile-setup-form',
          builder: (context, params) => const CreateProfileWidget(),
        ),
        FFRoute(
          name: AddressFormWidget.routeName,
          path: AddressFormWidget.routePath,
          builder: (context, params) => const AddressFormWidget(),
        ),
        FFRoute(
          name: ForgotPasswordWidget.routeName,
          path: ForgotPasswordWidget.routePath,
          builder: (context, params) => const ForgotPasswordWidget(),
        ),
        FFRoute(
          name: SetPasswordWidget.routeName,
          path: SetPasswordWidget.routePath,
          builder: (context, params) => const SetPasswordWidget(),
        ),
        FFRoute(
          name: ServicesScreen.routeName,
          path: ServicesScreen.routePath,
          builder: (context, params) => ServicesScreen(
            initialCategory: params.state.uri.queryParameters['category'],
            initialFilter: params.state.uri.queryParameters['filter'],
            initialSearch: params.state.uri.queryParameters['search'],
          ),
        ),
        FFRoute(
          name: CallHistoryDetailsPageWidget.routeName,
          path: '/call-details/:callId',
          builder: (context, params) => CallHistoryDetailsPageWidget(
            callId: params.state.pathParameters['callId'],
            providerName: params.state.extraMap['providerName'],
            providerPhoto: params.state.extraMap['providerPhoto'],
            callType: params.state.extraMap['callType'],
            callStatus: params.state.extraMap['callStatus'],
            durationSeconds: params.state.extraMap['durationSeconds'],
            createdAt: params.state.extraMap['createdAt'],
          ),
        ),
        FFRoute(
          name: ChatPageWidget.routeName,
          path: '/chat/:roomId',
          builder: (context, params) => ChatPageWidget(
            roomId: params.state.pathParameters['roomId'],
            providerName: params.state.extraMap['providerName'],
            providerPhoto: params.state.extraMap['providerPhoto'],
          ),
        ),
        FFRoute(
          name: DocumentScanWidget.routeName,
          path: DocumentScanWidget.routePath,
          builder: (context, params) => const DocumentScanWidget(),
        ),
        FFRoute(
          name: ProUnverifiedLandingWidget.routeName,
          path: ProUnverifiedLandingWidget.routePath,
          builder: (context, params) => const ProUnverifiedLandingWidget(),
        ),
        FFRoute(
          name: VerificationReviewingWidget.routeName,
          path: VerificationReviewingWidget.routePath,
          builder: (context, params) => const VerificationReviewingWidget(),
        ),
        FFRoute(
          name: ProDashboardWidget.routeName,
          path: ProDashboardWidget.routePath,
          builder: (context, params) => params.isEmpty
              ? const ProDashboardWidget()
              : const ProDashboardWidget(),
        ),
        FFRoute(
          name: EditProfileWidget.routeName,
          path: EditProfileWidget.routePath,
          builder: (context, params) => const EditProfileWidget(),
        ),
        FFRoute(
          name: FavoritesWidget.routeName,
          path: FavoritesWidget.routePath,
          builder: (context, params) => const FavoritesWidget(),
        ),
        FFRoute(
          name: MyReviewsWidget.routeName,
          path: MyReviewsWidget.routePath,
          builder: (context, params) => const MyReviewsWidget(),
        ),
        FFRoute(
          name: MyNotificationsWidget.routeName,
          path: MyNotificationsWidget.routePath,
          builder: (context, params) => const MyNotificationsWidget(),
        ),
        FFRoute(
          name: LanguageSettingsWidget.routeName,
          path: LanguageSettingsWidget.routePath,
          builder: (context, params) => const LanguageSettingsWidget(),
        ),
        FFRoute(
          name: SecuritySettingsWidget.routeName,
          path: SecuritySettingsWidget.routePath,
          builder: (context, params) => const SecuritySettingsWidget(),
        ),
        FFRoute(
          name: SettingsWidget.routeName,
          path: SettingsWidget.routePath,
          builder: (context, params) => const SettingsWidget(),
        ),
        FFRoute(
          name: BookingWidget.routeName,
          path: BookingWidget.routePath,
          builder: (context, params) => BookingWidget(
            serviceName: params.getParam(
              'serviceName',
              ParamType.String,
            ),
            category: params.getParam(
              'category',
              ParamType.String,
            ),
            price: params.getParam(
              'price',
              ParamType.String,
            ),
            imageUrl: params.getParam(
              'imageUrl',
              ParamType.String,
            ),
          ),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra! as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) async {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/splash';
          }

          // Role-based routing logic with 4-state pro account lifecycle
          if (appStateNotifier.loggedIn) {
            final userId = Supabase.instance.client.auth.currentUser?.id;
            if (userId != null) {
              final userProfile = await _fetchUserProfile(userId);
              if (userProfile != null) {
                final currentPath = state.uri.toString();
                final proRedirect =
                    _getProUserRedirect(userProfile, currentPath);

                if (proRedirect != null) {
                  return proRedirect;
                }
              }
            }
          }

          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);

          // TEMPORARILY DISABLED: Show pages even during loading to debug
          // This allows splash to render and navigate properly
          final child = page; // Always show the page, ignore loading state

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          _buildTransition(
                    transitionInfo,
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

enum TransitionType {
  fade,
  scale,
  slide,
  bottomToTop,
  topToBottom,
  leftToRight,
  rightToLeft,
}

Widget _buildTransition(
  TransitionInfo transitionInfo,
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  switch (transitionInfo.transitionType) {
    case TransitionType.fade:
      return FadeTransition(opacity: animation, child: child);
    case TransitionType.scale:
      return ScaleTransition(
        scale: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        ),
        alignment: transitionInfo.alignment ?? Alignment.center,
        child: child,
      );
    case TransitionType.bottomToTop:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    case TransitionType.topToBottom:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    case TransitionType.leftToRight:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    case TransitionType.rightToLeft:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    case TransitionType.slide:
      return FadeTransition(opacity: animation, child: child);
  }
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = TransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final TransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() =>
      const TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final lastMatch = routerDelegate.currentConfiguration.last;
    final matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
