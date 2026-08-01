import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/resources/users_api.dart';
import '/auth/base_auth_user_provider.dart';
import '/backend/supabase/database/tables/payment_methods.dart';
import '/flutter_flow/lat_lng.dart';
import '/index.dart';
import '/main.dart';
import '/models/service_listing.dart';
import '/pages/booking_funnel/booking_models.dart';
import '/pages/geographic_selection/geographic_selection_widget.dart';
import '/services/provider_verification_service.dart';

// Helper function to fetch user profile for role-based routing.
// The /auth/me/ (getMe) response carries the real account capabilities:
// `is_provider`, `is_client`, `kyc_skipped`, `role`, `display_name`, etc.
Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
  try {
    final data = await ShphUsersApi.instance.getMe();
    final profile = data['profile'] is Map<String, dynamic>
        ? data['profile'] as Map<String, dynamic>
        : data;
    if (profile.isEmpty) {
      return null;
    }
    return {
      'role': profile['role'],
      'is_provider': profile['is_provider'],
      'is_client': profile['is_client'],
      'kyc_skipped': profile['kyc_skipped'],
      'verification_status': profile['verification_status'],
      'kyc_status': profile['kyc_status'],
      'email': profile['email'],
      'display_name': profile['display_name'],
      'is_profile_complete': profile['is_profile_complete'],
      'first_name': profile['first_name'],
      'last_name': profile['last_name'],
    };
  } catch (e) {
    return null;
  }
}

/// Paths that are part of the KYC lifecycle or onboarding funnel and must not
/// be lifecycle-redirected (mirrors web's `kycRouteNames` skip list plus the
/// profile-setup target to avoid redirect loops).
const List<String> _kycFlowPaths = [
  '/eKYCBegin',
  '/iDVerify',
  '/pro-verify-doc',
  '/face-verification',
  '/kyc',
];

/// Provider lifecycle resolution used by the redirect guard. Returns a
/// redirect path when the provider is not in the expected state for the
/// requested path, or `null` to allow the navigation.
Future<String?> _resolveProviderRedirectAsync(
  Map<String, dynamic> profile,
  String currentPath,
) async {
  if (profile['is_provider'] != true) {
    return null;
  }
  if (_kycFlowPaths.any((path) => currentPath.startsWith(path))) {
    return null;
  }
  final redirect =
      await ProviderVerificationService.instance.resolveProviderRedirect(profile);
  return redirect == currentPath ? null : redirect;
}

/// Route gating requirements (web `beforeEach` meta parity). Keyed by path
/// prefix so GoRoute definitions stay unchanged.
class _RouteGates {
  const _RouteGates({
    this.requiresProvider = false,
    this.requiresClient = false,
    this.requiresKyc = false,
  });

  final bool requiresProvider;
  final bool requiresClient;
  final bool requiresKyc;

  bool get requiresAuth => requiresProvider || requiresClient || requiresKyc;
}

const _RouteGates _noGates = _RouteGates();

/// Provider-only route prefixes.
const List<String> _providerPathPrefixes = [
  '/pro-',
  '/face-verification',
  '/iDVerify',
  '/eKYCBegin',
  '/kyc',
];

/// Paths that act as a provider's home (web: Home ↔ ProviderDashboard). The
/// lifecycle runs on these so a provider can never idle on the client shell.
const List<String> _providerHomePaths = ['/pro-dashboard', '/', '/home'];

/// Client-only routes (kept minimal — shared shells like home/messages/profile
/// must remain reachable by providers).
const List<String> _clientOnlyPaths = [
  '/booking',
  '/booking-payment',
  '/bookings',
  '/write-review',
  '/favorites',
  '/my-reviews',
  '/client-on-demand-jobs',
  '/wallet',
  '/payment-methods',
  '/addresses',
];

/// Routes that gate a real action requiring verified KYC (e.g. posting a
/// service). A KYC-skipped provider is sent to the KYC intro from here.
const List<String> _requiresKycPaths = [
  '/create-service',
  '/my-services',
  '/earnings',
  '/provider-analytics',
  '/provider-bids',
  '/provider-booking-flow',
];

_RouteGates _gatesForPath(String path) {
  var gates = _noGates;
  if (_providerPathPrefixes.any(path.startsWith)) {
    gates = _RouteGates(requiresProvider: true);
  }
  if (_clientOnlyPaths.any((p) => path.startsWith(p))) {
    gates = _RouteGates(
      requiresClient: true,
      requiresProvider: gates.requiresProvider,
    );
  }
  if (_requiresKycPaths.any((p) => path.startsWith(p))) {
    gates = _RouteGates(
      requiresProvider: true,
      requiresKyc: true,
    );
  }
  return gates;
}

class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  static GoRouter createRouter(dynamic appStateNotifier, {dynamic appState}) =>
      GoRouter(
        initialLocation: '/',
        debugLogDiagnostics: true,
        refreshListenable: appStateNotifier,
        redirect: (context, state) =>
            RoleBasedRedirectGuard.checkRedirect(appStateNotifier, state),
        errorBuilder: (context, state) {
          final isLoggedIn = appStateNotifier?.loggedIn ?? false;
          final page = isLoggedIn ? const NavBarPage() : const SplashWidget();
          return page;
        },
        routes: [
          GoRoute(
            path: '/',
            name: '_initialize',
            builder: (context, state) {
              // If user is logged in, go to home (pro redirect handled in redirect guard)
              final isLoggedIn = appStateNotifier?.loggedIn ?? false;
              if (isLoggedIn) {
                return const NavBarPage();
              }

              // Always show splash first for non-logged in users
              // Splash will handle navigation to onboarding or sign_options after delay
              return const SplashWidget();
            },
          ),
          GoRoute(
            path: OnboardingWidget.routePath,
            name: OnboardingWidget.routeName,
            builder: (context, state) => const OnboardingWidget(),
          ),
          GoRoute(
            path: SplashWidget.routePath,
            name: SplashWidget.routeName,
            builder: (context, state) => const SplashWidget(),
          ),
          GoRoute(
            path: SigninWidget.routePath,
            name: SigninWidget.routeName,
            builder: (context, state) => const SigninWidget(),
          ),
          GoRoute(
            path: SignOptionsWidget.routePath,
            name: SignOptionsWidget.routeName,
            builder: (context, state) => const SignOptionsWidget(),
          ),
          GoRoute(
            path: HomeWidget.routePath,
            name: HomeWidget.routeName,
            builder: (context, state) {
              final queryParams = state.uri.queryParameters;
              if (queryParams.isEmpty) {
                return const NavBarPage(
                  initialPage: 'Home',
                  disableResizeToAvoidBottomInset: true,
                );
              }
              return const HomeWidget();
            },
          ),
          GoRoute(
            path: BookingFlowScreen.routePath,
            name: BookingFlowScreen.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final service = extra?['service'] as ServiceListing?;
              if (service == null) {
                return const NavBarPage(
                  initialPage: 'Home',
                  disableResizeToAvoidBottomInset: true,
                );
              }
              return BookingFlowScreen(
                selectedService: service,
                initialUrgency: extra?['initialUrgency'] as BookingUrgency?,
                initialScheduledDate:
                    extra?['initialScheduledDate'] as DateTime?,
                initialScheduledTime:
                    extra?['initialScheduledTime'] as TimeOfDay?,
              );
            },
          ),
          GoRoute(
            path: TMSubCategoryScreen.routePath,
            name: TMSubCategoryScreen.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final service = extra?['service'] as ServiceListing?;
              if (service == null) {
                return const NavBarPage(
                  initialPage: 'Home',
                  disableResizeToAvoidBottomInset: true,
                );
              }
              return TMSubCategoryScreen(
                selectedService: service,
              );
            },
          ),
          GoRoute(
            path: BookingsWidget.routePath,
            name: BookingsWidget.routeName,
            builder: (context, state) {
              final queryParams = state.uri.queryParameters;
              if (queryParams.isEmpty) {
                return const NavBarPage(initialPage: 'Bookings');
              }
              return const BookingsWidget();
            },
          ),
          GoRoute(
            path: MessagesWidget.routePath,
            name: MessagesWidget.routeName,
            builder: (context, state) {
              final queryParams = state.uri.queryParameters;
              if (queryParams.isEmpty) {
                return const NavBarPage(initialPage: 'Messages');
              }
              return const MessagesWidget();
            },
          ),
          GoRoute(
            path: SignupWidget.routePath,
            name: SignupWidget.routeName,
            builder: (context, state) => const SignupWidget(),
          ),
          GoRoute(
            path: PhoneVerifyUserWidget.routePath,
            name: PhoneVerifyUserWidget.routeName,
            builder: (context, state) => const PhoneVerifyUserWidget(),
          ),
          GoRoute(
            path: ProfileWidget.routePath,
            name: ProfileWidget.routeName,
            builder: (context, state) {
              final queryParams = state.uri.queryParameters;
              if (queryParams.isEmpty) {
                return const NavBarPage(initialPage: 'Profile');
              }
              return const ProfileWidget();
            },
          ),
          GoRoute(
            path: CategoryWidget.routePath,
            name: CategoryWidget.routeName,
            builder: (context, state) {
              final queryParams = state.uri.queryParameters;
              if (queryParams.isEmpty) {
                return const NavBarPage(initialPage: 'Category');
              }
              return const CategoryWidget();
            },
          ),
          GoRoute(
            path: ExploreWidget.routePath,
            name: ExploreWidget.routeName,
            builder: (context, state) {
              final queryParams = state.uri.queryParameters;
              if (queryParams.isEmpty) {
                return const NavBarPage(initialPage: 'Explore');
              }
              return const ExploreWidget();
            },
          ),
          GoRoute(
            path: EKYCBeginWidget.routePath,
            name: EKYCBeginWidget.routeName,
            builder: (context, state) => const EKYCBeginWidget(),
          ),
          GoRoute(
            path: SearchPageWidget.routePath,
            name: SearchPageWidget.routeName,
            builder: (context, state) => const SearchPageWidget(),
          ),
          GoRoute(
            path: ProductPageWidget.routePath,
            name: ProductPageWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ProductPageWidget(
                serviceName: extra?['serviceName'] as String? ??
                    state.uri.queryParameters['serviceName'] ??
                    '',
                category: extra?['category'] as String? ??
                    state.uri.queryParameters['category'] ??
                    '',
                price: extra?['price'] as String? ??
                    state.uri.queryParameters['price'] ??
                    '',
                rating: extra?['rating'] as double? ??
                    double.tryParse(
                        state.uri.queryParameters['rating'] ?? '0') ??
                    0.0,
                reviewCount: extra?['reviewCount'] as int? ??
                    int.tryParse(
                        state.uri.queryParameters['reviewCount'] ?? '0') ??
                    0,
                imageUrl: extra?['imageUrl'] as String? ??
                    state.uri.queryParameters['imageUrl'] ??
                    '',
                description: extra?['description'] as String? ??
                    state.uri.queryParameters['description'] ??
                    '',
                serviceId: extra?['serviceId'] as int?,
                providerId: extra?['providerId'] as String? ?? '',
                providerName: extra?['providerName'] as String? ?? '',
                providerPhoto: extra?['providerPhoto'] as String?,
                providerCategory: extra?['providerCategory'] as String? ?? '',
                isVerified: extra?['isVerified'] as bool? ?? false,
              );
            },
          ),
          GoRoute(
            path: ReviewsWidget.routePath,
            name: ReviewsWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ReviewsWidget(
                serviceId: extra?['serviceId'] as int? ??
                    int.tryParse(
                        state.uri.queryParameters['serviceId'] ?? '0') ??
                    0,
                serviceName: extra?['serviceName'] as String? ??
                    state.uri.queryParameters['serviceName'] ??
                    '',
              );
            },
          ),
          GoRoute(
            path: ContactProviderWidget.routePath,
            name: ContactProviderWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ContactProviderWidget(
                providerName: extra?['providerName'] as String? ??
                    state.uri.queryParameters['providerName'] ??
                    'Provider',
                providerId: extra?['providerId'] as String?,
                providerPhoto: extra?['providerPhoto'] as String?,
                isVerified: extra?['isVerified'] as bool? ?? false,
                mobileNumber: extra?['mobileNumber'] as String?,
                serviceName: extra?['serviceName'] as String?,
                serviceCategory: extra?['serviceCategory'] as String?,
                servicePrice: extra?['servicePrice'] as String?,
                serviceDescription: extra?['serviceDescription'] as String?,
              );
            },
          ),
          GoRoute(
            path: CategoriesWidget.routePath,
            name: CategoriesWidget.routeName,
            builder: (context, state) => const CategoriesWidget(),
          ),
          GoRoute(
            path: AddressesWidget.routePath,
            name: AddressesWidget.routeName,
            builder: (context, state) => const AddressesWidget(),
          ),
          GoRoute(
            path: PinLocationWidget.routePath,
            name: PinLocationWidget.routeName,
            builder: (context, state) => PinLocationWidget(
              latlong: state.extra as LatLng?,
            ),
          ),
          GoRoute(
            path: CreateProfileWidget.routePath,
            name: CreateProfileWidget.routeName,
            builder: (context, state) => const CreateProfileWidget(),
          ),
          GoRoute(
            path: '/pro-profile-setup-form',
            name: 'ProProfileSetup',
            builder: (context, state) => const CreateProfileWidget(),
          ),
          GoRoute(
            path: AddressFormWidget.routePath,
            name: AddressFormWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AddressFormWidget(
                addressId: extra?['addressId'] as int?,
              );
            },
          ),
          GoRoute(
            path: ForgotPasswordWidget.routePath,
            name: ForgotPasswordWidget.routeName,
            builder: (context, state) => const ForgotPasswordWidget(),
          ),
          GoRoute(
            path: SetPasswordWidget.routePath,
            name: SetPasswordWidget.routeName,
            builder: (context, state) => const SetPasswordWidget(),
          ),
          GoRoute(
            path: ServicesScreen.routePath,
            name: ServicesScreen.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ServicesScreen(
                initialCategory: extra?['initialCategory'] as String? ??
                    state.uri.queryParameters['category'],
                initialFilter: extra?['initialFilter'] as String? ??
                    state.uri.queryParameters['filter'],
                initialSearch: extra?['initialSearch'] as String? ??
                    state.uri.queryParameters['search'],
              );
            },
          ),
          GoRoute(
            path: '/call-details/:callId',
            name: CallHistoryDetailsPageWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return CallHistoryDetailsPageWidget(
                callId: state.pathParameters['callId'],
                providerName: extra?['providerName'],
                providerPhoto: extra?['providerPhoto'],
                callType: extra?['callType'],
                callStatus: extra?['callStatus'],
                durationSeconds: extra?['durationSeconds'],
                createdAt: extra?['createdAt'],
              );
            },
          ),
          GoRoute(
            path: '/chat/:roomId',
            name: ChatPageWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ChatPageWidget(
                roomId: state.pathParameters['roomId'],
                providerName: extra?['providerName'],
                providerPhoto: extra?['providerPhoto'],
              );
            },
          ),
          GoRoute(
            path: DocumentScanWidget.routePath,
            name: DocumentScanWidget.routeName,
            builder: (context, state) => const DocumentScanWidget(),
          ),
          GoRoute(
            path: IDVerifyWidget.routePath,
            name: IDVerifyWidget.routeName,
            builder: (context, state) => const IDVerifyWidget(),
          ),
          GoRoute(
            path: FaceVerificationScreen.routePath,
            name: FaceVerificationScreen.routeName,
            builder: (context, state) => const FaceVerificationScreen(),
          ),
          GoRoute(
            path: ProUnverifiedLandingWidget.routePath,
            name: ProUnverifiedLandingWidget.routeName,
            builder: (context, state) => const ProUnverifiedLandingWidget(),
          ),
          GoRoute(
            path: VerificationReviewingWidget.routePath,
            name: VerificationReviewingWidget.routeName,
            builder: (context, state) => const VerificationReviewingWidget(),
          ),
          GoRoute(
            path: ProDashboardWidget.routePath,
            name: ProDashboardWidget.routeName,
            builder: (context, state) => const ProDashboardWidget(),
          ),
          GoRoute(
            path: ProEditProfileWidget.routePath,
            name: ProEditProfileWidget.routeName,
            builder: (context, state) => const ProEditProfileWidget(),
          ),
          GoRoute(
            path: EditProfileWidget.routePath,
            name: EditProfileWidget.routeName,
            builder: (context, state) => const EditProfileWidget(),
          ),
          GoRoute(
            path: ServiceHistoryWidget.routePath,
            name: ServiceHistoryWidget.routeName,
            builder: (context, state) => const ServiceHistoryWidget(),
          ),
          GoRoute(
            path: ReviewsRatingsWidget.routePath,
            name: ReviewsRatingsWidget.routeName,
            builder: (context, state) => const ReviewsRatingsWidget(),
          ),
          GoRoute(
            path: HelpSupportWidget.routePath,
            name: HelpSupportWidget.routeName,
            builder: (context, state) => const HelpSupportWidget(),
          ),
          GoRoute(
            path: AboutWidget.routePath,
            name: AboutWidget.routeName,
            builder: (context, state) => const AboutWidget(),
          ),
          GoRoute(
            path: CreateServiceWidget.routePath,
            name: CreateServiceWidget.routeName,
            builder: (context, state) => const CreateServiceWidget(),
          ),
          GoRoute(
            path: FavoritesWidget.routePath,
            name: FavoritesWidget.routeName,
            builder: (context, state) => const FavoritesWidget(),
          ),
          GoRoute(
            path: MyReviewsWidget.routePath,
            name: MyReviewsWidget.routeName,
            builder: (context, state) => const MyReviewsWidget(),
          ),
          GoRoute(
            path: MyNotificationsWidget.routePath,
            name: MyNotificationsWidget.routeName,
            builder: (context, state) => const MyNotificationsWidget(),
          ),
          GoRoute(
            path: PaymentMethodsWidget.routePath,
            name: PaymentMethodsWidget.routeName,
            builder: (context, state) => const PaymentMethodsWidget(),
          ),
          GoRoute(
            path: AddCardPaymentWidget.routePath,
            name: AddCardPaymentWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AddCardPaymentWidget(
                paymentMethod: extra?['paymentMethod'] as PaymentMethodsRow?,
              );
            },
          ),
          GoRoute(
            path: AddEwalletPaymentWidget.routePath,
            name: AddEwalletPaymentWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AddEwalletPaymentWidget(
                paymentMethod: extra?['paymentMethod'] as PaymentMethodsRow?,
              );
            },
          ),
          GoRoute(
            path: WalletWidget.routePath,
            name: WalletWidget.routeName,
            builder: (context, state) => const WalletWidget(),
          ),
          GoRoute(
            path: OnDemandBookingWidget.routePath,
            name: OnDemandBookingWidget.routeName,
            builder: (context, state) => const OnDemandBookingWidget(),
          ),
          GoRoute(
            path: LanguageSettingsWidget.routePath,
            name: LanguageSettingsWidget.routeName,
            builder: (context, state) => const LanguageSettingsWidget(),
          ),
          GoRoute(
            path: SecuritySettingsWidget.routePath,
            name: SecuritySettingsWidget.routeName,
            builder: (context, state) => const SecuritySettingsWidget(),
          ),
          GoRoute(
            path: SettingsWidget.routePath,
            name: SettingsWidget.routeName,
            builder: (context, state) => const SettingsWidget(),
          ),
          GoRoute(
            path: BookingWidget.routePath,
            name: BookingWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return BookingWidget(
                serviceId: extra?['serviceId'] as int? ??
                    int.tryParse(state.uri.queryParameters['serviceId'] ?? ''),
                serviceName: extra?['serviceName'] as String? ??
                    state.uri.queryParameters['serviceName'],
                category: extra?['category'] as String? ??
                    state.uri.queryParameters['category'],
                price: extra?['price'] as String? ??
                    state.uri.queryParameters['price'],
                imageUrl: extra?['imageUrl'] as String? ??
                    state.uri.queryParameters['imageUrl'],
              );
            },
          ),
          GoRoute(
            path: BookingPaymentWidget.routePath,
            name: BookingPaymentWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return BookingPaymentWidget(
                serviceId: extra?['serviceId'] as int?,
                serviceName: extra?['serviceName'] as String?,
                category: extra?['category'] as String?,
                price: extra?['price'] as String?,
                imageUrl: extra?['imageUrl'] as String?,
                bookingDate: extra?['bookingDate'] as String?,
                bookingTime: extra?['bookingTime'] as String?,
                notes: extra?['notes'] as String?,
              );
            },
          ),
          GoRoute(
            path: BookingSuccessWidget.routePath,
            name: BookingSuccessWidget.routeName,
            builder: (context, state) => const BookingSuccessWidget(),
          ),
          GoRoute(
            path: BookingDetailsWidget.routePath,
            name: BookingDetailsWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return BookingDetailsWidget(
                bookingId: extra?['bookingId'] as String? ??
                    state.uri.queryParameters['bookingId'],
              );
            },
          ),
          GoRoute(
            path: HelpPage.routePath,
            name: HelpPage.routeName,
            builder: (context, state) => const HelpPage(),
          ),
          GoRoute(
            path: ChatbotPage.routePath,
            name: ChatbotPage.routeName,
            builder: (context, state) => const ChatbotPage(),
          ),
          GoRoute(
            path: TMActiveJobScreen.routePath,
            name: TMActiveJobScreen.routeName,
            builder: (context, state) => const TMActiveJobScreen(),
          ),
          GoRoute(
            path: TMBroadcastScreen.routePath,
            name: TMBroadcastScreen.routeName,
            builder: (context, state) => const TMBroadcastScreen(),
          ),
          GoRoute(
            path: TMEstimateScreen.routePath,
            name: TMEstimateScreen.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return TMEstimateScreen(
                subCategory: extra?['subCategory'],
              );
            },
          ),
          GoRoute(
            path: TMInvoiceScreen.routePath,
            name: TMInvoiceScreen.routeName,
            builder: (context, state) => const TMInvoiceScreen(),
          ),
          GoRoute(
            path: TMPaymentScreen.routePath,
            name: TMPaymentScreen.routeName,
            builder: (context, state) => const TMPaymentScreen(),
          ),
          GoRoute(
            path: TMRatingScreen.routePath,
            name: TMRatingScreen.routeName,
            builder: (context, state) => const TMRatingScreen(),
          ),
          GoRoute(
            path: PrivacyPolicyWidget.routePath,
            name: PrivacyPolicyWidget.routeName,
            builder: (context, state) => const PrivacyPolicyWidget(),
          ),
          GoRoute(
            path: TermsOfServiceWidget.routePath,
            name: TermsOfServiceWidget.routeName,
            builder: (context, state) => const TermsOfServiceWidget(),
          ),
          GoRoute(
            path: GeographicSelectionWidget.routePath,
            name: GeographicSelectionWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return GeographicSelectionWidget(
                selectionType:
                    extra?['selectionType'] as GeographicSelectionType,
                parentCode: extra?['parentCode'] as String?,
              );
            },
          ),
          GoRoute(
            path: ProviderProfileWidget.routePath,
            name: ProviderProfileWidget.routeName,
            builder: (context, state) => ProviderProfileWidget(
              providerId: state.pathParameters['providerId'],
            ),
          ),
          GoRoute(
            path: CategoryDetailWidget.routePath,
            name: CategoryDetailWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return CategoryDetailWidget(
                categoryId: int.tryParse(
                      state.pathParameters['categoryId'] ?? '') ??
                  0,
                categoryName: extra?['categoryName'] as String? ??
                    state.uri.queryParameters['categoryName'] ??
                    '',
              );
            },
          ),
          GoRoute(
            path: RecommendationsWidget.routePath,
            name: RecommendationsWidget.routeName,
            builder: (context, state) => const RecommendationsWidget(),
          ),
          GoRoute(
            path: ProviderBidsWidget.routePath,
            name: ProviderBidsWidget.routeName,
            builder: (context, state) => const ProviderBidsWidget(),
          ),
          GoRoute(
            path: ClientOnDemandJobsWidget.routePath,
            name: ClientOnDemandJobsWidget.routeName,
            builder: (context, state) => const ClientOnDemandJobsWidget(),
          ),
          GoRoute(
            path: DisputesWidget.routePath,
            name: DisputesWidget.routeName,
            builder: (context, state) => const DisputesWidget(),
          ),
          GoRoute(
            path: NotificationPreferencesWidget.routePath,
            name: NotificationPreferencesWidget.routeName,
            builder: (context, state) =>
                const NotificationPreferencesWidget(),
          ),
          GoRoute(
            path: ThemeSettingsWidget.routePath,
            name: ThemeSettingsWidget.routeName,
            builder: (context, state) => const ThemeSettingsWidget(),
          ),
          GoRoute(
            path: SessionsWidget.routePath,
            name: SessionsWidget.routeName,
            builder: (context, state) => const SessionsWidget(),
          ),
          GoRoute(
            path: SubcategoryWidget.routePath,
            name: SubcategoryWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return SubcategoryWidget(
                categoryId: int.tryParse(
                      state.pathParameters['categoryId'] ?? '') ??
                  0,
                categoryName: extra?['categoryName'] as String? ??
                    state.uri.queryParameters['categoryName'] ??
                    '',
              );
            },
          ),
          GoRoute(
            path: KycHubWidget.routePath,
            name: KycHubWidget.routeName,
            builder: (context, state) => const KycHubWidget(),
          ),
          GoRoute(
            path: ReportProblemWidget.routePath,
            name: ReportProblemWidget.routeName,
            builder: (context, state) => const ReportProblemWidget(),
          ),
          GoRoute(
            path: RoomListWidget.routePath,
            name: RoomListWidget.routeName,
            builder: (context, state) => const RoomListWidget(),
          ),
          GoRoute(
            path: RoomCreateWidget.routePath,
            name: RoomCreateWidget.routeName,
            builder: (context, state) => const RoomCreateWidget(),
          ),
          GoRoute(
            path: RoomJoinWidget.routePath,
            name: RoomJoinWidget.routeName,
            builder: (context, state) => const RoomJoinWidget(),
          ),
          GoRoute(
            path: RoomDetailWidget.routePath,
            name: RoomDetailWidget.routeName,
            builder: (context, state) => RoomDetailWidget(
              roomId: state.pathParameters['roomId'] ?? '',
            ),
          ),
          GoRoute(
            path: ProjectListWidget.routePath,
            name: ProjectListWidget.routeName,
            builder: (context, state) => const ProjectListWidget(),
          ),
          GoRoute(
            path: ProjectCreateWidget.routePath,
            name: ProjectCreateWidget.routeName,
            builder: (context, state) => const ProjectCreateWidget(),
          ),
          GoRoute(
            path: ProjectDetailWidget.routePath,
            name: ProjectDetailWidget.routeName,
            builder: (context, state) => ProjectDetailWidget(
              projectId: state.pathParameters['projectId'] ?? '',
            ),
          ),
          GoRoute(
            path: MyServicesWidget.routePath,
            name: MyServicesWidget.routeName,
            builder: (context, state) => const MyServicesWidget(),
          ),
          GoRoute(
            path: EarningsWidget.routePath,
            name: EarningsWidget.routeName,
            builder: (context, state) => const EarningsWidget(),
          ),
          GoRoute(
            path: ProviderAnalyticsWidget.routePath,
            name: ProviderAnalyticsWidget.routeName,
            builder: (context, state) => const ProviderAnalyticsWidget(),
          ),
          GoRoute(
            path: ProviderBookingFlowWidget.routePath,
            name: ProviderBookingFlowWidget.routeName,
            builder: (context, state) => ProviderBookingFlowWidget(
              bookingId:
                  state.pathParameters['bookingId'] ?? '',
            ),
          ),
          GoRoute(
            path: WriteReviewWidget.routePath,
            name: WriteReviewWidget.routeName,
            builder: (context, state) => WriteReviewWidget(
              bookingId:
                  state.pathParameters['bookingId'] ?? '',
              serviceName: state.extra != null
                  ? (state.extra as Map)['serviceName'] as String?
                  : state.uri.queryParameters['serviceName'],
            ),
          ),
          GoRoute(
            path: OtpPageWidget.routePath,
            name: OtpPageWidget.routeName,
            builder: (context, state) => OtpPageWidget(
              initialPhone: state.uri.queryParameters['phone'],
            ),
          ),
          GoRoute(
            path: NotFoundWidget.routePath,
            name: NotFoundWidget.routeName,
            builder: (context, state) => const NotFoundWidget(),
          ),
          GoRoute(
            path: EtaTrackingWidget.routePath,
            name: EtaTrackingWidget.routeName,
            builder: (context, state) => EtaTrackingWidget(
              token: state.pathParameters['token'] ?? '',
            ),
          ),
          GoRoute(
            path: BiometricSetupWidget.routePath,
            name: BiometricSetupWidget.routeName,
            builder: (context, state) => const BiometricSetupWidget(),
          ),
          GoRoute(
            path: CallPermissionWidget.routePath,
            name: CallPermissionWidget.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return CallPermissionWidget(
                mediaType: extra?['mediaType'] as String? ??
                    state.uri.queryParameters['mediaType'] ??
                    'audio',
                participantName: extra?['participantName'] as String? ??
                    state.uri.queryParameters['participantName'],
              );
            },
          ),
        ],
      );
}

// Custom redirect guard for role-based routing
class RoleBasedRedirectGuard {
  // Private constructor to prevent instantiation
  RoleBasedRedirectGuard._();

  /// Check if user needs to be redirected based on their role and verification status
  static Future<String?> checkRedirect(
    dynamic appStateNotifier,
    GoRouterState state,
  ) async {
    if (appStateNotifier.shouldRedirect) {
      final redirectLocation = appStateNotifier.getRedirectLocation();
      appStateNotifier.clearRedirectLocation();
      return redirectLocation;
    }

    final currentPath = state.uri.toString();
    final gates = _gatesForPath(currentPath);

    // Auth gate: role/kyc-gated routes require a logged-in session (web parity).
    if (!appStateNotifier.loggedIn) {
      if (gates.requiresAuth) {
        return SigninWidget.routePath;
      }
      return null;
    }

    final userId = currentUser?.uid;
    if (userId == null) {
      return null;
    }

    final userProfile = await _fetchUserProfile(userId);
    if (userProfile == null) {
      return null;
    }

    final isProvider = userProfile['is_provider'] == true;
    final isClient = userProfile['is_client'] == true;

    // Role gates (web `beforeEach` parity).
    if (gates.requiresProvider && !isProvider) {
      return HomeWidget.routePath;
    }
    if (gates.requiresClient && !isClient) {
      return HomeWidget.routePath;
    }

    // Provider 4-state lifecycle.
    if (gates.requiresProvider && isProvider) {
      final redirect =
          await _resolveProviderRedirectAsync(userProfile, currentPath);
      if (redirect != null) {
        // A KYC-skipped provider on a KYC-gated route goes to the KYC intro.
        if (gates.requiresKyc && redirect == '/pro-dashboard') {
          return EKYCBeginWidget.routePath;
        }
        return redirect;
      }
    }

    // Home-by-mode: a provider on the client shell / provider dashboard is
    // lifecycle-redirected (web `beforeEach` home↔dashboard parity).
    if (isProvider && _providerHomePaths.contains(currentPath)) {
      final redirect =
          await _resolveProviderRedirectAsync(userProfile, currentPath);
      if (redirect != null) {
        // The provider shell at `/`/`/home` IS this app's provider dashboard;
        // a verified or KYC-skipped provider stays put instead of bouncing to
        // the standalone /pro-dashboard page.
        if (redirect == ProDashboardWidget.routePath &&
            (currentPath == '/' ||
                currentPath == HomeWidget.routePath)) {
          return null;
        }
        return redirect;
      }
    }

    return null;
  }
}
