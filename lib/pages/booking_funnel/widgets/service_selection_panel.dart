import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '/models/service_listing.dart';
import '/pages/search_page/search_page_widget.dart';
import '/services/service_listing_service.dart';
import '/theme/app_theme.dart';

class ServiceSelectionPanel extends StatefulWidget {
  const ServiceSelectionPanel({super.key});

  @override
  State<ServiceSelectionPanel> createState() => _ServiceSelectionPanelState();
}

class _ServiceSelectionPanelState extends State<ServiceSelectionPanel> {
  late Future<List<ServiceListing>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = ServiceListingService.instance.fetchServiceListings(
      ordering: '-rating',
      pageSize: 9,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Quick book',
                style: theme.labelMedium.override(
                  color: theme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pick a service',
              style: theme.titleLarge.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap any service to instantly configure your booking.',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<ServiceListing>>(
              future: _servicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _gridPlaceholder();
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Could not load services. Pull down to retry.',
                      style:
                          theme.bodySmall.override(color: theme.secondaryText),
                    ),
                  );
                }
                final services = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGrid(context, services),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        final router = GoRouter.of(context);
                        Navigator.of(context).pop();
                        router.pushNamed(SearchPageWidget.routeName);
                      },
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text('Search all services â†’'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridPlaceholder() {
    final theme = AppTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) => DecoratedBox(
            decoration: BoxDecoration(
              color: theme.alternate.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, List<ServiceListing> services) =>
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.92,
        ),
        itemBuilder: (context, index) {
          final service = services[index];
          return _ServicePickerTile(
            service: service,
            icon: _categoryIcon(service.categoryName),
            onTap: () => Navigator.of(context).pop(service),
          );
        },
      );

  IconData _categoryIcon(String? categoryName) {
    final category = (categoryName ?? '').toLowerCase();
    if (category.contains('clean')) {
      return Icons.cleaning_services_rounded;
    }
    if (category.contains('plumb')) {
      return Icons.plumbing_rounded;
    }
    if (category.contains('electric')) {
      return Icons.electrical_services_rounded;
    }
    if (category.contains('paint') || category.contains('decor')) {
      return Icons.format_paint_rounded;
    }
    if (category.contains('carp')) {
      return Icons.handyman_rounded;
    }
    if (category.contains('appliance')) {
      return Icons.kitchen_rounded;
    }
    if (category.contains('laundry')) {
      return Icons.local_laundry_service_rounded;
    }
    return Icons.home_repair_service_rounded;
  }
}

class _ServicePickerTile extends StatelessWidget {
  const _ServicePickerTile({
    required this.service,
    required this.icon,
    required this.onTap,
  });

  final ServiceListing service;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.alternate),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.bodySmall.override(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              service.formattedPrice,
              style: theme.labelSmall.override(
                color: theme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
