import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/backend/supabase/database/tables/bookings.dart';
import '/backend/supabase/database/tables/service_listings.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/category_pill.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/content_container.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/models/service_listing.dart';
import '/services/bookings_service.dart';
import '/services/logging_service.dart';
import '/services/service_listing_service.dart';
import '/theme/app_theme.dart';
import '/utils/geo_utils.dart';
import '/utils/tagalog_service_keywords.dart';
import '../booking_funnel/booking_controller.dart';
import '../booking_funnel/booking_models.dart';
import '../booking_funnel/express_checkout_screen.dart';
import '../booking_funnel/widgets/booking_flow_route.dart';
import 'search_page_model.dart';

export 'search_page_model.dart';

class SearchPageWidget extends StatefulWidget {
  const SearchPageWidget({super.key, this.openFilters = false});

  static String routeName = 'SearchPage';
  static String routePath = '/searchPage';

  final bool openFilters;

  @override
  State<SearchPageWidget> createState() => _SearchPageWidgetState();
}

class _SearchPageWidgetState extends State<SearchPageWidget> {
  late SearchPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  static const List<String> _categoryOptions = [
    'Cleaning',
    'Painting',
    'Plumbing',
    'Electrical',
  ];
  static const List<String> _ratingOptions = ['4.0', '4.5', '5.0'];

  List<ServiceListingsRow> _searchResults = [];
  bool _isSearching = false;
  bool _showFilters = false;
  String? _selectedCategory;
  String? _selectedRating;
  String? _selectedPriceSort;
  List<String> _recentSearches = [];
  List<BookingsRow> _recentBookings = [];
  int _searchGeneration = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SearchPageModel.new);
    _showFilters = widget.openFilters;
    _loadRecentSearches();
    _loadRecentBookings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recent_searches') ?? [];
    safeSetState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _loadRecentBookings() async {
    try {
      final bookings = await BookingsService.instance.getUserBookings();
      safeSetState(() {
        _recentBookings = bookings.take(3).toList();
      });
    } catch (e) {
      LoggingService.error(
        'Error loading recent bookings',
        tag: 'SearchPage',
        error: e,
      );
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recent_searches') ?? []
      ..remove(query)
      ..insert(0, query);
    if (searches.length > 5) {
      searches.removeLast();
    }
    await prefs.setStringList('recent_searches', searches);
    safeSetState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _performSearch(String query) async {
    final searchGeneration = ++_searchGeneration;
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      safeSetState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    await _saveRecentSearch(normalizedQuery);
    safeSetState(() {
      _isSearching = true;
    });

    try {
      // Tagalog queries won't match English titles server-side. Fetch a broad
      // listing set and let the client-side Tagalog keyword expansion do the
      // matching.
      final isTagalog = isTagalogQuery(normalizedQuery);
      final apiServices = await ServiceListingService.instance
          .fetchServiceListings(search: isTagalog ? null : normalizedQuery);
      final services = apiServices
          .map(
            (listing) => ServiceListingsRow({
              'id': listing.id,
              'category': listing.category,
              'category_name': listing.categoryName,
              'provider': listing.provider,
              'provider_name': listing.providerName,
              'provider_photo': listing.providerPhoto,
              'title': listing.title,
              'description': listing.description,
              'base_price': listing.basePrice,
              'price_unit': listing.priceUnit,
              'status': listing.status,
              'is_available': listing.isAvailable ?? 'true',
              'rating': listing.rating,
              'thumbnail': listing.thumbnail,
              'review_count': listing.reviewCount ?? 0,
              'is_time_material': listing.isTimeMaterial,
            }),
          )
          .where((service) => service.isAvailable == 'true')
          .toList();

      final results = services.where((service) {
        final category = service.categoryName ?? '';
        final rating = double.tryParse(service.rating ?? '0') ?? 0.0;

        final matchesCategory = _selectedCategory == null ||
            _matchesCategory(_selectedCategory!, category);
        final matchesRating =
            _selectedRating == null || rating >= double.parse(_selectedRating!);

        final terms = expandTagalogQuery(normalizedQuery);
        final title = service.title.toLowerCase();
        final desc = (service.description ?? '').toLowerCase();
        final provider = (service.providerName ?? '').toLowerCase();
        final categoryLower = category.toLowerCase();
        final matchesQuery = terms.any(
              (term) => title.contains(term) || categoryLower.contains(term),
            ) ||
            desc.contains(normalizedQuery.toLowerCase()) ||
            provider.contains(normalizedQuery.toLowerCase()) ||
            _matchesCategory(normalizedQuery, category);

        return matchesCategory && matchesRating && matchesQuery;
      }).toList();

      if (_selectedPriceSort != null) {
        results.sort((a, b) {
          final priceA = a.basePrice ?? 0;
          final priceB = b.basePrice ?? 0;
          return _selectedPriceSort == 'low'
              ? priceA.compareTo(priceB)
              : priceB.compareTo(priceA);
        });
      } else {
        results.sort((a, b) {
          final ratingA = double.tryParse(a.rating ?? '0') ?? 0.0;
          final ratingB = double.tryParse(b.rating ?? '0') ?? 0.0;
          return ratingB.compareTo(ratingA);
        });
      }

      if (searchGeneration != _searchGeneration) {
        return;
      }

      safeSetState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      LoggingService.error(
        'Error searching services',
        tag: 'SearchPage',
        error: e,
      );
      if (searchGeneration != _searchGeneration) {
        return;
      }

      safeSetState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _scheduleSearch(String query) {
    EasyDebounce.debounce(
      'search_page_query',
      const Duration(milliseconds: 300),
      () => _performSearch(query),
    );
  }

  bool _matchesCategory(String selected, String actual) {
    final selectedNormalized = _normalizeCategory(selected);
    final actualNormalized = _normalizeCategory(actual);
    return actualNormalized == selectedNormalized ||
        actualNormalized.contains(selectedNormalized) ||
        selectedNormalized.contains(actualNormalized);
  }

  String _normalizeCategory(String value) => value
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp('[^a-z0-9]+'), '');

  void _applyQuickSearch(String value) {
    _searchController.text = value;
    _performSearch(value);
  }

  void _openCategoryBrowse(String category) {
    context.pushNamed(
      ServicesScreen.routeName,
      extra: <String, dynamic>{
        'initialCategory': category,
      },
    );
  }

  void _resetFilters() {
    safeSetState(() {
      _selectedCategory = null;
      _selectedRating = null;
      _selectedPriceSort = null;
    });
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  @override
  void dispose() {
    EasyDebounce.cancel('search_page_query');
    _model.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).secondaryBackground,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: wrapWithModel(
                          model: _model.backButtonModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const BackButtonWidget(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _l10n.spHeaderTitle,
                              style:
                                  AppTheme.of(context).titleLarge.override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        color: AppTheme.of(context).primaryText,
                                      ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _l10n.spHeaderSubtitle,
                              style:
                                  AppTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.plusJakartaSans(),
                                        color: AppTheme.of(context)
                                            .secondaryText,
                                      ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          safeSetState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppTheme.of(context).primaryBackground,
                          foregroundColor: AppTheme.of(context).primary,
                        ),
                        icon: Icon(
                          _showFilters
                              ? Icons.close_rounded
                              : Icons.tune_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          child: Column(
                            children: [
                              Hero(
                                tag: 'searchBarHero',
                                child: Material(
                                  color: Colors.transparent,
                                  child: _buildSearchBar(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildQuickCategoryRail(),
                              if (_showFilters) ...[
                                const SizedBox(height: 16),
                                _buildFilterPanel(),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (_isSearching)
                        SliverList.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) => const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                            child: SearchCardSkeleton(),
                          ),
                        )
                      else if (_searchResults.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            child: _searchController.text.isEmpty
                                ? _buildEmptyState()
                                : _buildNoResultsState(),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          sliver: SliverList.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) =>
                                _buildServiceCard(_searchResults[index]),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildSearchBar() {
    final theme = AppTheme.of(context);
    return Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: AppTheme.of(context).secondaryText,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                onChanged: _scheduleSearch,
                decoration: InputDecoration(
                  hintText: _l10n.spSearchPlaceholder,
                  hintStyle: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).textTertiary,
                      ),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              InkWell(
                onTap: () {
                  _searchController.clear();
                  _performSearch('');
                },
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppTheme.of(context).textTertiary,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      );
  }

  Widget _buildQuickCategoryRail() => SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildQuickCategoryChip(
              icon: Icons.cleaning_services_rounded,
              label: _l10n.hmCatCleaning,
              onTap: () => _openCategoryBrowse('Cleaning'),
            ),
            _buildQuickCategoryChip(
              icon: Icons.plumbing_rounded,
              label: _l10n.hmCatPlumbing,
              onTap: () => _openCategoryBrowse('Plumbing'),
            ),
            _buildQuickCategoryChip(
              icon: Icons.electrical_services_rounded,
              label: _l10n.hmCatElectrical,
              onTap: () => _openCategoryBrowse('Electrical'),
            ),
            _buildQuickCategoryChip(
              icon: Icons.format_paint_rounded,
              label: _l10n.hmCatPainting,
              onTap: () => _openCategoryBrowse('Painting & Decorating'),
            ),
            _buildQuickCategoryChip(
              icon: Icons.grid_view_rounded,
              label: _l10n.spAllServices,
              onTap: () => context.pushNamed(ServicesScreen.routeName),
            ),
          ],
        ),
      );

  Widget _buildQuickCategoryChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.of(context).border),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 14, color: AppTheme.of(context).primaryText),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                          color: AppTheme.of(context).primaryText,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildFilterPanel() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterGroup(
              title: _l10n.spCategory,
              children: [
                _buildChip(
                  label: _l10n.spAll,
                  selected: _selectedCategory == null,
                  onTap: () {
                    safeSetState(() => _selectedCategory = null);
                    _performSearch(_searchController.text);
                  },
                ),
                ..._categoryOptions.map(
                  (category) => _buildChip(
                    label: category,
                    selected: _selectedCategory == category,
                    onTap: () {
                      safeSetState(() => _selectedCategory = category);
                      _performSearch(_searchController.text);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildFilterGroup(
              title: _l10n.spMinRating,
              children: [
                _buildChip(
                  label: _l10n.spAll,
                  selected: _selectedRating == null,
                  onTap: () {
                    safeSetState(() => _selectedRating = null);
                    _performSearch(_searchController.text);
                  },
                ),
                ..._ratingOptions.map(
                  (rating) => _buildChip(
                    label: '$rating+',
                    selected: _selectedRating == rating,
                    onTap: () {
                      safeSetState(() => _selectedRating = rating);
                      _performSearch(_searchController.text);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildFilterGroup(
              title: _l10n.spPrice,
              children: [
                _buildChip(
                  label: _l10n.spDefault,
                  selected: _selectedPriceSort == null,
                  onTap: () {
                    safeSetState(() => _selectedPriceSort = null);
                    _performSearch(_searchController.text);
                  },
                ),
                _buildChip(
                  label: _l10n.spLowToHigh,
                  selected: _selectedPriceSort == 'low',
                  onTap: () {
                    safeSetState(() => _selectedPriceSort = 'low');
                    _performSearch(_searchController.text);
                  },
                ),
                _buildChip(
                  label: _l10n.spHighToLow,
                  selected: _selectedPriceSort == 'high',
                  onTap: () {
                    safeSetState(() => _selectedPriceSort = 'high');
                    _performSearch(_searchController.text);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                onPressed: _resetFilters,
                variant: AppButtonVariant.text,
                child: Text(_l10n.spResetFilters),
              ),
            ),
          ],
        ),
      );

  Widget _buildFilterGroup({
    required String title,
    required List<Widget> children,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.of(context).labelLarge.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: const Color(0xFF16202A),
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: children,
          ),
        ],
      );

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        side: BorderSide.none,
        backgroundColor: const Color(0xFFF3F6F8),
        selectedColor: AppTheme.of(context).primary,
        labelStyle: AppTheme.of(context).labelMedium.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              color: selected ? Colors.white : const Color(0xFF16202A),
            ),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 42,
                color: AppTheme.of(context).primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _l10n.spEmptyTitle,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: const Color(0xFF16202A),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _l10n.spEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: const Color(0xFF6F7B86),
                  ),
            ),
            const SizedBox(height: 20),
            AppButton(
              onPressed: () => context.pushNamed(ServicesScreen.routeName),
              child: Text(_l10n.spBrowseAllServices),
            ),
            if (_recentSearches.isNotEmpty) ...[
              const SizedBox(height: 26),
              _buildSuggestionBlock(
                title: _l10n.spRecentSearches,
                children: _recentSearches
                    .map(
                      (search) => _buildSuggestionChip(
                        icon: Icons.history_rounded,
                        label: search,
                        onTap: () => _applyQuickSearch(search),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (_recentBookings.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSuggestionBlock(
                title: _l10n.spRecentBookings,
                children: _recentBookings
                    .map(
                      (booking) => _buildSuggestionChip(
                        icon: Icons.bookmark_outline_rounded,
                        label: '${_l10n.spBookingRefPrefix}${booking.id.substring(0, 8)}',
                        onTap: () => _applyQuickSearch(
                            booking.serviceListingId.toString()),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      );

  Widget _buildSuggestionBlock({
    required String title,
    required List<Widget> children,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.of(context).labelLarge.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: const Color(0xFF16202A),
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: children,
          ),
        ],
      );

  Widget _buildSuggestionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: const Color(0xFF7F8B97)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: const Color(0xFF16202A),
                      ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildNoResultsState() => Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 46,
                color: AppTheme.of(context).primary,
              ),
              const SizedBox(height: 16),
              Text(
                _l10n.spNoServicesFound,
                style: AppTheme.of(context).titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      color: const Color(0xFF16202A),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _l10n.spNoResultsSubtitle,
                textAlign: TextAlign.center,
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: const Color(0xFF6F7B86),
                    ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  AppButton(
                    onPressed: () {
                      _resetFilters();
                      _searchController.clear();
                      _performSearch('');
                    },
                    child: Text(_l10n.spClearFilters),
                  ),
                  AppButton(
                    onPressed: () => context.pushNamed(
                      ServicesScreen.routeName,
                    ),
                    variant: AppButtonVariant.outlined,
                    child: Text(_l10n.spBrowseAllServices),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void _openExpressCheckout(BuildContext context, ServiceListingsRow row) {
    final appState = FFAppState();
    final lat = appState.selectedLatitude ?? GeoUtils.fallbackLat;
    final lng = appState.selectedLongitude ?? GeoUtils.fallbackLng;
    final listing = ServiceListing(
      id: row.id,
      title: row.title,
      categoryName: row.categoryName,
      description: row.description,
      basePrice: row.basePrice,
      priceUnit: row.priceUnit,
      thumbnail: row.thumbnail,
      rating: row.rating,
      reviewCount: row.reviewCount,
      isTimeMaterial: row.isTimeMaterial ?? false,
    );
    final controller = BookingFlowController(
      initialDraft: BookingDraft(
        urgency: BookingUrgency.rightNow,
        rooms: 1,
        cleaningType: ServiceType.standard,
        paymentMethod: BookingPaymentMethod.gcash,
        address: BookingAddress(
          label: appState.selectedLocationMode == 'device'
              ? _l10n.hmCurrentDeviceLocation
              : appState.selectedAddressLabel.isNotEmpty
                  ? appState.selectedAddressLabel
                  : _l10n.bfPinnedLocation,
          line1: appState.selectedLocationMode == 'device'
              ? _l10n.hmPinnedAddress
              : appState.selectedAddressLine1.isNotEmpty
                  ? appState.selectedAddressLine1
                  : _l10n.hmPinnedAddress,
          city: appState.selectedAddressCity.isNotEmpty
              ? appState.selectedAddressCity
              : 'Metro Manila',
        ),
        latitude: lat,
        longitude: lng,
      ),
    )..setService(listing);
    Navigator.of(context).push(
      buildBookingFlowRoute(
        ChangeNotifierProvider.value(
          value: controller,
          child: ExpressCheckoutScreen(service: listing),
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceListingsRow service) => _SearchServiceCard(
        service: service,
        onTap: () => _openExpressCheckout(context, service),
      );
}

class _SearchServiceCard extends StatelessWidget {
  const _SearchServiceCard({
    required this.service,
    required this.onTap,
  });

  final ServiceListingsRow service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchServiceThumbnail(imageUrl: service.thumbnail),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.titleMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: const Color(0xFF16202A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service.categoryName ??
                            AppLocalizations.of(context)!.spServiceFallback,
                        style: theme.bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: const Color(0xFF6F7B86),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Color(0xFFFFC44D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (double.tryParse(service.rating ?? '0') ?? 0)
                                .toStringAsFixed(1),
                            style: theme.bodySmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${service.reviewCount ?? 0} reviews',
                            style: theme.bodySmall.override(
                              font: GoogleFonts.plusJakartaSans(),
                              color: const Color(0xFF6F7B86),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        service.basePrice != null
                            ? 'PHP ${service.basePrice}${service.priceUnit ?? ''}'
                            : 'PHP 0',
                        style: theme.titleSmall.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: theme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchServiceThumbnail extends StatelessWidget {
  const _SearchServiceThumbnail({required this.imageUrl});

  static const double size = 92;

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (size * devicePixelRatio).round();

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: cacheSize,
              cacheHeight: cacheSize,
              errorBuilder: (context, error, stackTrace) =>
                  const _SearchServiceThumbnailFallback(),
            )
          : const _SearchServiceThumbnailFallback(),
    );
  }
}

class _SearchServiceThumbnailFallback extends StatelessWidget {
  const _SearchServiceThumbnailFallback();

  @override
  Widget build(BuildContext context) => Container(
        width: _SearchServiceThumbnail.size,
        height: _SearchServiceThumbnail.size,
        color: AppTheme.of(context).border,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.of(context).secondaryText,
        ),
      );
}
