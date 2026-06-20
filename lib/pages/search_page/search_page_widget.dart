import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/backend/supabase/database/tables/bookings.dart';
import '/backend/supabase/database/tables/service_listings.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/bookings_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
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
  List<ServiceListingsRow> _searchResults = [];
  bool _isSearching = false;
  bool _showFilters = false;
  String? _selectedCategory;
  String? _selectedRating;
  String? _selectedPriceSort;
  List<String> _recentSearches = [];
  List<BookingsRow> _recentBookings = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, SearchPageModel.new);
    _showFilters = widget.openFilters;
    _loadRecentSearches();
    _loadRecentBookings();
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

  @override
  void dispose() {
    _model.dispose();
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      safeSetState(() {
        _searchResults = [];
      });
      return;
    }

    await _saveRecentSearch(query);

    safeSetState(() {
      _isSearching = true;
    });

    try {
      var queryBuilder = ServiceListingsTable().queryRows(
        queryFn: (q) => q.ilike('title', '%$query%'),
      );

      // Apply category filter
      if (_selectedCategory != null) {
        queryBuilder = ServiceListingsTable().queryRows(
          queryFn: (q) => q
              .ilike('title', '%$query%')
              .eq('category_name', _selectedCategory!),
        );
      }

      // Apply rating filter
      if (_selectedRating != null) {
        final minRating = double.parse(_selectedRating!);
        queryBuilder = ServiceListingsTable().queryRows(
          queryFn: (q) =>
              q.ilike('title', '%$query%').gte('rating', minRating.toString()),
        );
      }

      // Apply price sort
      if (_selectedPriceSort != null) {
        final ascending = _selectedPriceSort == 'low';
        queryBuilder = ServiceListingsTable().queryRows(
          queryFn: (q) => q
              .ilike('title', '%$query%')
              .order('base_price', ascending: ascending),
        );
      }

      final results = await queryBuilder;

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
      safeSetState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Widget _buildServiceCard(ServiceListingsRow service) => GestureDetector(
        onTap: () => context.pushNamed(
          ProductPageWidget.routeName,
          extra: <String, dynamic>{
            'serviceName': service.title,
            'category': service.categoryName ?? 'Service',
            'price': service.basePrice != null
                ? '₱${service.basePrice}${service.priceUnit ?? ''}'
                : '₱0',
            'rating': double.tryParse(service.rating ?? '0') ?? 0.0,
            'reviewCount': service.reviewCount ?? 0,
            'imageUrl': service.thumbnail ?? '',
            'description':
                service.description ?? 'Professional service for your needs.',
            'serviceId': service.id,
            'providerId': service.provider?.toString() ?? '',
            'providerName': service.providerName ?? 'Provider',
            'providerPhoto': service.providerPhoto,
            'providerCategory': service.categoryName ?? 'Service',
          },
        ),
        child: Container(
          margin: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      service.thumbnail != null && service.thumbnail!.isNotEmpty
                          ? Image.network(
                              service.thumbnail!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 80,
                                height: 80,
                                color: AppTheme.of(context).secondaryText,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: AppTheme.of(context).primaryBackground,
                                ),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: AppTheme.of(context).secondaryText,
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppTheme.of(context).primaryBackground,
                              ),
                            ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.categoryName ?? 'Service',
                        style: AppTheme.of(context).bodySmall.override(
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.rating ?? '0',
                            style: AppTheme.of(context).bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${service.reviewCount ?? 0})',
                            style: AppTheme.of(context).bodySmall.override(
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.basePrice != null
                            ? '₱${service.basePrice}${service.priceUnit ?? ''}'
                            : '₱0',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: AppTheme.of(context).primary,
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
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

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for services',
              style: AppTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for "painting", "cleaning", or "plumbing"',
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            if (_recentSearches.isNotEmpty) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent searches',
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recentSearches
                          .map((search) => GestureDetector(
                                onTap: () {
                                  _searchController.text = search;
                                  _performSearch(search);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 14,
                                        color:
                                            AppTheme.of(context).secondaryText,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        search,
                                        style: AppTheme.of(context).bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
            if (_recentBookings.isNotEmpty) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent bookings',
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                          ),
                    ),
                    const SizedBox(height: 12),
                    ..._recentBookings.map((booking) => GestureDetector(
                          onTap: () {
                            _searchController.text =
                                booking.serviceListingId.toString();
                            _performSearch(booking.serviceListingId.toString());
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bookmark,
                                  size: 16,
                                  color: AppTheme.of(context).primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Booking #${booking.id.substring(0, 8)}',
                                    style: AppTheme.of(context).bodySmall,
                                  ),
                                ),
                                Text(
                                  booking.status,
                                  style:
                                      AppTheme.of(context).bodySmall.override(
                                            color: AppTheme.of(context).primary,
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildFilterPanel() => Container(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.of(context).alternate,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 8),
              child: Text(
                'Category',
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                children: [
                  _buildFilterChip('All', _selectedCategory == null, () {
                    safeSetState(() {
                      _selectedCategory = null;
                      _performSearch(_searchController.text);
                    });
                  }),
                  _buildFilterChip('Cleaning', _selectedCategory == 'Cleaning',
                      () {
                    safeSetState(() {
                      _selectedCategory = 'Cleaning';
                      _performSearch(_searchController.text);
                    });
                  }),
                  _buildFilterChip('Painting', _selectedCategory == 'Painting',
                      () {
                    safeSetState(() {
                      _selectedCategory = 'Painting';
                      _performSearch(_searchController.text);
                    });
                  }),
                  _buildFilterChip('Plumbing', _selectedCategory == 'Plumbing',
                      () {
                    safeSetState(() {
                      _selectedCategory = 'Plumbing';
                      _performSearch(_searchController.text);
                    });
                  }),
                  _buildFilterChip(
                      'Electrical', _selectedCategory == 'Electrical', () {
                    safeSetState(() {
                      _selectedCategory = 'Electrical';
                      _performSearch(_searchController.text);
                    });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Rating Filter
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 8),
              child: Text(
                'Rating',
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                children: [
                  _buildFilterChip('All', _selectedRating == null, () {
                    safeSetState(() {
                      _selectedRating = null;
                      _performSearch(_searchController.text);
                    });
                  }),
                  _buildFilterChip('4.0+', _selectedRating == '4.0', () {
                    safeSetState(() {
                      _selectedRating = '4.0';
                      _performSearch(_searchController.text);
                    });
                  }),
                  _buildFilterChip('4.5+', _selectedRating == '4.5', () {
                    safeSetState(() {
                      _selectedRating = '4.5';
                      _performSearch(_searchController.text);
                    });
                  }),
                  _buildFilterChip('5.0', _selectedRating == '5.0', () {
                    safeSetState(() {
                      _selectedRating = '5.0';
                      _performSearch(_searchController.text);
                    });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Price Sort
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 8),
              child: Text(
                'Price',
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                children: [
                  _buildFilterChip('All', _selectedPriceSort == null, () {
                    safeSetState(() {
                      _selectedPriceSort = null;
                      _performSearch(_searchController.text);
                    });
                  }),
                  _buildFilterChip('Low to High', _selectedPriceSort == 'low',
                      () {
                    safeSetState(() {
                      _selectedPriceSort = 'low';
                      _performSearch(_searchController.text);
                    });
                  }),
                  _buildFilterChip('High to Low', _selectedPriceSort == 'high',
                      () {
                    safeSetState(() {
                      _selectedPriceSort = 'high';
                      _performSearch(_searchController.text);
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
        child: FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) => onTap(),
          selectedColor: AppTheme.of(context).primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.of(context).primaryText,
            fontSize: 13,
          ),
          backgroundColor: AppTheme.of(context).secondaryBackground,
        ),
      );

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Text(
              'Search',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                    ),
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                  ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.close : Icons.filter_list,
                  color: AppTheme.of(context).primaryText,
                ),
                onPressed: () {
                  safeSetState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
            ],
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 20),
                    child: Hero(
                      tag: 'searchBarHero',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          height: MediaQuery.of(context).size.width * 0.13,
                          constraints: const BoxConstraints(
                            minHeight: 45,
                            maxHeight: 65,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                10, 0, 10, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.magnifyingGlass,
                                  color: Color(0x6B14181B),
                                  size: 24,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: TextField(
                                      controller: _searchController,
                                      autofocus: true,
                                      onChanged: _performSearch,
                                      decoration: InputDecoration(
                                        hintText: 'Search for services...',
                                        hintStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              color: const Color(0xE357636C),
                                              fontSize: 16,
                                            ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _performSearch('');
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showFilters) _buildFilterPanel(),
                  Expanded(
                    child: _isSearching
                        ? ListView.builder(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 20),
                            itemCount: 5,
                            itemBuilder: (context, index) =>
                                const SearchCardSkeleton(),
                          )
                        : _searchResults.isEmpty
                            ? _searchController.text.isEmpty
                                ? _buildEmptyState()
                                : const Center(
                                    child: Text(
                                      'No services found',
                                      style: TextStyle(
                                        color: Color(0xE357636C),
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                            : ListView.builder(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 20),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final service = _searchResults[index];
                                  return _buildServiceCard(service);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
