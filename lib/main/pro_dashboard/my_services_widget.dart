import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/models/service_listing.dart';
import '/services/service_listing_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'create_service_widget.dart';

class MyServicesWidget extends StatefulWidget {
  const MyServicesWidget({super.key});

  static const String routeName = 'MyServices';
  static const String routePath = '/pro/my-services';

  @override
  State<MyServicesWidget> createState() => _MyServicesWidgetState();
}

class _MyServicesWidgetState extends State<MyServicesWidget> {
  List<ServiceListing> _listings = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  final Set<int> _togglingIds = {};

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    try {
      final listings = await ServiceListingService.instance.fetchMyListings();
      if (mounted) {
        setState(() {
          _listings = listings;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      LoggingService.error('Error loading my listings: $e',
          tag: 'MyServicesWidget');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await _loadListings();
  }

  Future<void> _toggleAvailability(ServiceListing listing, bool value) async {
    if (_togglingIds.contains(listing.id)) return;

    setState(() => _togglingIds.add(listing.id));

    final idx = _listings.indexWhere((l) => l.id == listing.id);
    if (idx != -1) {
      setState(() {
        _listings[idx] = ServiceListing(
          id: listing.id,
          title: listing.title,
          category: listing.category,
          categoryName: listing.categoryName,
          provider: listing.provider,
          providerName: listing.providerName,
          providerPhoto: listing.providerPhoto,
          description: listing.description,
          basePrice: listing.basePrice,
          priceUnit: listing.priceUnit,
          status: value ? 'active' : 'draft',
          isAvailable: value ? 'true' : 'false',
          rating: listing.rating,
          thumbnail: listing.thumbnail,
          reviewCount: listing.reviewCount,
          isTimeMaterial: listing.isTimeMaterial,
          galleryUrls: listing.galleryUrls,
        );
      });
    }

    try {
      await ServiceListingService.instance
          .updateListing(id: listing.id, isAvailable: value);
    } catch (e) {
      LoggingService.error('Error toggling availability: $e',
          tag: 'MyServicesWidget');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update availability')),
        );
      }
      await _loadListings();
    } finally {
      if (mounted) {
        setState(() => _togglingIds.remove(listing.id));
      }
    }
  }

  Future<void> _confirmDelete(ServiceListing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Remove "${listing.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success =
        await ServiceListingService.instance.deleteListing(listing.id);
    if (mounted) {
      if (success) {
        setState(() => _listings.removeWhere((l) => l.id == listing.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete service')),
        );
      }
    }
  }

  Future<void> _toggleArchive(ServiceListing listing) async {
    final isArchived = listing.status == 'archived';
    ServiceListing? updated;
    if (isArchived) {
      updated = await ServiceListingService.instance.unarchiveListing(listing.id);
    } else {
      updated = await ServiceListingService.instance.archiveListing(listing.id);
    }

    if (updated != null && mounted) {
      final idx = _listings.indexWhere((l) => l.id == listing.id);
      if (idx != -1) {
        setState(() => _listings[idx] = updated!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArchived ? 'Service restored' : 'Service archived'),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(isArchived ? 'Failed to restore' : 'Failed to archive'),
        ),
      );
    }
  }

  Future<void> _addGalleryImage(ServiceListing listing) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;

      final url = await ServiceListingService.instance
          .uploadListingImage(listing.id, File(picked.path));

      if (url != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image added to gallery')),
        );
        await _loadListings();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      LoggingService.error('Error adding gallery image: $e',
          tag: 'MyServicesWidget');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _openEdit(ServiceListing listing) {
    context.pushNamed(CreateServiceWidget.routeName,
        queryParameters: {'edit': listing.id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Services',
          style: AppTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
        ),
        backgroundColor: AppTheme.of(context).primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () =>
                context.pushNamed(CreateServiceWidget.routeName),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _listings.length,
                    itemBuilder: (context, index) =>
                        _buildListingCard(_listings[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline_rounded,
              size: 64,
              color: AppTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'No services posted yet',
              style: AppTheme.of(context).titleMedium.override(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Post your first service to start receiving bookings.',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  context.pushNamed(CreateServiceWidget.routeName),
              icon: const Icon(Icons.add),
              label: const Text('Post a Service'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(ServiceListing listing) {
    final isArchived = listing.status == 'archived';
    final isAvailable = listing.isAvailable == 'true' ||
        listing.status == 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: AppTheme.of(context).titleMedium.override(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (listing.categoryName != null)
                        Text(
                          listing.categoryName!,
                          style: AppTheme.of(context).bodySmall.override(
                                color: AppTheme.of(context).secondaryText,
                              ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isArchived
                        ? const Color(0xFFF1F5F9)
                        : isAvailable
                            ? const Color(0xFFECFDF3)
                            : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isArchived
                        ? 'Archived'
                        : isAvailable
                            ? 'Available'
                            : 'Unavailable',
                    style: AppTheme.of(context).labelSmall.override(
                          fontWeight: FontWeight.w600,
                          color: isArchived
                              ? const Color(0xFF64748B)
                              : isAvailable
                                  ? const Color(0xFF027A48)
                                  : const Color(0xFFC2410C),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Price
            Text(
              listing.formattedPrice,
              style: AppTheme.of(context).titleSmall.override(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.of(context).primary,
                  ),
            ),
            // Description
            if (listing.description != null &&
                listing.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                listing.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
            ],
            // Gallery thumbnails
            if (listing.allImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: listing.allImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        listing.allImages[index],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: AppTheme.of(context).secondaryBackground,
                          child: const Icon(Icons.broken_image, size: 20),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Actions
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Availability toggle
                Row(
                  children: [
                    Switch(
                      value: isAvailable && !isArchived,
                      onChanged: isArchived
                          ? null
                          : (v) => _toggleAvailability(listing, v),
                      activeThumbColor: AppTheme.of(context).primary,
                    ),
                    Text(
                      'Available',
                      style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                  ],
                ),
                // Action buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_photo_alternate_outlined,
                          size: 20),
                      tooltip: 'Add Image',
                      onPressed: () => _addGalleryImage(listing),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit',
                      onPressed: () => _openEdit(listing),
                    ),
                    IconButton(
                      icon: Icon(
                        isArchived
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                        size: 20,
                      ),
                      tooltip: isArchived ? 'Restore' : 'Archive',
                      onPressed: () => _toggleArchive(listing),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(listing),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
