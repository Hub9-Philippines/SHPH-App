import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/booking_action_row.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'bookings_model.dart';

export 'bookings_model.dart';

class BookingsWidget extends StatefulWidget {
  const BookingsWidget({super.key});

  static String routeName = 'Bookings';
  static String routePath = '/bookings';

  @override
  State<BookingsWidget> createState() => _BookingsWidgetState();
}

class _BookingsWidgetState extends State<BookingsWidget> {
  late BookingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BookingsModel.new);
    _model.onStateChanged = () {
      if (mounted) {
        safeSetState(() {});
      }
    };
  }

  @override
  void dispose() {
    searchController.dispose();
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
          backgroundColor: AppTheme.of(context).secondaryBackground,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: AppThemeData.spaceLg),
                      _buildSearchBar(context),
                      const SizedBox(height: AppThemeData.spaceMd),
                      _buildFilterChips(context),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppTheme.of(context).primary,
                    onRefresh: () => _model.reloadBookings(),
                    child: _model.errorMessage != null
                        ? _pullableState(
                            context,
                            _buildErrorState(context),
                          )
                        : _model.isLoading
                            ? ListView.separated(
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                    16, 16, 16, 24),
                                itemCount: 3,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, __) =>
                                    const BookingCardSkeleton(),
                              )
                            : _buildFilteredResults(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTopBar(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bookings',
                  style: AppTheme.of(context).headlineSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                        color: AppTheme.of(context).primaryText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track active work, completed visits, and next steps.',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: _model.reloadBookings,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.of(context).primaryBackground,
              foregroundColor: AppTheme.of(context).primary,
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      );  Widget _buildSearchBar(BuildContext context) {
    final theme = AppTheme.of(context);
    return TextField(
      controller: searchController,
      textInputAction: TextInputAction.search,
      onChanged: _model.setSearchQuery,
      style: theme.bodyMedium.override(
        font: GoogleFonts.plusJakartaSans(),
        color: theme.primaryText,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search services or providers',
        hintStyle: theme.bodyMedium.override(
          font: GoogleFonts.plusJakartaSans(),
          color: theme.textTertiary,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: theme.secondaryText,
          size: 22,
        ),
        suffixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: theme.secondaryText,
                ),
                onPressed: () {
                  searchController.clear();
                  _model.setSearchQuery('');
                  safeSetState(() {});
                },
              ),
        filled: true,
        fillColor: theme.primaryBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
          borderSide: BorderSide(color: theme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
          borderSide: const BorderSide(color: AppThemeData.actionPrimary),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final theme = AppTheme.of(context);
    final chips = <BookingsFilter, String>{
      BookingsFilter.all: 'All',
      BookingsFilter.pending: 'Pending',
      BookingsFilter.completed: 'Completed',
      BookingsFilter.canceled: 'Canceled',
    };
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        itemBuilder: (context, index) {
          final filter = chips.keys.elementAt(index);
          final label = chips.values.elementAt(index);
          final active = _model.selectedFilter == filter;
          return GestureDetector(
            onTap: () => safeSetState(() => _model.setFilter(filter)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? AppThemeData.actionPrimary
                    : theme.primaryBackground,
                borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
                border: Border.all(
                  color: active ? AppThemeData.actionPrimary : theme.border,
                ),
              ),
              child: Text(
                label,
                style: theme.labelMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                  color: active ? Colors.white : theme.secondaryText,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }

  /// Wraps non-scrollable states (error/empty) so the pull-to-refresh
  /// gesture stays available, matching Profile's always-scrollable feel.
  Widget _pullableState(BuildContext context, Widget child) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      );

  Widget _buildFilteredResults(BuildContext context) {
    final items = _model.filteredBookings;
    if (items.isEmpty) {
      return _pullableState(context, _buildEmptyState(context));
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildBookingCard(
        context,
        items[index],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingItem booking) {
    final theme = AppTheme.of(context);
    final (statusColor, statusBgColor) =
        AppThemeData.statusColors(booking.status.toLowerCase());
    final timeText = _formatTime(booking.scheduledExecutionDate);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: theme.border),
        boxShadow: AppThemeData.shadowSoft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
          onTap: () => _openDetails(context, booking),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppThemeData.radiusMd),
                      child: booking.imageUrl.trim().isNotEmpty
                          ? Image.network(
                              booking.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _bookingIconFallback(context),
                            )
                          : _bookingIconFallback(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.titleSmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                              ),
                              color: theme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            booking.providerName ?? booking.serviceType,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodySmall.override(
                              font: GoogleFonts.plusJakartaSans(),
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius:
                            BorderRadius.circular(AppThemeData.radiusPill),
                      ),
                      child: Text(
                        booking.status,
                        style: theme.labelSmall.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 15,
                      color: theme.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        timeText.isEmpty
                            ? booking.date
                            : '${booking.date} · $timeText',
                        style: theme.labelMedium.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: theme.secondaryText,
                        ),
                      ),
                    ),
                    Text(
                      'PHP ${booking.price.toStringAsFixed(0)}',
                      style: theme.labelLarge.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                        color: theme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BookingActionRow(
                  status: booking.status,
                  onTrack: () => _openDetails(context, booking),
                  onReschedule: _showRescheduleComingSoon,
                  onReview: () => context.pushNamed(
                    WriteReviewWidget.routeName,
                    pathParameters: {'bookingId': booking.id},
                    extra: <String, dynamic>{'serviceName': booking.title},
                  ),
                  onBookAgain: () => _bookAgain(context, booking),
                  onViewDetails: () => _openDetails(context, booking),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, BookingItem booking) async {
    final cancelled = await context.pushNamed<bool>(
      BookingDetailsWidget.routeName,
      extra: <String, dynamic>{'bookingId': booking.id},
    );
    if (cancelled == true) {
      _model.reloadBookings();
    }
  }

  void _showRescheduleComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rescheduling is coming soon.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _bookAgain(BuildContext context, BookingItem booking) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    context.pushNamed(
      BookingPaymentWidget.routeName,
      extra: <String, dynamic>{
        'serviceId': booking.serviceListingId,
        'serviceName': booking.title,
        'category': booking.serviceType,
        'price': booking.price.toStringAsFixed(0),
        'imageUrl': booking.imageUrl,
        'bookingDate': DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
        ).toIso8601String(),
        'bookingTime': '10:00 AM',
        'notes': null,
        'addressId': null,
        'address': null,
      },
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) {
      return '';
    }
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  Widget _bookingIconFallback(BuildContext context) => Container(
        width: 56,
        height: 56,
        color: AppTheme.of(context).surfaceAlt,
        child: Icon(
          Icons.home_repair_service_rounded,
          size: 24,
          color: AppTheme.of(context).secondaryText,
        ),
      );

  Widget _buildEmptyState(BuildContext context) {
    final theme = AppTheme.of(context);
    final (heading, description) = _model.emptyStateCopy(
      hasSearchQuery: _model.searchQuery.isNotEmpty,
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(AppThemeData.spaceLg),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
            border: Border.all(color: theme.border),
            boxShadow: AppThemeData.shadowSoft,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppThemeData.successTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _model.searchQuery.isNotEmpty
                      ? Icons.search_off_rounded
                      : switch (_model.selectedFilter) {
                          BookingsFilter.pending =>
                            Icons.timelapse_rounded,
                          BookingsFilter.completed =>
                            Icons.task_alt_rounded,
                          BookingsFilter.canceled =>
                            Icons.event_busy_rounded,
                          BookingsFilter.all => Icons.inbox_rounded,
                        },
                  color: AppThemeData.successTeal,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppThemeData.spaceLg),
              Text(
                heading,
                textAlign: TextAlign.center,
                style: theme.titleMedium.override(
                  font:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: AppThemeData.spaceSm),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(AppThemeData.radiusCard),
            boxShadow: AppThemeData.shadowSoft,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: theme.error),
              const SizedBox(height: 16),
              Text(
                _model.errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _model.reloadBookings(),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
