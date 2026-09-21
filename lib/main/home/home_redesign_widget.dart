import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/api/models/booking.dart';
import '/api/models/recommendation_item.dart';
import '/api/models/service_listing.dart';
import '/api/resources/bookings_api.dart';
import '/api/resources/recommendations_api.dart';
import '/api/resources/services_api.dart';
import '/auth/auth_util.dart';
import '/app_state.dart';
import '/components/cupertino_ui/app_feedback.dart';
import '/components/refreshable_page.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pages/booking_funnel/booking_controller.dart';
import '/pages/booking_funnel/booking_models.dart';
import '/pages/booking_funnel/express_checkout_screen.dart';
import '/pages/booking_funnel/widgets/booking_flow_route.dart';
import '/pages/booking_funnel/widgets/emergency_service_panel.dart';
import '/pages/booking_funnel/widgets/service_selection_panel.dart';
import '/models/service_listing.dart';
import '/services/auth_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import '/utils/geo_utils.dart';

class HomeRedesignWidget extends StatefulWidget {
  const HomeRedesignWidget({super.key});

  @override
  State<HomeRedesignWidget> createState() => _HomeRedesignWidgetState();
}

class _HomeRedesignWidgetState extends State<HomeRedesignWidget>
    with RefreshablePage<HomeRedesignWidget> {
  late final ScrollController _scrollController;
  late final VoidCallback _scrollListener;
  bool _isHeaderCompact = false;

  List<_HomeBookingData> _bookings = const [];
  List<_HomeCategoryData> _categories = const [];
  List<_TrendingProviderData> _providers = const [];
  List<_TrendingProviderData> _recommendedProviders = const [];
  bool _hasBookingHistory = false;
  bool _isHomeLoading = true;

  String get _displayName {
    final name = currentUserDisplayName.trim();
    if (name.isEmpty) {
      return 'there';
    }
    return name.split(' ').first;
  }

    String get _headerGreeting => _displayName == 'there'
      ? 'there'
      : _displayName;

  @override
  void initState() {
    super.initState();
    _scrollListener = _handleScroll;
    _scrollController = ScrollController()..addListener(_scrollListener);
    _loadHomeData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Future<void> onRefresh() async {
    // Pull to refresh reloads the signed-in user's profile (so the greeting
    // and avatar reflect fresh server data) and re-fetches the feed.
    try {
      await AuthService.instance.refreshCurrentUser();
    } catch (_) {
      // Non-fatal: fall through and still rebuild with current state.
    }
    await _loadHomeData();
    if (mounted) safeSetState(() {});
  }

  void _handleScroll() {
    final compact = _scrollController.hasClients && _scrollController.offset > 28;
    if (compact != _isHeaderCompact) {
      setState(() {
        _isHeaderCompact = compact;
      });
    }
  }

  Future<void> _openProfileActions() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _AccountMenu(
        name: currentUserDisplayName.trim(),
        email: currentUserEmail.trim(),
        onManageAddresses: _openManageAddresses,
        onHelpSupport: _openHelpSupport,
        onSignOut: _signOut,
      ),
    );
  }

  Future<void> _openSearchPage() async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SearchPageWidget(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(opacity: fade, child: child);
        },
      ),
    );
  }

  Future<void> _startBookingProcess({
    BookingUrgency urgency = BookingUrgency.rightNow,
    ServiceListing? preselectedService,
  }) async {
    final selectedService = preselectedService ??
        await showModalBottomSheet<ServiceListing>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const ServiceSelectionPanel(),
        );

    if (!mounted || selectedService == null) {
      return;
    }

    final appState = FFAppState();
    final lat = appState.selectedLatitude ?? GeoUtils.fallbackLat;
    final lng = appState.selectedLongitude ?? GeoUtils.fallbackLng;
    final bookingAddress = BookingAddress(
      label: appState.selectedLocationMode == 'device'
          ? 'Current device location'
          : appState.selectedAddressLabel.isNotEmpty
              ? appState.selectedAddressLabel
              : 'Pinned location',
      line1: appState.selectedLocationMode == 'device'
          ? 'Using live location'
          : appState.selectedAddressLine1.isNotEmpty
              ? appState.selectedAddressLine1
              : 'Pinned location',
      city: appState.selectedAddressCity.isNotEmpty
          ? appState.selectedAddressCity
          : 'Metro Manila',
    );

    await Navigator.of(context).push(
      buildBookingFlowRoute(
        ChangeNotifierProvider(
          create: (_) => BookingFlowController(
            initialDraft: BookingDraft(
              urgency: urgency,
              rooms: 1,
              cleaningType: ServiceType.standard,
              paymentMethod: BookingPaymentMethod.gcash,
              address: bookingAddress,
              latitude: lat,
              longitude: lng,
            ),
          )..setService(selectedService),
          child: ExpressCheckoutScreen(service: selectedService),
        ),
      ),
    );
  }

  /// Launches the emergency/urgent flow via a dedicated picker that lists only
/// emergency-category services, then starts the express checkout with
/// right-now urgency (same as the categories "Urgent Assistance" entry).
  Future<void> _openEmergencyBooking() async {
    final selectedService = await showModalBottomSheet<ServiceListing>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EmergencyServicePanel(),
    );

    if (!mounted || selectedService == null) {
      return;
    }

    await _startBookingProcess(
      urgency: BookingUrgency.rightNow,
      preselectedService: selectedService,
    );
  }

  Future<bool> _confirmExit() async {
    return await AppFeedback.confirmDialog(
          context: context,
          title: 'Exit app',
          message: 'Do you want to close Serbisyo Hub?',
          confirmText: 'Exit',
          cancelText: 'Cancel',
        ) ??
        false;
  }

  Future<void> _openTrackingPage(_HomeBookingData booking) async {
    await context.pushNamed(
      BookingDetailsWidget.routeName,
      extra: <String, dynamic>{
        'bookingId':
            booking.bookingId.isNotEmpty ? booking.bookingId : null,
      },
    );
  }

  void _openCategory(String categoryName) {
    if (categoryName == 'More') {
      context.pushNamed(CategoriesWidget.routeName);
      return;
    }

    context.pushNamed(
      ServicesScreen.routeName,
      extra: <String, dynamic>{
        'initialCategory': categoryName,
      },
    );
  }

  void _openProvider(String providerId) {
    context.pushNamed(
      ProviderProfileWidget.routeName,
      pathParameters: <String, String>{'providerId': providerId},
    );
  }

  Future<void> _openManageAddresses() async {
    Navigator.of(context).pop();
    await context.pushNamed(AddressesWidget.routeName);
  }

  Future<void> _openHelpSupport() async {
    Navigator.of(context).pop();
    await context.pushNamed(HelpPage.routeName);
  }

  Future<void> _signOut() async {
    Navigator.of(context).pop();
    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    if (!mounted) {
      return;
    }
    GoRouter.of(context).clearRedirectLocation();
    context.goNamedAuth(SplashWidget.routeName, context.mounted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final appState = context.watch<FFAppState>();
    final hasUnreadNotifications = appState.notificationCount > 0;
    final bookings = _bookings;
    final categories = _categories;
    final providers = _providers;
    final recommendedProviders = _recommendedProviders;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) {
            return;
          }

          if (!GoRouter.of(context).canPop()) {
            final shouldExit = await _confirmExit();
            if (shouldExit && mounted) {
              await SystemNavigator.pop();
            }
            return;
          }

          if (mounted) {
            context.pop();
          }
        },
        child: Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.primaryBackground,
                        const Color(0xFFF8FAFC),
                      ],
                    ),
                  ),
                  child: wrapWithRefresh(
                    controller: _scrollController,
                    displacement: _isHeaderCompact ? 64 : 150,
                    slivers: [
                      // Top spacer that reserves room for the pinned header
                      // while it is fully expanded (greeting view) at the top
                      // of the list. Kept at/under the header's expanded height
                      // so no gap shows; if the header grows slightly taller,
                      // the (opaque) header simply overlaps it invisibly.
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 150),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 28),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            if (bookings.isNotEmpty) ...[
                              _HomeSectionHeader(
                                title: 'YOUR BOOKINGS',
                                actionLabel: 'See more',
                                onActionTap: () =>
                                    context.pushNamed(BookingsWidget.routeName),
                              ),
                              const SizedBox(height: 12),
                              ...bookings.map(
                                (booking) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ActiveBookingCard(
                                    title: booking.title,
                                    providerName: booking.providerName,
                                    category: booking.category,
                                    statusLabel: booking.statusLabel,
                                    statusColor: booking.statusColor,
                                    statusBgColor: booking.statusBgColor,
                                    icon: booking.icon,
                                    iconBgColor: booking.iconBgColor,
                                    iconColor: booking.iconColor,
                                    subtitleInfo: booking.subtitleInfo,
                                    onTrackTap: () =>
                                        _openTrackingPage(booking),
                                    onMessageTap: () => context.pushNamed(
                                      MessagesWidget.routeName,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            _HomeSectionHeader(
                              title: 'Trending near you',
                              subtitle:
                                  'Verified pros with the strongest reviews nearby.',
                              actionLabel: 'See all',
                              onActionTap: () =>
                                  context.pushNamed(CategoriesWidget.routeName),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 154,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                itemCount: _isHomeLoading ? 3 : providers.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  if (_isHomeLoading) {
                                    return const TrendingProviderCardSkeleton();
                                  }
                                  final provider = providers[index];
                                  return TrendingProviderCard(
                                    name: provider.name,
                                    category: provider.category,
                                    avatarUrl: provider.avatarUrl,
                                    rating: provider.rating,
                                    reviewCount: provider.reviewCount,
                                    distanceKm: provider.distanceKm,
                                    startingPrice: provider.startingPrice,
                                    onTap: () =>
                                        _openProvider(provider.providerId),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 18),
                            EmergencyHelpCard(onTap: _openEmergencyBooking),
                            const SizedBox(height: 16),
                            _HomeSectionHeader(
                              title: 'EXPLORE SERVICES',
                              subtitle:
                                  'Popular local services, all in one place.',
                              actionLabel: 'Browse all',
                              onActionTap: () =>
                                  context.pushNamed(CategoriesWidget.routeName),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 104,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                itemCount: _isHomeLoading ? 4 : categories.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  if (_isHomeLoading) {
                                    return const HomeCategoryTileSkeleton();
                                  }
                                  final category = categories[index];
                                  return CategoryTileItem(
                                    name: category.name,
                                    priceSubtitle: category.priceSubtitle,
                                    icon: category.icon,
                                    gradientColors: category.gradientColors,
                                    badgeLabel: category.badgeLabel,
                                    isDarkText: category.isDarkText,
                                    onTap: () => _openCategory(category.name),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            SeasonalOfferCard(onTap: _startBookingProcess),
                            const SizedBox(height: 18),
                            if (_hasBookingHistory &&
                                _recommendedProviders.isNotEmpty) ...[
                              _HomeSectionHeader(
                                title: 'Recommended for you',
                                subtitle:
                                    'Based on what homeowners nearby are booking.',
                              ),
                              const SizedBox(height: 12),
                              ...recommendedProviders.map(
                                (provider) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _RecommendedProviderCard(
                                    provider: provider,
                                    onTap: () => _openProvider(
                                      provider.providerId,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            ReferralBannerCard(
                              promoCode: 'SHPH2026',
                              onTap: () => context.pushNamed(
                                ProfileWidget.routeName,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                // Pinned header: stays frozen at the top of the screen and
                // collapses from the tall greeting view into a compact
                // bar (search bar + notification + profile) as the list
                // scrolls. See _handleScroll -> _isHeaderCompact.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PrototypeAppHeader(
                    userName: _headerGreeting,
                    avatarUrl: currentUserPhoto,
                    hasUnreadNotifications: hasUnreadNotifications,
                    isCompact: _isHeaderCompact,
                    onNotificationTap: () => context.pushNamed(
                      MyNotificationsWidget.routeName,
                    ),
                    onAvatarTap: _openProfileActions,
                    onSearchTap: _openSearchPage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadHomeData() async {
    final results = await Future.wait<Object?>([
      _loadBookings(),
      _loadCategories(),
      _loadProviders(),
      _loadRecommendedProviders(),
    ]);

    if (!mounted) return;

    setState(() {
      _isHomeLoading = false;
      _bookings = (results[0] as List<_HomeBookingData>?) ?? const [];
      _categories = (results[1] as List<_HomeCategoryData>?) ?? const [];
      _providers = (results[2] as List<_TrendingProviderData>?) ?? const [];
      var recommended =
          (results[3] as List<_TrendingProviderData>?) ?? const [];
      // Final fallback for "Recommended for you": reuse the top-rated
      // providers already fetched for the trending rail so the section is
      // never rendered with a bare header. Applied here because the providers
      // list is only resolved once this batch completes.
      if (recommended.isEmpty && _providers.isNotEmpty) {
        recommended = _providers;
      }
      _recommendedProviders = recommended;
    });
  }

  Future<List<_HomeBookingData>> _loadBookings() async {
    try {
      final page = await ShphBookingsApi.instance.listUserBookings();
      _hasBookingHistory = page.results.isNotEmpty;
      final active = page.results
          .where((b) =>
              b.status != 'cancelled' &&
              b.status != 'completed' &&
              b.status != 'cancelled')
          .take(2)
          .toList();

      return active.map((b) {
        final status = b.status;
        final label = switch (status) {
          'confirmed' => 'Confirmed',
          'en_route' || 'assigned' => 'On the way',
          'on_site' || 'arrived' => 'On site',
          'in_progress' => 'In progress',
          'pending' => 'Pending',
          _ => status.isNotEmpty ? status : 'Pending',
        };
        return _HomeBookingData(
          title: b.listingTitle ?? 'Service booking',
          providerName: b.providerName ?? 'Waiting for a pro',
          category: _bookingCategoryLabel(b.status),
          statusLabel: label,
          statusColor: AppThemeData.successBrand,
          statusBgColor: AppThemeData.statusActiveBg,
          icon: Icons.home_work_rounded,
          iconBgColor: AppThemeData.statusActiveBg,
          iconColor: AppThemeData.successBrand,
          subtitleInfo: _bookingSubtitle(b),
          bookingId: b.id,
        );
      }).toList();
    } catch (e, s) {
      LoggingService.error(
        'Failed to load home bookings',
        tag: 'HomeRedesign',
        error: e,
        stackTrace: s,
      );
      return const [];
    }
  }

  Future<List<_HomeCategoryData>> _loadCategories() async {
    try {
      final page = await ShphServicesApi.instance.listCategories();
      final themes = _categoryPalette(Theme.of(context).brightness);
      return page.results.take(5).map((c) {
        final name = c.name;
        final palette = themes[c.name.toLowerCase()] ?? themes['default']!;
        return _HomeCategoryData(
          name: name,
          priceSubtitle: '',
          icon: palette.icon,
          gradientColors: palette.colors,
          badgeLabel: palette.badgeLabel,
          isDarkText: palette.isDarkText,
        );
      }).toList();
    } catch (e, s) {
      LoggingService.error(
        'Failed to load home categories',
        tag: 'HomeRedesign',
        error: e,
        stackTrace: s,
      );
      return const [];
    }
  }

  Future<List<_TrendingProviderData>> _loadProviders() async {
    try {
      final appState = FFAppState();
      final useLocation = GeoUtils.hasValidLocation(
        appState.selectedLatitude,
        appState.selectedLongitude,
      );
      final page = await ShphServicesApi.instance.listListings(
        ordering: '-rating',
        pageSize: 20,
        latitude: useLocation ? appState.selectedLatitude : null,
        longitude: useLocation ? appState.selectedLongitude : null,
      );

      // Trending = listings sorted by rating/reviews server-side (-rating).
      final byRating = [...page.results]..sort((a, b) {
          final ra = double.tryParse(a.rating ?? '0') ?? 0;
          final rb = double.tryParse(b.rating ?? '0') ?? 0;
          if (ra != rb) return rb.compareTo(ra);
          return (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0);
        });

      return byRating
          .take(10)
          .map(_fromListing)
          .where((p) => p.name.isNotEmpty)
          .toList();
    } catch (e, s) {
      LoggingService.error(
        'Failed to load home providers',
        tag: 'HomeRedesign',
        error: e,
        stackTrace: s,
      );
      return const [];
    }
  }

  Future<List<_TrendingProviderData>> _loadNearbyRecommendations() async {
    try {
      final appState = FFAppState();
      final useLocation = GeoUtils.hasValidLocation(
        appState.selectedLatitude,
        appState.selectedLongitude,
      );
      final nearby = await ShphRecommendationsApi.instance.nearby(
        lat: useLocation ? appState.selectedLatitude : null,
        lng: useLocation ? appState.selectedLongitude : null,
        radius: 10,
        limit: 10,
      );

      // Server-computed radius search — distance_km comes from the backend.
      return nearby
          .map((r) {
            final listing = r.listing;
            return _TrendingProviderData(
              providerId: listing.provider?.toString() ?? '',
              name: listing.providerName ?? '',
              category: listing.categoryName ?? 'Service',
              avatarUrl: listing.providerPhoto ?? '',
              rating: double.tryParse(listing.rating ?? '0') ?? 0,
              reviewCount: listing.reviewCount ?? 0,
              distanceKm: r.distanceKm ?? listing.distanceKm ?? 0,
              startingPrice: (listing.basePrice ?? 0).round(),
            );
          })
          .where((p) => p.name.isNotEmpty && p.providerId.isNotEmpty)
          .toList();
    } catch (e, s) {
      LoggingService.error(
        'Failed to load home nearby recommendations',
        tag: 'HomeRedesign',
        error: e,
        stackTrace: s,
      );
      return const [];
    }
  }

  Future<List<_TrendingProviderData>> _loadUserRecommendations() async {
    try {
      final items = await ShphRecommendationsApi.instance.user(limit: 10);

      // Booking-history-personalized feed — each item embeds a listing with
      // provider/rating/photo/category already parsed by the model.
      return items
          .map((RecommendationItem r) {
            final listing = r.listing;
            return _TrendingProviderData(
              providerId: listing.provider?.toString() ?? '',
              name: listing.providerName ?? '',
              category: listing.categoryName ?? 'Service',
              avatarUrl: listing.providerPhoto ?? '',
              rating: double.tryParse(listing.rating ?? '0') ?? 0,
              reviewCount: listing.reviewCount ?? 0,
              distanceKm: listing.distanceKm ?? 0,
              startingPrice: (listing.basePrice ?? 0).round(),
            );
          })
          .where((p) => p.name.isNotEmpty && p.providerId.isNotEmpty)
          .toList();
    } catch (e, s) {
      LoggingService.error(
        'Failed to load home user recommendations',
        tag: 'HomeRedesign',
        error: e,
        stackTrace: s,
      );
      return const [];
    }
  }

  Future<List<_TrendingProviderData>> _loadRecommendedProviders() async {
    final personalized = await _loadUserRecommendations();
    if (personalized.isNotEmpty) {
      return personalized;
    }
    return _loadNearbyRecommendations();
  }

  static _TrendingProviderData _fromListing(ShphServiceListing listing) {
    final rating = double.tryParse(listing.rating ?? '0') ?? 0;
    return _TrendingProviderData(
      providerId: listing.provider?.toString() ?? '${listing.id}',
      name: listing.providerName ?? '',
      category: listing.categoryName ?? 'Service',
      avatarUrl: listing.providerPhoto ?? '',
      rating: rating,
      reviewCount: listing.reviewCount ?? 0,
      distanceKm: listing.distanceKm ?? 0,
      startingPrice: (listing.basePrice ?? 0).round(),
    );
  }

  static String _bookingCategoryLabel(String status) => switch (status) {
        'in_progress' => 'In progress',
        'en_route' || 'on_site' || 'arrived' || 'assigned' => 'On the way',
        'confirmed' => 'Upcoming',
        _ => 'Booking',
      };

  static String _bookingSubtitle(ShphBooking b) {
    final status = b.status;
    if (status == 'in_progress') {
      return 'Service is now underway';
    }
    if (b.scheduledAt != null && b.scheduledAt!.isNotEmpty) {
      return 'Scheduled at ${b.scheduledAt}';
    }
    return 'Booking #${b.id}';
  }

  static Map<String, _CategoryPalette> _categoryPalette(
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;
    return {
      'default': _CategoryPalette(
        icon: Icons.build_rounded,
        colors: [AppThemeData.accentBlue, AppThemeData.accentNavy],
        isDarkText: isDark,
      ),
      'cleaning': _CategoryPalette(
        icon: Icons.cleaning_services_rounded,
        colors: const [Color(0xFF0EA5E9), Color(0xFF1D4ED8)],
        badgeLabel: 'Popular',
      ),
      'plumbing': _CategoryPalette(
        icon: Icons.plumbing_rounded,
        colors: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
        badgeLabel: 'Fast help',
      ),
      'electrical': _CategoryPalette(
        icon: Icons.electrical_services_rounded,
        colors: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
        badgeLabel: 'Trusted',
        isDarkText: true,
      ),
      'painting': _CategoryPalette(
        icon: Icons.format_paint_rounded,
        colors: const [Color(0xFF8B5CF6), Color(0xFF2563EB)],
      ),
    };
  }
}

class _CategoryPalette {
  const _CategoryPalette({
    required this.icon,
    required this.colors,
    this.badgeLabel,
    this.isDarkText = false,
  });

  final IconData icon;
  final List<Color> colors;
  final String? badgeLabel;
  final bool isDarkText;
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: AppDesignTokens.sectionHeader(),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: theme.bodySmall.override(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  actionLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.right,
                  style: theme.bodySmall.override(
                    fontWeight: FontWeight.w700,
                    color: AppDesignTokens.brand,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _RecommendedProviderCard extends StatelessWidget {
  const _RecommendedProviderCard({
    required this.provider,
    required this.onTap,
  });

  final _TrendingProviderData provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = provider.avatarUrl.trim().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppDesignTokens.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
        border: Border.all(color: AppDesignTokens.borderMedium, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppDesignTokens.surfaceMuted,
                      backgroundImage:
                          hasAvatar ? NetworkImage(provider.avatarUrl) : null,
                      child: hasAvatar
                          ? null
                          : const Icon(
                              Icons.person_rounded,
                              color: AppDesignTokens.inkMuted,
                              size: 20,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppDesignTokens.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              provider.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: AppDesignTokens.cardTitle().copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 13,
                            color: AppDesignTokens.brandAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${provider.category} · ${provider.distanceKm.toStringAsFixed(1)} km away',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: AppDesignTokens.caption(),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            provider.rating.toStringAsFixed(1),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '(${provider.reviewCount})',
                            style: AppDesignTokens.caption(
                              color: AppDesignTokens.inkMuted,
                            ).copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₱${provider.startingPrice}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppDesignTokens.brand,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'starting',
                      style: AppDesignTokens.caption(
                        color: AppDesignTokens.inkMuted,
                      ).copyWith(fontSize: 8.5),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.brandLight,
                        borderRadius:
                            BorderRadius.circular(AppDesignTokens.radiusPill),
                      ),
                      child: Text(
                        'Book',
                        style: AppDesignTokens.badge(
                          color: AppDesignTokens.brand,
                        ).copyWith(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu({
    required this.name,
    required this.email,
    required this.onManageAddresses,
    required this.onHelpSupport,
    required this.onSignOut,
  });

  final String name;
  final String email;
  final VoidCallback onManageAddresses;
  final VoidCallback onHelpSupport;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x220F172A),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppDesignTokens.cardTitle(),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: AppDesignTokens.caption(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              _AccountMenuItem(
                icon: Icons.location_on_outlined,
                label: 'Manage addresses',
                onTap: onManageAddresses,
              ),
              _AccountMenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & support',
                onTap: onHelpSupport,
              ),
              _AccountMenuItem(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                isDanger: true,
                onTap: onSignOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountMenuItem extends StatelessWidget {
  const _AccountMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final color =
        isDanger ? AppDesignTokens.danger : AppDesignTokens.inkSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppDesignTokens.cardTitle().copyWith(
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBookingData {
  const _HomeBookingData({
    required this.title,
    required this.providerName,
    required this.category,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBgColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.subtitleInfo,
    this.bookingId = '',
  });

  final String title;
  final String providerName;
  final String category;
  final String statusLabel;
  final Color statusColor;
  final Color statusBgColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String subtitleInfo;
  final String bookingId;
}

class _HomeCategoryData {
  const _HomeCategoryData({
    required this.name,
    required this.priceSubtitle,
    required this.icon,
    required this.gradientColors,
    this.badgeLabel,
    this.isDarkText = false,
  });

  final String name;
  final String priceSubtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final String? badgeLabel;
  final bool isDarkText;
}

class _TrendingProviderData {
  const _TrendingProviderData({
    required this.providerId,
    required this.name,
    required this.category,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.startingPrice,
  });

  final String providerId;
  final String name;
  final String category;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int startingPrice;
}
