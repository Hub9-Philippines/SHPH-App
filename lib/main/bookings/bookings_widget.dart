import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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

  Widget _buildBookingCard(BuildContext context, BookingItem booking) {
    final theme = AppTheme.of(context);
    final status = booking.status.toLowerCase();
    final statusColor = switch (status) {
      'completed' => const Color(0xFF7B8794),
      'in progress' => theme.success,
      _ => const Color(0xFFFFA726),
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.8)),
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    booking.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: theme.secondaryBackground,
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
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
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          booking.status,
                          style: theme.labelMedium.override(
                            font: GoogleFonts.poppins(
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
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.serviceType,
                        style: theme.bodySmall.override(
                          font: GoogleFonts.poppins(),
                          color: theme.secondaryText,
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
                color: theme.secondaryBackground,
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
              onPressed: () {
                context.pushNamed(
                  'BookingDetails',
                  extra: <String, dynamic>{
                    'bookingId': booking.id,
                  },
                );
              },
              text: 'View Booking Details',
              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
              ),
              options: FFButtonOptions(
                width: double.infinity,
                height: 52,
                color: theme.primary.withValues(alpha: 0.10),
                textStyle: theme.titleSmall.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                  ),
                  color: theme.primary,
                ),
                elevation: 0,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: theme.primary, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.titleMedium.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
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
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _model.errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: theme.bodyMedium,
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
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
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

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bookings',
                                  style: AppTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        color: const Color(0xFF16202A),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track active work and completed visits',
                                  style: AppTheme.of(context)
                                      .bodySmall
                                      .override(
                                        font: GoogleFonts.poppins(),
                                        color:
                                            AppTheme.of(context).secondaryText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              color: AppTheme.of(context).primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildBookingsHeader(context),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x10000000),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: custom_widgets.CupertinoSlidingWidgetBookings(
                          width: double.infinity,
                          height: double.infinity,
                          initialIndex: _model.selectedTabIndex!,
                          onChanged: (index) async {
                            _model.selectedTabIndex = index;
                            safeSetState(() {});
                            await _model.pageViewController?.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease,
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
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                16,
                                20,
                                24,
                              ),
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
                                        _model.selectedTabIndex, 0),
                                    1,
                                  ),
                                ),
                              ),
                              onPageChanged: (_) async {
                                safeSetState(() {});
                                _model.selectedTabIndex =
                                    _model.pageViewCurrentIndex;
                                safeSetState(() {});
                              },
                              children: [
                                if (_model.inProgressList.isEmpty)
                                  _buildEmptyState(
                                    context,
                                    icon: Icons.timelapse_rounded,
                                    title: 'No bookings in progress',
                                    subtitle:
                                        'New active bookings will appear here once a provider is on the way or currently working.',
                                  )
                                else
                                  ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      16,
                                      20,
                                      24,
                                    ),
                                    itemCount: _model.inProgressList.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) =>
                                        _buildBookingCard(
                                      context,
                                      _model.inProgressList[index],
                                    ),
                                  ),
                                if (_model.completedList.isEmpty)
                                  _buildEmptyState(
                                    context,
                                    icon: Icons.task_alt_rounded,
                                    title: 'No completed bookings',
                                    subtitle:
                                        'Finished bookings will show here with their final status and details.',
                                  )
                                else
                                  ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      16,
                                      20,
                                      24,
                                    ),
                                    itemCount: _model.completedList.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) =>
                                        _buildBookingCard(
                                      context,
                                      _model.completedList[index],
                                    ),
                                  ),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildBookingsHeader(BuildContext context) {
    final total = _model.inProgressList.length + _model.completedList.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F8A6C),
            Color(0xFF17B890),
            Color(0xFF73D8B4),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HeaderMetric(
              label: 'Active',
              value: '${_model.inProgressList.length}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _HeaderMetric(
              label: 'Completed',
              value: '${_model.completedList.length}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _HeaderMetric(
              label: 'Total',
              value: '$total',
            ),
          ),
        ],
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
            font: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
            color: theme.secondaryText,
          ),
        ),
        Text(
          value,
          style: theme.bodyMedium.override(
            font: GoogleFonts.poppins(
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            ),
            color: emphasized ? theme.primary : theme.primaryText,
          ),
        ),
      ],
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ),
      );
}
