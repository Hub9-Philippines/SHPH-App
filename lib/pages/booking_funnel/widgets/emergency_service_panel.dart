import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/l10n/app_localizations.dart';
import '/models/service_listing.dart';
import '/services/service_listing_service.dart';
import '/theme/app_theme.dart';
import '/utils/emergency_categories.dart';

/// Bottom-sheet picker for the home "Get Help" card. Lists only services
/// whose category is flagged as emergency (see [isEmergencyCategory]) and
/// returns the selected [ServiceListing] via `Navigator.pop`.
class EmergencyServicePanel extends StatefulWidget {
  const EmergencyServicePanel({super.key});

  @override
  State<EmergencyServicePanel> createState() => _EmergencyServicePanelState();
}

class _EmergencyServicePanelState extends State<EmergencyServicePanel> {
  late Future<List<ServiceListing>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = ServiceListingService.instance.fetchServiceListings(
      ordering: '-rating',
      pageSize: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
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
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppThemeData.destructiveCrimson.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emergency_rounded,
                      size: 16,
                      color: AppThemeData.destructiveCrimson,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.emBadge,
                      style: theme.labelMedium.override(
                        color: AppThemeData.destructiveCrimson,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.emTitle,
                style: theme.titleLarge.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.emSubtitle,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: FutureBuilder<List<ServiceListing>>(
                  future: _servicesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      );
                    }

                    final services = (snapshot.data ?? const <ServiceListing>[])
                        .where(
                          (service) =>
                              isEmergencyCategory(service.categoryName),
                        )
                        .toList();

                    if (services.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: services.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _EmergencyServiceTile(
                            service: services[index],
                            icon: _categoryIcon(services[index].categoryName),
                            onTap: () =>
                                Navigator.of(context).pop(services[index]),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sos_rounded,
            size: 40,
            color: theme.secondaryText.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.emEmpty,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(color: theme.secondaryText),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.emClose),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String? categoryName) {
    final category = (categoryName ?? '').toLowerCase();
    if (category.contains('plumb')) {
      return Icons.plumbing_rounded;
    }
    if (category.contains('electric')) {
      return Icons.electrical_services_rounded;
    }
    if (category.contains('lock')) {
      return Icons.lock_open_rounded;
    }
    if (category.contains('pest')) {
      return Icons.pest_control_rounded;
    }
    return Icons.emergency_rounded;
  }
}

class _EmergencyServiceTile extends StatelessWidget {
  const _EmergencyServiceTile({
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
            border: Border.all(color: theme.alternate),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppThemeData.destructiveCrimson.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppThemeData.destructiveCrimson, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodyMedium.override(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.categoryName ?? 'Service',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                service.formattedPrice,
                style: theme.labelLarge.override(
                  color: AppThemeData.destructiveCrimson,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}