import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/models/service_listing.dart';
import '/services/logging_service.dart';
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
  });

  final String? initialCategory;
  final String? initialFilter;
  final String? initialSearch;

  static String routeName = 'ServicesScreen';
  static String routePath = '/services';

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late ServicesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Map<String, String> _filterLabels = {
    'recommended': 'Recommended',
    'topRated': 'Top rated',
    'lowestPrice': 'Lowest price',
    'nearest': 'Nearest first',
  };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ServicesModel.new);
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
          backgroundColor: const Color(0xFFF5F7FA),
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
                                      _buildSearchBar(context),
                                      const SizedBox(height: 16),
                                      _buildHeroSummary(context),
                                      const SizedBox(height: 18),
                                      _buildCategoryRail(context),
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
                    'Services',
                    style: AppTheme.of(context).titleLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: const Color(0xFF16202A),
                        ),
                  ),
                  Text(
                    'Find the right pro for the job.',
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

  Widget _buildSearchBar(BuildContext context) => Container(
        height: 58,
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
                  hintText: 'Search services or categories...',
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
                : 'Explore every service',
            style: AppTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedFilter != null
                ? '$count services sorted by ${_filterLabels[selectedFilter] ?? selectedFilter}'
                : '$count services ready to book',
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
                    ? 'Smart ranking'
                    : _filterLabels[selectedFilter] ?? selectedFilter,
              ),
              _summaryPill(
                context,
                icon: Icons.category_rounded,
                label: selectedCategory ?? 'All categories',
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
        height: 42,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _model.categories.length,
          itemBuilder: (context, index) {
            final category = _model.categories[index];
            final isSelected = (_model.selectedCategory ?? 'All') == category ||
                (_model.selectedCategory == null && category == 'All');
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _model.selectedCategory =
                        category == 'All' ? null : category;
                    _model.applyFilters();
                  });
                },
                showCheckmark: false,
                side: BorderSide.none,
                backgroundColor: Colors.white,
                selectedColor: AppTheme.of(context).primary,
                labelStyle: AppTheme.of(context).labelMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                      color:
                          isSelected ? Colors.white : const Color(0xFF16202A),
                    ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            );
          },
        ),
      );

  Widget _buildSortRow(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              '${_model.filteredServices.length} results',
              style: AppTheme.of(context).titleSmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                    color: const Color(0xFF16202A),
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _model.selectedFilter,
                hint: Text(
                  'Sort by',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                      ),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'default',
                    child: Text('Default'),
                  ),
                  ..._filterLabels.entries.map(
                    (entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  ),
                ],
                selectedItemBuilder: (context) => [
                  const Text('Default'),
                  ..._filterLabels.values.map(Text.new),
                ],
                onChanged: (value) {
                  setState(() {
                    _model.selectedFilter = value == 'default' ? null : value;
                    _model.applyFilters();
                  });
                },
              ),
            ),
          ),
        ],
      );

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
                        ? 'No services available'
                        : 'No services found',
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
                        ? 'That category does not have live listings right now. Try another category or clear the filter.'
                        : 'Try a broader keyword or switch the category filter.',
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: const Color(0xFF6F7B86),
                        ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _model.selectedCategory = null;
                        _model.selectedFilter = null;
                        _model.searchController.clear();
                        _model.searchQuery = '';
                        _model.applyFilters();
                      });
                    },
                    child: const Text('Reset filters'),
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
          label: appState.selectedAddressLabel.isNotEmpty
              ? appState.selectedAddressLabel
              : 'Pinned location',
          line1: appState.selectedAddressLine1.isNotEmpty
              ? appState.selectedAddressLine1
              : 'Pinned address',
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
  ) =>
      RepaintBoundary(
        child: GestureDetector(
          onTap: () => _openExpressCheckout(context, service),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _ServiceCardImage(
                      imageUrl: service['imageUrl'] as String?,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: const Color(0xFF16202A),
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)
                                .primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            service['category'] as String,
                            style: AppTheme.of(context).labelSmall.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: AppTheme.of(context).primary,
                                ),
                          ),
                        ),
                        if (_model.selectedFilter == 'nearest' &&
                            service['distanceText'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: AppTheme.of(context).primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  service['distanceText'] as String,
                                  style:
                                      AppTheme.of(context).labelSmall.override(
                                            font: GoogleFonts.plusJakartaSans(),
                                            color: AppTheme.of(context).primary,
                                          ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Color(0xFFFFC44D),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (service['rating'] as double).toStringAsFixed(1),
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: const Color(0xFF16202A),
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${service['reviewCount']} reviews',
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.plusJakartaSans(),
                                    color: const Color(0xFF6F7B86),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service['price'] as String,
                                style: AppTheme.of(context).titleSmall.override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: AppTheme.of(context).primary,
                                    ),
                              ),
                            ),
                            Material(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: () {
                                  final serviceId = service['id'] as int;
                                  if (_model.favorites.contains(serviceId)) {
                                    _model.favorites.remove(serviceId);
                                  } else {
                                    _model.favorites.add(serviceId);
                                  }
                                  setState(() {});
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    _model.favorites
                                            .contains(service['id'] as int)
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: _model.favorites
                                            .contains(service['id'] as int)
                                        ? const Color(0xFFE2557B)
                                        : const Color(0xFF8A97A4),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
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

class _ServiceCardImage extends StatelessWidget {
  const _ServiceCardImage({required this.imageUrl});

  static const double size = 92;

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
