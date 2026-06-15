import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ServicesModel.new);
    // Periodically check if data is loaded and trigger rebuild
    _checkDataLoaded();
  }

  Future<void> _checkDataLoaded() async {
    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_model.isLoading && mounted) {
        setState(() {});
        print('ServicesWidget - Data loaded, triggering rebuild');
        return;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use constructor parameters to set initial state
    if (widget.initialCategory != null) {
      _model.selectedCategory = widget.initialCategory;
    }
    if (widget.initialFilter != null) {
      _model.selectedFilter = widget.initialFilter;
    }
    if (widget.initialSearch != null) {
      _model.searchQuery = widget.initialSearch!;
      _model.searchController.text = widget.initialSearch!;
      // Focus on search field after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _model.searchFocusNode.requestFocus();
      });
    }
    // Only apply filters if data is already loaded, otherwise it will be applied after load
    if (!_model.isLoading) {
      _model.applyFilters();
    }
  }

  @override
  void dispose() {
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
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              _buildFilterBar(context),
              Expanded(
                child: _buildServiceList(context),
              ),
            ],
          ),
        ),
      );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: AppTheme.of(context).primaryBackground,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.of(context).primaryText,
            size: 24,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _model.searchController,
            focusNode: _model.searchFocusNode,
            onChanged: (value) {
              _model.searchQuery = value;
              _model.applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Search services...',
              hintStyle: AppTheme.of(context).bodySmall,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.of(context).secondaryText,
                size: 20,
              ),
            ),
          ),
        ),
        actions: const [],
      );

  Widget _buildFilterBar(BuildContext context) => Container(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
        color: AppTheme.of(context).primaryBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category FilterChips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _model.categories.length,
                itemBuilder: (context, index) {
                  final category = _model.categories[index];
                  final isSelected = _model.selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _model.selectedCategory = selected ? category : null;
                          _model.applyFilters();
                        });
                      },
                      selectedColor: AppTheme.of(context).primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.of(context).primaryText,
                        fontSize: 13,
                      ),
                      backgroundColor: AppTheme.of(context).secondaryBackground,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Combined Filter Dropdown
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _model.selectedFilter,
                hint: Text(
                  'Sort by',
                  style: AppTheme.of(context).bodySmall,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(
                      value: 'recommended', child: Text('Recommended')),
                  DropdownMenuItem(value: 'topRated', child: Text('Top Rated')),
                  DropdownMenuItem(
                      value: 'lowestPrice', child: Text('Lowest Price')),
                  DropdownMenuItem(value: 'nearest', child: Text('Nearest')),
                ],
                onChanged: (value) {
                  setState(() {
                    _model.selectedFilter = value;
                    _model.applyFilters();
                  });
                },
                isExpanded: true,
              ),
            ),
          ],
        ),
      );

  Widget _buildServiceList(BuildContext context) {
    final filteredServices = _model.filteredServices;

    if (_model.isLoading) {
      return ListView.builder(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        itemCount: 5,
        itemBuilder: (context, index) => const ServiceCardSkeleton(),
      );
    }

    if (filteredServices.isEmpty) {
      final hasCategoryFilter = _model.selectedCategory != null;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasCategoryFilter ? Icons.category_outlined : Icons.search_off,
              size: 64,
              color: AppTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              hasCategoryFilter ? 'No services available' : 'No services found',
              style: AppTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasCategoryFilter
                  ? 'Services in this category are coming soon. You can explore other categories in the meantime.'
                  : 'Try adjusting your filters',
              style: AppTheme.of(context).bodySmall,
              textAlign: TextAlign.center,
            ),
            if (hasCategoryFilter) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _model.selectedCategory = null;
                    _model.applyFilters();
                  });
                },
                child: const Text('View All Services'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        final service = filteredServices[index];
        return _buildServiceCard(context, service);
      },
    );
  }

  Widget _buildServiceCard(
          BuildContext context, Map<String, dynamic> service) =>
      GestureDetector(
        onTap: () => context.pushNamed(
          ProductPageWidget.routeName,
          extra: <String, dynamic>{
            'serviceName': service['title'] as String,
            'category': service['category'] as String,
            'price': service['price'] as String,
            'rating': service['rating'] as double,
            'reviewCount': service['reviewCount'] as int,
            'imageUrl': service['imageUrl'] as String,
            'description':
                'Professional service for your needs. Quality work guaranteed.',
            'providerId': service['providerId']?.toString() ?? '',
            'providerName': service['providerName'] as String? ?? 'Provider',
            'providerPhoto': service['providerPhoto'] as String?,
            'providerCategory': service['category'] as String? ?? 'Service',
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
                  child: Image.network(
                    service['imageUrl'] as String,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.of(context).secondaryText,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppTheme.of(context).primaryBackground,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['title'] as String,
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['category'] as String,
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
                            service['rating'].toString(),
                            style: AppTheme.of(context).bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${service['reviewCount']})',
                            style: AppTheme.of(context).bodySmall.override(
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            service['price'] as String,
                            style: AppTheme.of(context).bodyMedium.override(
                                  color: AppTheme.of(context).primary,
                                  font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600),
                                ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Implement favorite toggle with database
                              // Currently just toggles local state for UI feedback
                              final serviceId = service['id'] as int;
                              final isFavorited =
                                  _model.favorites.contains(serviceId);
                              if (isFavorited) {
                                _model.favorites.remove(serviceId);
                              } else {
                                _model.favorites.add(serviceId);
                              }
                              setState(() {});
                            },
                            child: Icon(
                              _model.favorites.contains(service['id'] as int)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _model.favorites
                                      .contains(service['id'] as int)
                                  ? Colors.red
                                  : AppTheme.of(context).secondaryText,
                              size: 24,
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
      );
}
