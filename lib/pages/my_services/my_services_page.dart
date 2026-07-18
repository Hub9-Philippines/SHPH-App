import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/api/models/paginated_response.dart';
import '/api/models/service_listing.dart';
import '/api/resources/services_api.dart';
import '/theme/app_theme.dart';

/// Manage the provider's own service listings.
///
/// Mirrors `shph-app/src/views/provider/MyServicesPage.vue`. Backed by
/// `ShphServicesApi.listMyListings()` → GET `/api/services/listings/mine/`.
class MyServicesPage extends StatefulWidget {
  const MyServicesPage({super.key});

  static String routeName = 'MyServices';
  static String routePath = '/provider/my-services';

  @override
  State<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  List<ShphServiceListing> _listings = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadListings());
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final PaginatedResponse<ShphServiceListing> response =
          await ShphServicesApi.instance.listMyListings();
      if (mounted) {
        setState(() {
          _listings = response.results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load listings: $e';
        });
      }
    }
  }

  Future<void> _toggleAvailability(ShphServiceListing listing) async {
    final newValue = listing.isAvailable == 'true' ? 'false' : 'true';
    try {
      await ShphServicesApi.instance.updateListing(
        listing.id,
        {'is_available': newValue},
      );
      await _loadListings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  Future<void> _archive(ShphServiceListing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive listing?'),
        content: Text('"${listing.title}" will be hidden from search.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Archive')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ShphServicesApi.instance.archiveListing(listing.id);
      await _loadListings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archive failed: $e')),
        );
      }
    }
  }

  Future<void> _delete(ShphServiceListing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text(
            '"${listing.title}" will be permanently deleted. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ShphServicesApi.instance.deleteListing(listing.id);
      await _loadListings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _edit(ShphServiceListing listing) async {
    final refreshed = await context.push<bool>(
      '/provider/post-service?listingId=${listing.id}',
    );
    if (refreshed == true) await _loadListings();
  }

  Future<void> _create() async {
    final created = await context.push<bool>('/provider/post-service');
    if (created == true) await _loadListings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text('My Services',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
        backgroundColor: theme.primaryBackground,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _loadListings)
              : _listings.isEmpty
                  ? _EmptyView(onCreate: _create)
                  : RefreshIndicator(
                      onRefresh: _loadListings,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _listings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final listing = _listings[i];
                          return _ListingCard(
                            listing: listing,
                            onToggle: () => _toggleAvailability(listing),
                            onEdit: () => _edit(listing),
                            onArchive: () => _archive(listing),
                            onDelete: () => _delete(listing),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Post Service'),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.onToggle,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final ShphServiceListing listing;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isAvailable = listing.isAvailable == 'true';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(listing.title,
                    style: theme.titleMedium
                        .override(fontWeight: FontWeight.w700)),
              ),
              Switch(value: isAvailable, onChanged: (_) => onToggle()),
            ],
          ),
          if (listing.categoryName != null)
            Text(listing.categoryName!,
                style: theme.bodySmall.override(color: theme.secondaryText)),
          const SizedBox(height: 8),
          if (listing.basePrice != null)
            Text('PHP ${listing.basePrice!.toStringAsFixed(2)}',
                style: theme.bodyMedium.override(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onArchive,
                icon: const Icon(Icons.archive_outlined, size: 18),
                label: const Text('Archive'),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline,
                    color: Colors.red.shade700, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add_outlined,
                size: 64, color: theme.secondaryText),
            const SizedBox(height: 16),
            Text('No services yet',
                style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Post your first service to start receiving bookings.',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Post Service'),
            ),
          ],
        ),
      ),
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
