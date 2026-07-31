import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/pages/booking_funnel/status_page.dart';
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
          backgroundColor: const Color(0xFFF4F7FB),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 74,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: custom_widgets.CupertinoSlidingWidgetBookings(
                          width: double.infinity,
                          height: double.infinity,
                          initialIndex: _model.selectedTabIndex ?? 0,
                          onChanged: (index) async {
                            _model.selectedTabIndex = index;
                            safeSetState(() {});
                            await _model.pageViewController?.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _model.errorMessage != null
                      ? _buildErrorState(context)
                      : _model.isLoading
                          ? ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 16, 20, 24),
                              itemCount: 3,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, __) =>
                                  const BookingCardSkeleton(),
                            )
                          : PageView(
                              controller: _model.pageViewController ??=
                                  PageController(
                                initialPage: max(
                                  0,
                                  min(
                                    valueOrDefault<int>(
                                      _model.selectedTabIndex,
                                      0,
                                    ),
                                    1,
                                  ),
                                ),
                              ),
                              onPageChanged: (_) async {
                                _model.selectedTabIndex =
                                    _model.pageViewCurrentIndex;
                                safeSetState(() {});
                              },
                              children: [
                                _buildBookingsTab(
                                  context,
                                  items: _model.inProgressList,
                                  icon: Icons.timelapse_rounded,
                                  title: 'No bookings in progress',
                                  subtitle:
                                      'New active bookings will appear here once a provider is on the way or currently working.',
                                ),
                                _buildBookingsTab(
                                  context,
                                  items: _model.completedList,
                                  icon: Icons.task_alt_rounded,
                                  title: 'No completed bookings',
                                  subtitle:
                                      'Finished bookings will show here with their final status and details.',
                                ),
                              ],
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
                        color: const Color(0xFF14213D),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track active work, completed visits, and next steps.',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: const Color(0xFF64748B),
                      ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: _model.reloadBookings,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.of(context).primary,
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      );

  Widget _buildBookingsTab(
    BuildContext context, {
    required List<BookingItem> items,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    if (items.isEmpty) {
      return _buildEmptyState(
        context,
        icon: icon,
        title: title,
        subtitle: subtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _model.reloadBookings(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildBookingCard(context, items[index]),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingItem booking) {
    final theme = AppTheme.of(context);
    final status = booking.status.toLowerCase();
    final shouldShowStatusButton = _isToday(booking.scheduledExecutionDate) &&
        !_isTerminalStatus(booking.status);
    final (statusColor, statusBgColor) = AppThemeData.statusColors(status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            color: Color(0x12000000),
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: booking.imageUrl.trim().isNotEmpty
                      ? Image.network(
                          booking.imageUrl,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _bookingImageFallback(context),
                        )
                      : _bookingImageFallback(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          booking.status,
                          style: theme.labelMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        booking.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.titleSmall.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: const Color(0xFF14213D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.serviceType,
                        style: theme.bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _BookingMetaRow(
                    label: 'Booking date',
                    value: booking.date,
                  ),
                  const SizedBox(height: 8),
                  _BookingMetaRow(
                    label: 'Total paid',
                    value: 'PHP ${booking.price.toStringAsFixed(0)}',
                    emphasized: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FFButtonWidget(
              onPressed: () async {
                final cancelled = await context.pushNamed<bool>(
                  BookingDetailsWidget.routeName,
                  extra: <String, dynamic>{'bookingId': booking.id},
                );
                if (cancelled == true) {
                  _model.reloadBookings();
                }
              },
              text: 'View Booking Details',
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              options: FFButtonOptions(
                width: double.infinity,
                height: 52,
                color: theme.primary.withValues(alpha: 0.10),
                textStyle: theme.titleSmall.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: theme.primary,
                ),
                elevation: 0,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            if (shouldShowStatusButton) ...[
              const SizedBox(height: 10),
              FFButtonWidget(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StatusPage(
                        bookingStatus: booking.status,
                        bookingDate:
                            booking.scheduledExecutionDate ?? DateTime.now(),
                        providerName: 'Assigned provider',
                        serviceTitle: booking.title,
                      ),
                    ),
                  );
                },
                text: 'View Status',
                icon: const Icon(Icons.track_changes_rounded, size: 18),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 52,
                  color: theme.primary,
                  textStyle: theme.titleSmall.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: Colors.white,
                  ),
                  elevation: 0,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime? date) {
    if (date == null) {
      return false;
    }
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTerminalStatus(String status) {
    final normalized = status.toLowerCase();
    return normalized == 'cancelled' ||
        normalized == 'completed' ||
        normalized == 'booking cancelled';
  }

  Widget _bookingImageFallback(BuildContext context) => Container(
        width: 76,
        height: 76,
        color: AppTheme.of(context).secondaryBackground,
        child: Icon(
          Icons.image_not_supported_rounded,
          color: AppTheme.of(context).secondaryText,
        ),
      );

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = AppTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: theme.primary, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: const Color(0xFF14213D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: const Color(0xFF64748B),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
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
              FFButtonWidget(
                onPressed: () => _model.reloadBookings(),
                text: 'Retry',
                options: FFButtonOptions(
                  width: 120,
                  height: 44,
                  color: theme.primary,
                  textStyle: theme.bodySmall.override(
                    color: Colors.white,
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingMetaRow extends StatelessWidget {
  const _BookingMetaRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: theme.bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            ),
            color: emphasized ? theme.primary : theme.primaryText,
          ),
        ),
      ],
    );
  }
}
