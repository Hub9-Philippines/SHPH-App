import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/auth/auth_util.dart';
import '/app_state.dart';
import '/components/cupertino_ui/app_feedback.dart';
import '/components/refreshable_page.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pages/booking_funnel/booking_controller.dart';
import '/pages/booking_funnel/booking_models.dart';
import '/pages/booking_funnel/express_checkout_screen.dart';
import '/pages/booking_funnel/widgets/booking_flow_route.dart';
import '/pages/booking_funnel/widgets/service_selection_panel.dart';
import '/models/service_listing.dart';
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
  bool _isAccountMenuOpen = false;

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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Future<void> onRefresh() async {
    safeSetState(() {});
  }

  void _handleScroll() {
    final compact = _scrollController.hasClients && _scrollController.offset > 28;
    if (compact != _isHeaderCompact) {
      setState(() {
        _isHeaderCompact = compact;
      });
    }

    if (_isAccountMenuOpen && _scrollController.offset > 0) {
      setState(() {
        _isAccountMenuOpen = false;
      });
    }
  }

  void _toggleAccountMenu() {
    setState(() {
      _isAccountMenuOpen = !_isAccountMenuOpen;
    });
  }

  void _closeAccountMenu() {
    if (!_isAccountMenuOpen) {
      return;
    }
    setState(() {
      _isAccountMenuOpen = false;
    });
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

  Future<void> _startBookingProcess() async {
    final selectedService = await showModalBottomSheet<ServiceListing>(
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
              urgency: BookingUrgency.rightNow,
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
    _closeAccountMenu();
    await context.pushNamed(AddressesWidget.routeName);
  }

  Future<void> _openHelpSupport() async {
    _closeAccountMenu();
    await context.pushNamed(HelpPage.routeName);
  }

  Future<void> _signOut() async {
    _closeAccountMenu();
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
    final bookings = _prototypeBookings();
    final categories = _prototypeCategories();
    final providers = _prototypeProviders();
    final recommendedProviders = _prototypeRecommendedProviders();
    final accountName = currentUserDisplayName.trim().isNotEmpty
        ? currentUserDisplayName.trim()
        : 'Rina Santos';
    final accountEmail = currentUserEmail.trim().isNotEmpty
        ? currentUserEmail.trim()
        : 'rina@email.com';

    return GestureDetector(
      onTap: () {
        _closeAccountMenu();
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
                    slivers: [
                      SliverToBoxAdapter(
                        child: PrototypeAppHeader(
                          userName: _headerGreeting,
                          avatarUrl: currentUserPhoto,
                          hasUnreadNotifications: hasUnreadNotifications,
                          isCompact: _isHeaderCompact,
                          onNotificationTap: () => context.pushNamed(
                            MyNotificationsWidget.routeName,
                          ),
                          onAvatarTap: _toggleAccountMenu,
                          onSearchTap: _openSearchPage,
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 28),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
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
                                      onTrackTap: _startBookingProcess,
                                      onMessageTap: () => context.pushNamed(
                                        MessagesWidget.routeName,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                EmergencyHelpCard(onTap: _startBookingProcess),
                                const SizedBox(height: 16),
                                _HomeSectionHeader(
                                  title: 'EXPLORE SERVICES',
                                  subtitle: 'Popular local services, all in one place.',
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
                                    itemCount: categories.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                                    itemBuilder: (context, index) {
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
                                BayanihanPoolCard(
                                  onTap: _startBookingProcess,
                                ),
                                const SizedBox(height: 16),
                                SeasonalOfferCard(onTap: _startBookingProcess),
                                const SizedBox(height: 18),
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
                                    itemCount: providers.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final provider = providers[index];
                                      return TrendingProviderCard(
                                        name: provider.name,
                                        category: provider.category,
                                        avatarUrl: provider.avatarUrl,
                                        rating: provider.rating,
                                        reviewCount: provider.reviewCount,
                                        distanceKm: provider.distanceKm,
                                        startingPrice: provider.startingPrice,
                                        onTap: () => _openProvider(provider.providerId),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 18),
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
                    if (_isAccountMenuOpen)
                      Positioned.fill(
                        top: _isHeaderCompact ? 92 : 170,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _closeAccountMenu,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    if (_isAccountMenuOpen)
                      Positioned(
                        top: _isHeaderCompact ? 72 : 80,
                        right: 20,
                        child: _AccountMenu(
                          name: accountName,
                          email: accountEmail,
                          onManageAddresses: _openManageAddresses,
                          onHelpSupport: _openHelpSupport,
                          onSignOut: _signOut,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  List<_HomeBookingData> _prototypeBookings() {
    final now = DateTime.now();
    return [
      const _HomeBookingData(
        title: 'Lockout Assistance',
        providerName: 'Mario Santos',
        category: 'Locksmith',
        statusLabel: 'On the way',
        statusColor: Color(0xFF2563EB),
        statusBgColor: Color(0xFFEFF6FF),
        icon: Icons.key_rounded,
        iconBgColor: Color(0xFFEFF6FF),
        iconColor: Color(0xFF1E3A8A),
        subtitleInfo: 'ETA 12 min - PHP 350',
      ),
      _HomeBookingData(
        title: 'Deep Cleaning',
        providerName: 'Ana Cruz',
        category: 'Cleaning',
        statusLabel: 'In progress',
        statusColor: const Color(0xFFD97706),
        statusBgColor: const Color(0xFFFFFBEB),
        icon: Icons.cleaning_services_rounded,
        iconBgColor: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
        subtitleInfo: 'Started 9:05 AM - 2 of 3 rooms done',
      ),
    ];
  }

  List<_HomeCategoryData> _prototypeCategories() {
    return const [
      _HomeCategoryData(
        name: 'Cleaning',
        priceSubtitle: 'From PHP 499',
        icon: Icons.cleaning_services_rounded,
        gradientColors: [Color(0xFF0EA5E9), Color(0xFF1D4ED8)],
        badgeLabel: 'Popular',
      ),
      _HomeCategoryData(
        name: 'Plumbing',
        priceSubtitle: 'From PHP 599',
        icon: Icons.plumbing_rounded,
        gradientColors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
        badgeLabel: 'Fast help',
      ),
      _HomeCategoryData(
        name: 'Electrical',
        priceSubtitle: 'From PHP 699',
        icon: Icons.electrical_services_rounded,
        gradientColors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
        badgeLabel: 'Trusted',
        isDarkText: true,
      ),
      _HomeCategoryData(
        name: 'Painting',
        priceSubtitle: 'From PHP 799',
        icon: Icons.format_paint_rounded,
        gradientColors: [Color(0xFF8B5CF6), Color(0xFF2563EB)],
      ),
      _HomeCategoryData(
        name: 'More',
        priceSubtitle: 'All services',
        icon: Icons.grid_view_rounded,
        gradientColors: [Color(0xFFE2E8F0), Color(0xFFF8FAFC)],
        isDarkText: true,
      ),
    ];
  }

  List<_TrendingProviderData> _prototypeProviders() {
    return const [
      _TrendingProviderData(
        providerId: '101',
        name: 'Mila Reyes',
        category: 'Deep cleaning',
        avatarUrl: '',
        rating: 4.9,
        reviewCount: 128,
        distanceKm: 1.4,
        startingPrice: 549,
      ),
      _TrendingProviderData(
        providerId: '102',
        name: 'Arvin Santos',
        category: 'Plumbing repair',
        avatarUrl: '',
        rating: 4.8,
        reviewCount: 94,
        distanceKm: 2.1,
        startingPrice: 699,
      ),
      _TrendingProviderData(
        providerId: '103',
        name: 'Jessa Cruz',
        category: 'Electrical work',
        avatarUrl: '',
        rating: 4.9,
        reviewCount: 156,
        distanceKm: 2.8,
        startingPrice: 799,
      ),
    ];
  }

  List<_TrendingProviderData> _prototypeRecommendedProviders() {
    return const [
      _TrendingProviderData(
        providerId: '201',
        name: 'Pedro Reyes',
        category: 'Licensed Plumber',
        avatarUrl: 'https://i.pravatar.cc/80?img=11',
        rating: 4.9,
        reviewCount: 124,
        distanceKm: 1.2,
        startingPrice: 350,
      ),
      _TrendingProviderData(
        providerId: '202',
        name: 'Juan Dela Cruz',
        category: 'Electrical Expert',
        avatarUrl: 'https://i.pravatar.cc/80?img=68',
        rating: 4.8,
        reviewCount: 89,
        distanceKm: 2.4,
        startingPrice: 420,
      ),
    ];
  }
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
        width: 208,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    final color = isDanger ? AppDesignTokens.danger : AppDesignTokens.inkSecondary;
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
