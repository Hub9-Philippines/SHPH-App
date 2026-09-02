import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/components/instant_dispatch_section.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/geographic_selection/geographic_selection_widget.dart';
import '/models/service_listing.dart';
import '/utils/emergency_categories.dart';
import '/services/logging_service.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import '/utils/geo_utils.dart';
import '../../pages/booking_funnel/booking_controller.dart';
import '../../pages/booking_funnel/booking_models.dart';
import '../../pages/booking_funnel/express_checkout_screen.dart';
import '../../pages/booking_funnel/widgets/booking_flow_route.dart';
import 'services_model.dart';

export 'services_model.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({
    super.key,
    this.initialCategory,
    this.initialFilter,
    this.initialSearch,
    this.emergencyMode = false,
  });

  final String? initialCategory;
  final String? initialFilter;
  final String? initialSearch;

  /// Urgent Assistance entry: limits the catalog to emergency domains.
  final bool emergencyMode;

  static String routeName = 'ServicesScreen';
  static String routePath = '/services';

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late ServicesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  Map<String, String> get _filterLabels => {
        'recommended': _l10n.svFilterRecommended,
        'topRated': _l10n.svFilterTopRated,
        'lowestPrice': _l10n.svFilterLowestPrice,
        'nearest': _l10n.svFilterNearest,
      };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ServicesModel.new);
    _model.emergencyMode = widget.emergencyMode;
    _checkDataLoaded();
  }

  Future<void> _checkDataLoaded() async {
    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_model.isLoading && mounted) {
        setState(() {});
        LoggingService.debug(
          'Service screen rebuilt after initial data load',
          tag: 'ServicesScreen',
        );
        return;
      }
    }
  }

  Future<void> _refreshServices() async {
    _model.dispose();
    _model = createModel(context, ServicesModel.new);
    _model.emergencyMode = widget.emergencyMode;
    _model.emergencyMode = widget.emergencyMode;
    if (widget.initialCategory != null) {
      _model.selectedCategory = widget.initialCategory;
    }
    if (widget.initialFilter != null) {
      _model.selectedFilter = widget.initialFilter;
    }
    if (widget.initialSearch != null) {
      _model.searchQuery = widget.initialSearch!;
      _model.searchController.text = widget.initialSearch!;
    }
    await _checkDataLoaded();
    if (mounted) {
      safeSetState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialCategory != null) {
      _model.selectedCategory = widget.initialCategory;
    }
    if (widget.initialFilter != null) {
      _model.selectedFilter = widget.initialFilter;
    }
    if (widget.initialSearch != null) {
      _model.searchQuery = widget.initialSearch!;
      _model.searchController.text = widget.initialSearch!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _model.searchFocusNode.requestFocus();
      });
    }
    if (!_model.isLoading) {
      _model.applyFilters();
    }
  }

  @override
  void dispose() {
    EasyDebounce.cancel('services_screen_search');
    _model.dispose();
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
                _buildTopBar(context),
                Expanded(
                  child: _model.isLoading
                      ? _buildLoadingState(context)
                      : RefreshIndicator(
                          color: AppTheme.of(context).primary,
                          onRefresh: _refreshServices,
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 12, 20, 12),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: _buildSearchBar(context),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildLocationPill(context),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildHeroSummary(context),
                                      const SizedBox(height: 18),
                                      _buildCategoryRail(context),
                                      if (_isEmergencySelection) ...[
                                        InstantDispatchSection(
                                          categoryName: _model.selectedCategory!,
                                          onDispatch: (_) =>
                                              _launchInstantDispatch(context),
                                        ),
                                      ],
                                      const SizedBox(height: 14),
                                      _buildSortRow(context),
                                      const SizedBox(height: 18),
                                    ],
                                  ),
                                ),
                              ),
                              _buildServiceResults(context),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTopBar(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.arrow_back_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l10n.bfServices,
                    style: AppTheme.of(context).titleLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: const Color(0xFF16202A),
                        ),
                  ),
                  Text(
                    _l10n.svSubtitle,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: const Color(0xFF6F7B86),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  bool get _isEmergencySelection =>
      _model.selectedCategory != null &&
      isEmergencyCategory(_model.selectedCategory);

  /// Launches express checkout for the top emergency result in the selected
  /// category with right-now urgency (the Instant Dispatch guarantee).
  void _launchInstantDispatch(BuildContext context) {
    final matches = _model.filteredServices;
    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.svNoDispatchPros),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final nearest = List<Map<String, dynamic>>.from(matches)
      ..sort((a, b) => (a['distanceKm'] as double)
          .compareTo(b['distanceKm'] as double));
    _openExpressCheckout(context, nearest.first);
  }

  Widget _buildLocationPill(BuildContext context) {
    final theme = AppTheme.of(context);
    final label = FFAppState().selectedLocationMode == 'device'
        ? _l10n.hmCurrentDeviceLocation
        : FFAppState().selectedAddressLabel.isNotEmpty
            ? FFAppState().selectedAddressLabel
            : _l10n.svSetLocation;
    return Material(
      color: theme.primary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
      child: InkWell(
        onTap: () => context
            .pushNamed(GeographicSelectionWidget.routeName),
        borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.place_rounded, size: 16, color: theme.primary),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 84),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.labelSmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                    color: theme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.expand_more_rounded,
                  size: 16, color: theme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) => Container(        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF5F6B76),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _model.searchController,
                focusNode: _model.searchFocusNode,
                onChanged: (value) {
                  EasyDebounce.debounce(
                    'services_screen_search',
                    const Duration(milliseconds: 250),
                    () {
                      if (!mounted) {
                        return;
                      }
                      setState(() {
                        _model.searchQuery = value;
                        _model.applyFilters();
                      });
                    },
                  );
                },
                decoration: InputDecoration(
                  hintText: _l10n.svSearchPlaceholder,
                  hintStyle: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: const Color(0xFF93A0AC),
                      ),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_model.searchController.text.isNotEmpty)
              InkWell(
                onTap: () {
                  setState(() {
                    _model.searchController.clear();
                    _model.searchQuery = '';
                    _model.applyFilters();
                  });
                },
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF7F8B97),
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _buildHeroSummary(BuildContext context) {
    final selectedCategory = _model.selectedCategory;
    final selectedFilter = _model.selectedFilter;
    final count = _model.filteredServices.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A7F64),
            Color(0xFF0FA57A),
            Color(0xFF68D2AA),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220FA57A),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedCategory != null && selectedCategory != 'All'
                ? selectedCategory
                : _l10n.svExploreEveryService,
            style: AppTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedFilter != null
                ? _l10n.svCountSorted(
                    count, _filterLabels[selectedFilter] ?? selectedFilter)
                : _l10n.svCountReady(count),
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: Colors.white.withValues(alpha: 0.86),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _summaryPill(
                context,
                icon: Icons.tune_rounded,
                label: selectedFilter == null
                    ? _l10n.svSmartRanking
                    : _filterLabels[selectedFilter] ?? selectedFilter,
              ),
              _summaryPill(
                context,
                icon: Icons.category_rounded,
                label: selectedCategory ?? _l10n.svAllCategories,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.of(context).labelMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      );

  Widget _buildCategoryRail(BuildContext context) => SizedBox(
        height: 46,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _model.categories.length,
          itemBuilder: (context, index) {
            final category = _model.categories[index];
            final isSelected = (_model.selectedCategory ?? 'All') == category ||
                (_model.selectedCategory == null && category == 'All');
            final isEmergency = isEmergencyCategory(category);
            return Padding(
              padding: const EdgeInsets.only(right: AppThemeData.spaceSm),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEmergency) ...[
                      Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: isSelected
                            ? AppTheme.of(context).onPrimary
                            : AppTheme.of(context).primary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(category == 'All' ? _l10n.spAll : category),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _model.selectedCategory =
                        category == 'All' ? null : category;
                    _model.applyFilters();
                  });
                },
                showCheckmark: false,
                side: BorderSide(
                  color: isEmergency && !isSelected
                      ? AppTheme.of(context).primary.withValues(alpha: 0.55)
                      : Colors.transparent,
                  width: isEmergency && !isSelected ? 1.4 : 0,
                ),
                backgroundColor: Colors.white,
                selectedColor: AppTheme.of(context).primary,
                labelStyle: AppTheme.of(context).labelMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                      color:
                          isSelected ? AppTheme.of(context).onPrimary : const Color(0xFF16202A),
                    ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            );
          },
        ),
      );

  Widget _buildSortRow(BuildContext context) {
    final theme = AppTheme.of(context);
    final options = <(String?, String)>[
      (null, _l10n.spDefault),
      ('recommended', _l10n.svFilterRecommended),
      ('topRated', _l10n.svFilterTopRated),
      ('lowestPrice', _l10n.svFilterLowestPrice),
      ('nearest', _l10n.svFilterNearest),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppThemeData.spaceSm),
        itemBuilder: (context, index) {
          final (value, label) = options[index];
          final active = _model.selectedFilter == value;
          return GestureDetector(
            onTap: () {
              setState(() {
                _model.selectedFilter = value;
                _model.applyFilters();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    active ? theme.primary : theme.primaryBackground,
                borderRadius:
                    BorderRadius.circular(AppThemeData.radiusPill),
                border: Border.all(
                  color: active ? theme.primary : theme.border,
                ),
              ),
              child: Text(
                label,
                style: theme.labelMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                  color: active ? Colors.white : theme.secondaryText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) => ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: const [
          ServiceCardSkeleton(),
          SizedBox(height: 14),
          ServiceCardSkeleton(),
          SizedBox(height: 14),
          ServiceCardSkeleton(),
        ],
      );

  Widget _buildServiceResults(BuildContext context) {
    final filteredServices = _model.filteredServices;
    if (filteredServices.isEmpty) {
      final hasCategoryFilter =
          _model.selectedCategory != null && _model.selectedCategory != 'All';
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color:
                          AppTheme.of(context).primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      hasCategoryFilter
                          ? Icons.category_outlined
                          : Icons.search_off_rounded,
                      size: 42,
                      color: AppTheme.of(context).primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    hasCategoryFilter
                        ? _l10n.svNoServicesAvailable
                        : _l10n.svNoServicesFound,
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).titleMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: const Color(0xFF16202A),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasCategoryFilter
                        ? _l10n.svNoCategoryListings
                        : _l10n.svTryBroaderKeyword,
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: const Color(0xFF6F7B86),
                        ),
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    onPressed: () {
                      setState(() {
                        _model.selectedCategory = null;
                        _model.selectedFilter = null;
                        _model.searchController.clear();
                        _model.searchQuery = '';
                        _model.applyFilters();
                      });
                    },
                    child: Text(_l10n.spResetFilters),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      sliver: SliverList.builder(
        itemCount: filteredServices.length,
        itemBuilder: (context, index) {
          final service = filteredServices[index];
          return _buildServiceCard(context, service);
        },
      ),
    );
  }

  void _openExpressCheckout(
      BuildContext context, Map<String, dynamic> service) {
    final appState = FFAppState();
    final lat = appState.selectedLatitude ?? GeoUtils.fallbackLat;
    final lng = appState.selectedLongitude ?? GeoUtils.fallbackLng;
    final listing = ServiceListing(
      id: service['id'] as int,
      title: service['title'] as String,
      categoryName: service['category'] as String?,
      description: service['description'] as String?,
      basePrice: double.tryParse(
          (service['price'] as String).replaceAll(RegExp('[^0-9.]'), '')),
      thumbnail: service['imageUrl'] as String?,
      isTimeMaterial: service['isTimeMaterial'] as bool? ?? false,
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
              ? _l10n.svPinnedAddress
              : appState.selectedAddressLine1.isNotEmpty
                  ? appState.selectedAddressLine1
                  : _l10n.svPinnedAddress,
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

  Widget _buildServiceCard(
    BuildContext context,
    Map<String, dynamic> service,
  ) {
    final theme = AppTheme.of(context);
    final isEmergency = isEmergencyCategory(service['category'] as String?);
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _openExpressCheckout(context, service),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppThemeData.spaceMd),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
            border: isEmergency
                ? Border.all(
                    color: theme.primary.withValues(alpha: 0.45),
                    width: 1.2,
                  )
                : null,
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppThemeData.radiusSm),
                          child: _ServiceCardImage(
                            imageUrl: service['imageUrl'] as String?,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius:
                                BorderRadius.circular(AppThemeData.radiusPill),
                            child: InkWell(
                              onTap: () {
                                final serviceId = service['id'] as int;
                                setState(() {
                                  if (_model.favorites.contains(serviceId)) {
                                    _model.favorites.remove(serviceId);
                                  } else {
                                    _model.favorites.add(serviceId);
                                  }
                                });
                              },
                              borderRadius:
                                  BorderRadius.circular(AppThemeData.radiusPill),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  _model.favorites.contains(service['id'] as int)
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: _model.favorites
                                          .contains(service['id'] as int)
                                      ? const Color(0xFFE2557B)
                                      : const Color(0xFF8A97A4),
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  service['title'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.titleSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    color: theme.primaryText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.verified_rounded,
                                  size: 14, color: theme.primary),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.near_me_rounded,
                                  size: 12, color: Color(0xFF6F7B86)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  service['distanceText'] as String? ??
                                      _l10n.svDistanceUnknown,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.labelSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                    ),
                                    color: theme.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4D6),
                              borderRadius:
                                  BorderRadius.circular(AppThemeData.radiusPill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 12, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 3),
                                Text(
                                  '${(service['rating'] as double).toStringAsFixed(1)}'
                                  ' (${service['reviewCount']})',
                                  style: theme.labelSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                    color: const Color(0xFF8A6A00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if ((service['description'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    service['description'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                      ),
                      color: theme.secondaryText,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _l10n.svStartingFee,
                            style: theme.labelSmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                              ),
                              color: theme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            service['price'] as String,
                            style: theme.titleSmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                              color: theme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      onPressed: () =>
                          _openExpressCheckout(context, service),
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      borderRadius: AppThemeData.radiusSm,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppThemeData.spaceMd,
                        vertical: 9,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _l10n.ccBookNow,
                            style: theme.labelLarge.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
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

class _ServiceCardImage extends StatelessWidget {
  const _ServiceCardImage({required this.imageUrl});

  static const double size = 84;

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();

    if (imageUrl == null || imageUrl!.isEmpty) {
      return const _ServiceCardImageFallback();
    }

    return Image.network(
      imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      cacheWidth: cacheSize,
      cacheHeight: cacheSize,
      errorBuilder: (context, error, stackTrace) =>
          const _ServiceCardImageFallback(),
    );
  }
}

class _ServiceCardImageFallback extends StatelessWidget {
  const _ServiceCardImageFallback();

  @override
  Widget build(BuildContext context) => Container(
        width: _ServiceCardImage.size,
        height: _ServiceCardImage.size,
        color: const Color(0xFFE8EDF2),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.of(context).secondaryText,
        ),
      );
}
