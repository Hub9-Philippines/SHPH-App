import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/models/service_listing.dart';
import '/services/service_listing_service.dart';
import '/theme/app_theme.dart';

class ServiceSelectionPanel extends StatefulWidget {
  const ServiceSelectionPanel({
    super.key,
    this.locationLabel,
  });

  final String? locationLabel;

  @override
  State<ServiceSelectionPanel> createState() => _ServiceSelectionPanelState();
}

class _ServiceSelectionPanelState extends State<ServiceSelectionPanel> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<ServiceListing>> _servicesFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reloadServices();
  }

  void _reloadServices() {
    _servicesFuture = ServiceListingService.instance.fetchServiceListings(
      ordering: '-rating',
      pageSize: 50,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.62,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: FutureBuilder<List<ServiceListing>>(
          future: _servicesFuture,
          builder: (context, snapshot) {
            final services = snapshot.data ?? const <ServiceListing>[];
            final filtered = services.where((service) {
              final q = _query.trim().toLowerCase();
              if (q.isEmpty) {
                return true;
              }
              return service.title.toLowerCase().contains(q) ||
                  (service.categoryName ?? '').toLowerCase().contains(q);
            }).toList();

            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.alternate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Start booking',
                          style: theme.labelMedium.override(
                            color: theme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose any service',
                        style: theme.titleLarge.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pick the exact service you need before choosing the time.',
                        style: theme.bodyMedium.override(
                          color: theme.secondaryText,
                        ),
                      ),
                      if ((widget.locationLabel ?? '').isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: theme.alternate),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.place_rounded,
                                  color: theme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pinned location',
                                      style: theme.labelMedium.override(
                                        color: theme.secondaryText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.locationLabel!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.bodyMedium.override(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.secondaryText,
                      ),
                      filled: true,
                      fillColor: theme.secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.alternate),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.alternate),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildBody(
                    context,
                    snapshot,
                    filtered,
                    scrollController,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<List<ServiceListing>> snapshot,
    List<ServiceListing> filtered,
    ScrollController scrollController,
  ) {
    final theme = AppTheme.of(context);

    if (snapshot.connectionState == ConnectionState.waiting) {
      return ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const _ServicePlaceholderCard(),
      );
    }

    if (snapshot.hasError) {
      return _PanelStateCard(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load services',
        subtitle: 'Check your connection and try again to continue booking.',
        actionLabel: 'Retry',
        onAction: () {
          setState(_reloadServices);
        },
      );
    }

    if (filtered.isEmpty) {
      return _PanelStateCard(
        icon: Icons.search_off_rounded,
        title: _query.trim().isEmpty
            ? 'No services available yet'
            : 'No services found',
        subtitle: _query.trim().isEmpty
            ? 'Please try again in a moment or refresh the list.'
            : 'Try a different service keyword or clear your search.',
        actionLabel: _query.trim().isEmpty ? 'Refresh' : 'Clear search',
        onAction: () {
          if (_query.trim().isEmpty) {
            setState(_reloadServices);
            return;
          }
          _searchController.clear();
          setState(() {
            _query = '';
          });
        },
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final service = filtered[index];
        return InkWell(
          onTap: () => Navigator.of(context).pop(service),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.alternate),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _categoryIcon(service.categoryName),
                    color: theme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: theme.bodyLarge.override(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if ((service.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodySmall.override(
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                      if ((service.categoryName ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          service.categoryName!,
                          style: theme.bodySmall.override(
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  service.formattedPrice,
                  style: theme.bodyMedium.override(
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.secondaryText,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

class _PanelStateCard extends StatelessWidget {
  const _PanelStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: theme.primary),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.titleSmall.override(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.bodySmall.override(
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicePlaceholderCard extends StatelessWidget {
  const _ServicePlaceholderCard();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.alternate.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 160,
                  decoration: BoxDecoration(
                    color: theme.alternate.withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 12,
            width: 48,
            decoration: BoxDecoration(
              color: theme.alternate.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
