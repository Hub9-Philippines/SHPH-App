import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/resources/users_api.dart';
import '/auth/shph_auth/auth_util.dart';
import '/backend/shph_db/database/tables/payment_methods.dart';
import '/flutter_flow/lat_lng.dart';
import '/index.dart';
import '/main.dart';
import '/models/service_listing.dart';
import '/pages/booking_funnel/booking_models.dart';
import '/pages/geographic_selection/geographic_selection_widget.dart';

// Helper function to fetch user profile for role-based routing
Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
  try {
    return await ShphUsersApi.instance.getMe();
  } catch (e) {
    return null;
  }
}

// Determine pro user verification state based on 4-state lifecycle
String? _getProUserRedirect(Map<String, dynamic> profile, String currentPath) {
  final role = profile['role'] as String?;
  final verificationStatus = profile['verification_status'] as String?;
  final isVerified = profile['is_verified'] as bool? ?? false;
  final isFaceVerified = profile['is_face_verified'] as bool? ?? false;
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
    '/pro-dashboard',
  ];
  if (allowedVerificationPaths.any((path) => currentPath.startsWith(path))) {
    return null;
  }

  // State 1: incomplete profile - redirect to complete profile
  // This applies when profile is not marked complete or missing essential fields
  final hasName = (displayName != null && displayName.isNotEmpty) ||
      (firstName != null && firstName.isNotEmpty) ||
      (lastName != null && lastName.isNotEmpty);
  final isProfileIncomplete =
      email == null || !hasName || isProfileComplete != true;

  // Redirect to profile setup if incomplete
  if (isProfileIncomplete) {
    return '/pro-profile-setup-form';
  }

  // State 2: unverified
  if (verificationStatus == null || verificationStatus == 'unverified') {
    return '/pro-unverified-landing';
  }

  // State 3: pending or reviewing
  if (verificationStatus == 'pending' || verificationStatus == 'reviewing') {
    return '/pro-verification-progress';
  }

  // State 4: fully verified - redirect to pro dashboard
  // All verification checks must pass
  if (verificationStatus == 'verified' && isVerified && isFaceVerified) {
    return '/pro-dashboard';
  }

  // State 5: partially verified - still needs verification
  if (verificationStatus == 'verified' && (!isVerified || !isFaceVerified)) {
    return '/pro-unverified-landing';
  }

  // Default to unverified if status is unknown
  return '/pro-unverified-landing';
}

class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  static GoRouter createRouter(
    dynamic appStateNotifier, {
    dynamic appState,
    List<NavigatorObserver> observers = const [],
  }) =>
      GoRouter(
        initialLocation: '/',
        debugLogDiagnostics: true,
        observers: observers,
        refreshListenable: appStateNotifier,
        redirect: (context, state) =>
            RoleBasedRedirectGuard.checkRedirect(appStateNotifier, state),
        errorBuilder: (context, state) => const NotFoundPage(),
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
            path: ClientHelpSupportWidget.routePath,
            name: ClientHelpSupportWidget.routeName,
            builder: (context, state) => const ClientHelpSupportWidget(),
          ),
          GoRoute(
            path: ReportProblemWidget.routePath,
            name: ReportProblemWidget.routeName,
            builder: (context, state) => const ReportProblemWidget(),
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
          // Provider Suite
          GoRoute(
            path: ProviderAnalyticsPage.routePath,
            name: ProviderAnalyticsPage.routeName,
            builder: (context, state) => const ProviderAnalyticsPage(),
          ),
          GoRoute(
            path: ProviderBidsPage.routePath,
            name: ProviderBidsPage.routeName,
            builder: (context, state) => const ProviderBidsPage(),
          ),
          GoRoute(
            path: EarningsPage.routePath,
            name: EarningsPage.routeName,
            builder: (context, state) => const EarningsPage(),
          ),
          GoRoute(
            path: MyReviewsPage.routePath,
            name: MyReviewsPage.routeName,
            builder: (context, state) => const MyReviewsPage(),
          ),
          // Wallet & Payments
          GoRoute(
            path: WalletPage.routePath,
            name: WalletPage.routeName,
            builder: (context, state) => const WalletPage(),
          ),
          // Admin Suite
          GoRoute(
            path: AdminDashboardPage.routePath,
            name: AdminDashboardPage.routeName,
            builder: (context, state) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: AdminKycQueuePage.routePath,
            name: AdminKycQueuePage.routeName,
            builder: (context, state) => const AdminKycQueuePage(),
          ),
          GoRoute(
            path: AdminDisputesPage.routePath,
            name: AdminDisputesPage.routeName,
            builder: (context, state) => const AdminDisputesPage(),
          ),
          GoRoute(
            path: AdminPayoutsPage.routePath,
            name: AdminPayoutsPage.routeName,
            builder: (context, state) => const AdminPayoutsPage(),
          ),
          GoRoute(
            path: AdminUsersPage.routePath,
            name: AdminUsersPage.routeName,
            builder: (context, state) => const AdminUsersPage(),
          ),
          GoRoute(
            path: AdminAuditLogsPage.routePath,
            name: AdminAuditLogsPage.routeName,
            builder: (context, state) => const AdminAuditLogsPage(),
          ),
          // Client Gaps
          GoRoute(
            path: OnDemandJobsPage.routePath,
            name: OnDemandJobsPage.routeName,
            builder: (context, state) => const OnDemandJobsPage(),
          ),
          GoRoute(
            path: RecommendationsPage.routePath,
            name: RecommendationsPage.routeName,
            builder: (context, state) => const RecommendationsPage(),
          ),
          GoRoute(
            path: DisputesPage.routePath,
            name: DisputesPage.routeName,
            builder: (context, state) => const DisputesPage(),
          ),
          // Projects (SHPH-134)
          GoRoute(
            path: ProjectListPage.routePath,
            name: ProjectListPage.routeName,
            builder: (context, state) => const ProjectListPage(),
          ),
          GoRoute(
            path: ProjectCreatePage.routePath,
            name: ProjectCreatePage.routeName,
            builder: (context, state) => const ProjectCreatePage(),
          ),
          GoRoute(
            path: ProjectDetailPage.routePath,
            name: ProjectDetailPage.routeName,
            builder: (context, state) {
              final id = int.tryParse(
                state.pathParameters['projectId'] ?? '',
              );
              return ProjectDetailPage(projectId: id ?? 0);
            },
          ),
          // Rooms (SHPH-133)
          GoRoute(
            path: RoomListPage.routePath,
            name: RoomListPage.routeName,
            builder: (context, state) => const RoomListPage(),
          ),
          GoRoute(
            path: RoomCreatePage.routePath,
            name: RoomCreatePage.routeName,
            builder: (context, state) => const RoomCreatePage(),
          ),
          GoRoute(
            path: RoomJoinPage.routePath,
            name: RoomJoinPage.routeName,
            builder: (context, state) => const RoomJoinPage(),
          ),
          GoRoute(
            path: RoomDetailPage.routePath,
            name: RoomDetailPage.routeName,
            builder: (context, state) => RoomDetailPage(
              roomId: state.pathParameters['roomId'] ?? '',
            ),
          ),
          // Provider Suite (extended)
          GoRoute(
            path: ProviderDashboardPage.routePath,
            name: ProviderDashboardPage.routeName,
            builder: (context, state) => const ProviderDashboardPage(),
          ),
          GoRoute(
            path: ProviderHomePage.routePath,
            name: ProviderHomePage.routeName,
            builder: (context, state) => const ProviderHomePage(),
          ),
          GoRoute(
            path: MyServicesPage.routePath,
            name: MyServicesPage.routeName,
            builder: (context, state) => const MyServicesPage(),
          ),
          GoRoute(
            path: PostServicePage.routePath,
            name: PostServicePage.routeName,
            builder: (context, state) {
              final idStr = state.uri.queryParameters['listingId'];
              final id = int.tryParse(idStr ?? '');
              return PostServicePage(listingId: id);
            },
          ),
          GoRoute(
            path: ProviderAvailabilityPage.routePath,
            name: ProviderAvailabilityPage.routeName,
            builder: (context, state) => const ProviderAvailabilityPage(),
          ),
          GoRoute(
            path: ProviderProfilePage.routePath,
            name: ProviderProfilePage.routeName,
            builder: (context, state) => ProviderProfilePage(
              providerId:
                  int.tryParse(state.pathParameters['providerId'] ?? '') ?? 0,
            ),
          ),
          GoRoute(
            path: ReviewScanPage.routePath,
            name: ReviewScanPage.routeName,
            builder: (context, state) => const ReviewScanPage(),
          ),
          // Security & Preferences
          GoRoute(
            path: SessionsPage.routePath,
            name: SessionsPage.routeName,
            builder: (context, state) => const SessionsPage(),
          ),
          GoRoute(
            path: BiometricSetupPage.routePath,
            name: BiometricSetupPage.routeName,
            builder: (context, state) => const BiometricSetupPage(),
          ),
          GoRoute(
            path: NotificationPreferencesPage.routePath,
            name: NotificationPreferencesPage.routeName,
            builder: (context, state) => const NotificationPreferencesPage(),
          ),
          // Discovery & Support
          GoRoute(
            path: CategoryDetailPage.routePath,
            name: CategoryDetailPage.routeName,
            builder: (context, state) => CategoryDetailPage(
              categoryId:
                  int.tryParse(state.pathParameters['categoryId'] ?? '') ?? 0,
              categoryName: state.uri.queryParameters['name'],
            ),
          ),
          GoRoute(
            path: SubcategoryPage.routePath,
            name: SubcategoryPage.routeName,
            builder: (context, state) => SubcategoryPage(
              parentId:
                  int.tryParse(state.pathParameters['parentId'] ?? '') ?? 0,
              parentName: state.uri.queryParameters['name'],
            ),
          ),
          GoRoute(
            path: EtaTrackingPage.routePath,
            name: EtaTrackingPage.routeName,
            builder: (context, state) => EtaTrackingPage(
              token: state.pathParameters['token'] ?? '',
            ),
          ),
          GoRoute(
            path: HelpAssistantPage.routePath,
            name: HelpAssistantPage.routeName,
            builder: (context, state) => const HelpAssistantPage(),
          ),
          // Feature Gap — New Routes
          GoRoute(
            path: WriteReviewPage.routePath,
            name: WriteReviewPage.routeName,
            builder: (context, state) => WriteReviewPage(
              bookingId: state.pathParameters['bookingId'] ?? '',
              serviceName: state.uri.queryParameters['serviceName'],
              serviceListingId: int.tryParse(
                state.uri.queryParameters['serviceListingId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: AdminKycDetailPage.routePath,
            name: AdminKycDetailPage.routeName,
            builder: (context, state) => AdminKycDetailPage(
              submissionId:
                  int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
          ),
          GoRoute(
            path: LocationPermissionPage.routePath,
            name: LocationPermissionPage.routeName,
            builder: (context, state) => const LocationPermissionPage(),
          ),
          GoRoute(
            path: ExplorePage.routePath,
            name: ExplorePage.routeName,
            builder: (context, state) => const ExplorePage(),
          ),
          GoRoute(
            path: ThemeSettingsPage.routePath,
            name: ThemeSettingsPage.routeName,
            builder: (context, state) => const ThemeSettingsPage(),
          ),
        ],
      );
}

// Custom redirect guard for role-based routing
class RoleBasedRedirectGuard {
  // Private constructor to prevent instantiation
  RoleBasedRedirectGuard._();

  /// Provider-only path prefixes. Non-pro users hitting these are sent home.
  static const _providerOnlyPrefixes = [
    '/provider-dashboard',
    '/provider-home',
    '/provider/my-services',
    '/provider/post-service',
    '/provider/availability',
    '/provider/profile/',
    '/provider/review-scan',
  ];

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

    if (!appStateNotifier.loggedIn) {
      return null;
    }

    final userId = currentUserUid;
    if (userId.isEmpty) {
      return null;
    }

    final userProfile = await _fetchUserProfile(userId);
    if (userProfile == null) {
      return null;
    }

    final currentPath = state.uri.toString();

    // Gate provider-only pages: non-pro users get redirected home.
    if (_isProviderOnlyPath(currentPath) && !_isProvider(userProfile)) {
      return '/home';
    }

    // Role-based routing logic with 4-state pro account lifecycle
    final proRedirect = _getProUserRedirect(userProfile, currentPath);
    if (proRedirect != null) {
      return proRedirect;
    }

    return null;
  }

  /// Whether the given path requires pro/provider role.
  static bool _isProviderOnlyPath(String path) {
    for (final prefix in _providerOnlyPrefixes) {
      if (path == prefix || path.startsWith(prefix)) {
        return true;
      }
    }
    return false;
  }

  /// Whether the profile belongs to a provider. Booleans are source of truth
  /// (per AGENTS.md); `role == 'pro'` is the legacy fallback.
  static bool _isProvider(Map<String, dynamic> profile) {
    final isProvider = profile['is_provider'] as bool?;
    if (isProvider != null) return isProvider;
    return profile['role'] == 'pro';
  }
}
