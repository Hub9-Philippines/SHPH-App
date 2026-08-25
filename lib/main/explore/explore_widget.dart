import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/supabase.dart';
import '/components/content_container.dart';
import '/components/hero_offer_banner.dart';
import '/components/instant_dispatch_section.dart';
import '/components/invite_earn_banner.dart';
import '/components/provider_proximity_card.dart';
import '/components/quick_book_bar.dart';
import '/components/recommendation_card.dart';
import '/components/refreshable_page.dart';
import '/components/screen_header.dart';
import '/components/section_header.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/main/explore/explore_model.dart' show ExploreModel;
import '/models/service_listing.dart';
import '/theme/app_theme.dart';
import '/utils/category_icons.dart';
import '/utils/emergency_categories.dart';

export 'explore_model.dart';

class ExploreWidget extends StatefulWidget {
  const ExploreWidget({super.key});

  static String routeName = 'Explore';
  static String routePath = '/explore';

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget>
    with RefreshablePage<ExploreWidget> {
  late ExploreModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  int _refreshKey = 0;

  /// Emergency category picked in the rail; reveals the inline
  /// Instant Dispatch section beneath it.
  String? _emergencySelection;

  static const _tilePalettes = <List<Color>>[
    [Color(0xFF0F8A6C), Color(0xFF17B890)],
    [Color(0xFF1C6DD0), Color(0xFF54A6FF)],
    [Color(0xFFEF6C57), Color(0xFFFF9A62)],
    [Color(0xFF6C5CE7), Color(0xFF9C88FF)],
    [Color(0xFF0E7490), Color(0xFF22C3DD)],
    [Color(0xFF9A3412), Color(0xFFF97316)],
    [Color(0xFFB45309), Color(0xFFF59E0B)],
    [Color(0xFF334155), Color(0xFF64748B)],
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ExploreModel.new);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Future<void> onRefresh() async {
    _model.loadAll();
    setState(() {
      _refreshKey++;
    });
  }

  void _submitSearch(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.push('/services?search=${Uri.encodeComponent(trimmed)}');
  }

  void _openCategoryServices(CategoriesRow category) {
    context.push('/services?category=${Uri.encodeComponent(category.name)}');
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).bgPage,
          bottomNavigationBar: QuickBookBar(
            onUrgentAssistance: () => context.pushNamed(
              ServicesScreen.routeName,
              extra: <String, dynamic>{'emergencyMode': true},
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: 'Explore',
                  subtitle: 'Discover top-rated pros and seasonal deals.',
                  action: Icon(
                    Icons.explore_rounded,
                    color: AppTheme.of(context).primary,
                  ),
                ),
                Expanded(
                  child: ContentContainer(
                    variant: ContentVariant.full,
                    child: wrapWithRefresh(
                      child: ListView(
                        key: ValueKey('explore_feed_$_refreshKey'),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.only(bottom: 8),
                        children: [
                          _buildSearchAndCategories(context),
                          const SizedBox(height: AppThemeData.spaceXl),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16,
                                AppThemeData.spaceXl),
                            child: HeroOfferBanner(
                              imageAsset: 'assets/images/welcome-graphic.png',
                              onBookNow: () => context.push('/services'),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppThemeData.spaceXl),
                            child: _buildTopRatedNearYou(context),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppThemeData.spaceXl),
                            child: _buildRecommendations(context),
                          ),
                          InviteEarnBanner(
                            onShare: _shareInviteLink,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ------------------------------------------------------------------
  // Section 1 — Top search & category shortcuts
  // ------------------------------------------------------------------
  Widget _buildSearchAndCategories(BuildContext context) {
    final theme = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, AppThemeData.spaceLg, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border, width: 0.5),
              boxShadow: AppThemeData.shadowSoft,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _submitSearch,
                    style: theme.bodyMedium,
                    cursorColor: theme.primaryText,
                    decoration: InputDecoration(
                      hintText: 'Search services or providers',
                      hintStyle: theme.bodyMedium.copyWith(
                        color: theme.secondaryText,
                      ),
                      prefixIcon:
                          Icon(Icons.search_rounded, color: theme.secondaryText),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice search coming soon'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(Icons.mic_none_rounded, color: theme.secondaryText),
                ),
                IconButton(
                  onPressed: () => context.push('/searchPage'),
                  icon: Icon(Icons.tune_rounded, color: theme.secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionHeader(
            title: 'Service Category',
            seeAllLabel: 'View All',
            onSeeAll: () => context.push('/categories'),
          ),
          const SizedBox(height: AppThemeData.spaceMd),
          FutureBuilder<List<CategoriesRow>>(
            future: _model.categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 106,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppThemeData.spaceMd),
                    itemBuilder: (_, __) => SkeletonLoadingWidget(
                      width: 84,
                      height: 84,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                );
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final categories = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 106,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      // Headroom so the emergency bolt badge (-6 offset)
                      // floats fully above the tile instead of being clipped.
                      padding: const EdgeInsets.only(top: 8, bottom: 2),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppThemeData.spaceMd),
                      itemBuilder: (context, index) =>
                          _buildShortcutTile(categories[index], index),
                    ),
                  ),
                  if (_emergencySelection != null) ...[
                    const SizedBox(height: AppThemeData.spaceMd),
                    InstantDispatchSection(
                      categoryName: _emergencySelection!,
                      onDispatch: (_) => context.pushNamed(
                        ServicesScreen.routeName,
                        extra: <String, dynamic>{
                          'initialCategory': _emergencySelection,
                          'emergencyMode': true,
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutTile(CategoriesRow category, int index) {
    final palette = _tilePalettes[index % _tilePalettes.length];
    final isEmergency = isEmergencyCategory(category.name);
    final isSelectedEmergency = _emergencySelection == category.name;
    return GestureDetector(
      onTap: () {
        if (isEmergency) {
          // Emergency tiles select in place, revealing Instant Dispatch.
          safeSetState(() {
            _emergencySelection =
                isSelectedEmergency ? null : category.name;
          });
          return;
        }
        _openCategoryServices(category);
      },
      child: SizedBox(
        width: 96,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: palette,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: isEmergency
                        ? Border.all(
                            color: AppTheme.of(context).primary,
                            width: 2,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: palette.first.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      CategoryIcons.resolve(
                          slug: category.icon, name: category.name),
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                if (isEmergency)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (isSelectedEmergency)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -6,
                    child: Center(
                      child: Container(
                        height: 3,
                        width: 28,
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primary,
                          borderRadius:
                              BorderRadius.circular(AppThemeData.radiusPill),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppThemeData.spaceXs + 2),
            // Scale long names ("Aircon Repair") down instead of clipping.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                category.name,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: AppTheme.of(context).labelSmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Section 3 — Top Rated Near You carousel
  // ------------------------------------------------------------------
  Widget _buildTopRatedNearYou(BuildContext context) {
    // Spec: hide the whole section when the user has no selected location.
    final appState = FFAppState();
    final hasLocation = appState.selectedLatitude != null &&
        appState.selectedLongitude != null;
    if (!hasLocation) return const SizedBox.shrink();

    return FutureBuilder<List<ServiceListing>>(
      future: _model.topRatedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Top Rated Near You',
                padding: EdgeInsets.symmetric(horizontal: AppThemeData.spaceLg),
              ),
              const SizedBox(height: AppThemeData.spaceMd),
              SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppThemeData.spaceLg),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => SkeletonLoadingWidget(
                    width: 220,
                    height: 200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          );
        }
        final listings = snapshot.data ?? [];
        if (snapshot.hasError || listings.isEmpty) {
          // No rated providers returned → hide gracefully.
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Top Rated Near You',
              padding: EdgeInsets.symmetric(horizontal: AppThemeData.spaceLg),
            ),
            const SizedBox(height: AppThemeData.spaceMd),
            SizedBox(
              height: 216,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppThemeData.spaceLg),
                itemCount: listings.length,
                separatorBuilder: (_, __) => const SizedBox(width: 0),
                itemBuilder: (context, index) =>
                    _buildProximityCard(listings[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProximityCard(ServiceListing listing) {
    return ProviderProximityCard(
      providerName: listing.providerName ?? 'Service Provider',
      serviceType: listing.title,
      startingFee: listing.formattedPrice,
      rating: listing.ratingValue,
      distanceKm: listing.distanceKm,
      photoUrl: listing.providerPhoto,
      onBookNow: () => context.pushNamed(
        BookingFlowScreen.routeName,
        extra: <String, dynamic>{'service': listing},
      ),
      onTap: () => _openProductDetail(listing),
    );
  }

  // ------------------------------------------------------------------
  // Section 4 — Recommended for You feed
  // ------------------------------------------------------------------
  Widget _buildRecommendations(BuildContext context) {
    return FutureBuilder<List<ServiceListing>>(
      future: _model.recommendedFuture,
      builder: (context, snapshot) {
        final header = const SectionHeader(
          title: 'Recommended for You',
          padding: EdgeInsets.symmetric(horizontal: AppThemeData.spaceLg),
        );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Padding(
                padding: const EdgeInsets.all(AppThemeData.spaceLg),
                child: Column(
                  children: List.generate(
                    3,
                    (_) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: SkeletonLoadingWidget(
                          height: 90, borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        final listings = snapshot.data ?? [];
        if (snapshot.hasError || listings.isEmpty) {
          // Empty state; remaining sections still render.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Padding(
                padding: const EdgeInsets.fromLTRB(16, AppThemeData.spaceMd, 16, 0),
                child: Text(
                  'No recommendations yet — book a service to personalize this feed.',
                  style: AppTheme.of(context).bodySmall.copyWith(
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, AppThemeData.spaceMd, 16, 0),
              child: Column(
                children: listings
                    .map((listing) => RecommendationCard(
                          serviceName: listing.title,
                          providerName:
                              listing.providerName ?? 'Service Provider',
                          price: listing.formattedPrice,
                          providerPhoto: listing.providerPhoto,
                          rating: listing.ratingValue,
                          reviewCount: listing.reviewCount,
                          category: listing.categoryName,
                          onTap: () => _openProductDetail(listing),
                        ))
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openProductDetail(ServiceListing listing) {
    context.pushNamed(
      ProductPageWidget.routeName,
      extra: <String, dynamic>{
        'serviceName': listing.title,
        'category': listing.categoryName ?? '',
        'price': listing.formattedPrice,
        'rating': listing.ratingValue ?? 0.0,
        'reviewCount': listing.reviewCount ?? 0,
        'imageUrl': listing.thumbnail ?? '',
        'description': listing.description ?? '',
        'serviceId': listing.id,
        'providerId': listing.provider?.toString() ?? '',
        'providerName': listing.providerName ?? '',
        'providerPhoto': listing.providerPhoto,
        'providerCategory': listing.categoryName ?? '',
      },
    );
  }

  // ------------------------------------------------------------------
  // Section 5 — Invite & Earn share action
  // ------------------------------------------------------------------
  static const String _inviteUrl = 'https://serbisyohubph.com/invite';

  void _shareInviteLink() {
    Clipboard.setData(const ClipboardData(text: _inviteUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied — share it with friends!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
