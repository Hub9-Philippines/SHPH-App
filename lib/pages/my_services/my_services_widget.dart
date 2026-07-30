import 'package:flutter/material.dart';

import '/components/empty_state.dart';
import '/components/error_state.dart';
import '/components/status_pill.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'my_services_model.dart';

export 'my_services_model.dart';

class MyServicesWidget extends StatefulWidget {
  const MyServicesWidget({super.key});

  static String routeName = 'MyServices';
  static String routePath = '/my-services';

  @override
  State<MyServicesWidget> createState() => _MyServicesWidgetState();
}

class _MyServicesWidgetState extends State<MyServicesWidget> {
  late MyServicesModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, MyServicesModel.new);
    _model.loadListings().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: const Text('My Services'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _model.fetchError != null
              ? Center(
                  child: ErrorState(
                  message: _model.fetchError!,
                  onRetry: () => _model.loadListings().then((_) => safeSetState(() {})),
                ))
              : _model.listings.isEmpty
                  ? const Center(child: EmptyState(icon: Icons.business_center_outlined, title: 'No services posted yet'))
                  : RefreshIndicator(
                      onRefresh: () =>
                          _model.loadListings().then((_) => safeSetState(() {})),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _model.listings.length,
                        itemBuilder: (context, index) =>
                            _buildListingCard(context, theme, index),
                      ),
                    ),
    );
  }

  Widget _buildListingCard(
      BuildContext context, AppThemeData theme, int index) {
    final listing = _model.listings[index];
    final isArchived = listing['status'] == 'archived';
    final isAvailable = listing['is_available'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.secondaryBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listing['title']?.toString() ?? '',
                          style: theme.titleSmall),
                      const SizedBox(height: 4),
                      Text(listing['category_name']?.toString() ?? '',
                          style: theme.bodySmall?.copyWith(
                              color: theme.secondaryText)),
                    ],
                  ),
                ),
                StatusPill(
                  label: isArchived
                      ? 'Archived'
                      : isAvailable
                          ? 'Available'
                          : 'Unavailable',
                  status: isArchived ? 'cancelled' : isAvailable ? 'open' : 'expired',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${listing['base_price']?.toString() ?? '0'}',
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.primary,
              ),
            ),
            if (listing['description']?.toString().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(listing['description'].toString(),
                  style: theme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const Divider(height: 24),
            Row(
              children: [
                if (!isArchived)
                  Expanded(
                    child: _actionButton(
                      theme,
                      isAvailable ? Icons.toggle_off : Icons.toggle_on,
                      isAvailable ? 'Available' : 'Unavailable',
                      () => _model
                          .toggleAvailability(index, !isAvailable)
                          .then((_) => safeSetState(() {})),
                      color: isAvailable ? theme.success : theme.textTertiary,
                    ),
                  ),
                if (!isArchived) const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    theme,
                    Icons.edit,
                    'Edit',
                    () {},
                    color: theme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    theme,
                    isArchived ? Icons.unarchive : Icons.archive_outlined,
                    isArchived ? 'Restore' : 'Archive',
                    () => _model
                        .toggleArchive(index)
                        .then((_) => safeSetState(() {})),
                    color: isArchived ? theme.success : theme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    AppThemeData theme,
    IconData icon,
    String label,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? theme.primary,
        side: BorderSide(color: color ?? theme.primary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
