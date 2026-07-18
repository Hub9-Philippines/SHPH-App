import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/models/category.dart';
import '/api/models/paginated_response.dart';
import '/api/models/service_listing.dart';
import '/api/resources/services_api.dart';
import '/index.dart';
import '/theme/app_theme.dart';

/// Browse services within a category.
///
/// Mirrors `shph-app/src/views/services/CategoryDetailPage.vue`. There is no
/// dedicated category-detail endpoint — this page fetches the category's
/// listings via `ShphServicesApi.listListingsByCategory()` and optionally
/// shows subcategories via `listSubcategories()`.
class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  final int categoryId;
  final String? categoryName;

  static String routeName = 'CategoryDetail';
  static String routePath = '/category/:categoryId';

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<ShphServiceListing> _listings = const [];
  List<ShphCategory> _subcategories = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        ShphServicesApi.instance.listListingsByCategory(widget.categoryId),
        ShphServicesApi.instance.listSubcategories(widget.categoryId),
      ]);
      final listingsResp = results[0] as PaginatedResponse<ShphServiceListing>;
      final subResp = results[1] as PaginatedResponse<ShphCategory>;
      if (mounted) {
        setState(() {
          _listings = listingsResp.results;
          _subcategories = subResp.results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load category: $e';
        });
      }
    }
  }

  Future<void> _openSubcategory(ShphCategory sub) async {
    await context
        .push('/category/${sub.id}?name=${Uri.encodeComponent(sub.name)}');
  }

  Future<void> _openListing(ShphServiceListing listing) async {
    await context.push(
      '${ProductPageWidget.routePath}?serviceId=${listing.id}'
      '&serviceName=${Uri.encodeComponent(listing.title)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'Category',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadData)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      if (_subcategories.isNotEmpty) ...[
                        Text('Subcategories',
                            style: theme.titleMedium
                                .override(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _subcategories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final sub = _subcategories[i];
                              return _SubcategoryChip(
                                category: sub,
                                onTap: () => _openSubcategory(sub),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text('Services (${_listings.length})',
                          style: theme.titleMedium
                              .override(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (_listings.isEmpty)
                        _EmptyCard(label: 'No services in this category yet')
                      else
                        ..._listings.map((l) => _ListingCard(
                              listing: l,
                              onTap: () => _openListing(l),
                            )),
                    ],
                  ),
                ),
    );
  }
}

class _SubcategoryChip extends StatelessWidget {
  const _SubcategoryChip({required this.category, required this.onTap});
  final ShphCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, color: theme.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.bodySmall.override(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing, required this.onTap});
  final ShphServiceListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: theme.primaryBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (listing.thumbnail != null && listing.thumbnail!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    listing.thumbnail!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: theme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.image, color: theme.primary),
                    ),
                  ),
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.image, color: theme.primary),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title,
                        style: theme.bodyMedium
                            .override(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (listing.providerName != null)
                      Text(listing.providerName!,
                          style: theme.bodySmall
                              .override(color: theme.secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    if (listing.basePrice != null)
                      Text('PHP ${listing.basePrice!.toStringAsFixed(0)}',
                          style: theme.bodySmall
                              .override(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(color: theme.secondaryText)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(color: theme.secondaryText)),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
