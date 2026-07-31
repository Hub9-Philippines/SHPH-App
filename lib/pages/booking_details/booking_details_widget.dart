import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/resources/services_api.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/bookings_service.dart';
import '/theme/app_theme.dart';
import 'booking_details_model.dart';

export 'booking_details_model.dart';

class BookingDetailsWidget extends StatefulWidget {
  const BookingDetailsWidget({
    super.key,
    this.bookingId,
  });

  final String? bookingId;

  static String routeName = 'BookingDetails';
  static String routePath = '/booking-details';

  @override
  State<BookingDetailsWidget> createState() => _BookingDetailsWidgetState();
}

class _BookingDetailsWidgetState extends State<BookingDetailsWidget> {
  late BookingDetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BookingDetailsModel.new);
    _loadBookingDetails();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadBookingDetails() async {
    if (widget.bookingId == null) {
      setState(() => _model.errorMessage = 'Booking ID is required');
      return;
    }

    setState(() {
      _model.isLoading = true;
      _model.errorMessage = null;
    });

    try {
      final booking =
          await BookingsService.instance.getBookingById(widget.bookingId!);

      if (booking != null) {
        Map<String, dynamic>? service;
        final listingId = booking.serviceListingId;
        if (listingId != null) {
          final parsedId = int.tryParse(listingId.toString());
          if (parsedId != null) {
            try {
              final listing =
                  await ShphServicesApi.instance.getListing(parsedId);
              service = {
                'id': listing.id,
                'title': listing.title,
                'description': listing.description,
                'base_price': listing.basePrice,
                'category_name': listing.categoryName,
                'thumbnail': listing.thumbnail,
              };
            } catch (_) {}
          }
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _model.booking = booking;
          _model.serviceListing = service;
          _model.isLoading = false;
        });
      } else {
        setState(() {
          _model.isLoading = false;
          _model.errorMessage = 'Booking not found';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _model.isLoading = false;
          _model.errorMessage = 'Failed to load booking: $e';
        });
      }
    }
  }

  Future<void> _cancelBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true && _model.booking != null) {
      final success =
          await BookingsService.instance.cancelBooking(_model.booking!.id);
      if (!mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to cancel booking'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }

  String _formatStatus(String? status) {
    if (status == null) {
      return 'Unknown';
    }
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  (Color, Color) _getStatusColors(String? status) {
    if (status == null) {
      return (AppTheme.of(context).secondaryText, AppTheme.of(context).primaryBackground);
    }
    return AppThemeData.statusColors(status.toLowerCase());
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
            child: _model.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.of(context).primary,
                    ),
                  )
                : _model.errorMessage != null
                    ? _buildMessageState(
                        context,
                        icon: Icons.error_outline_rounded,
                        title: 'Could not load booking',
                        subtitle: _model.errorMessage!,
                        actionLabel: 'Retry',
                        onPressed: _loadBookingDetails,
                        iconColor: AppTheme.of(context).error,
                      )
                    : _model.booking == null
                        ? _buildMessageState(
                            context,
                            icon: Icons.inventory_2_outlined,
                            title: 'No booking data',
                            subtitle:
                                'This booking could not be found or is no longer available.',
                            actionLabel: 'Go back',
                            onPressed: () => Navigator.of(context).maybePop(),
                            iconColor: AppTheme.of(context).secondaryText,
                          )
                        : RefreshIndicator(
                            color: AppTheme.of(context).primary,
                            onRefresh: _loadBookingDetails,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                              children: [
                                _buildTopBar(context),
                                const SizedBox(height: 18),
                                _buildStatusHero(context),
                                const SizedBox(height: 18),
                                _buildServiceCard(context),
                                const SizedBox(height: 18),
                                _buildSectionCard(
                                  context,
                                  title: 'Booking information',
                                  subtitle:
                                      'Core scheduling, payment, and status details.',
                                  children: [
                                    _buildInfoRow(
                                      context,
                                      'Booking ID',
                                      _model.booking!.id.substring(0, 8),
                                    ),
                                    _buildInfoRow(
                                      context,
                                      'Date',
                                      '${_model.booking!.bookingDate.day}/${_model.booking!.bookingDate.month}/${_model.booking!.bookingDate.year}',
                                    ),
                                    _buildInfoRow(
                                      context,
                                      'Time',
                                      _model.booking!.bookingTime,
                                    ),
                                    _buildInfoRow(
                                      context,
                                      'Status',
                                      _formatStatus(_model.booking!.status),
                                    ),
                                    _buildInfoRow(
                                      context,
                                      'Payment status',
                                      _model.booking!.paymentStatus ?? 'Pending',
                                    ),
                                  ],
                                ),
                                if (_model.booking!.notes != null &&
                                    _model.booking!.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 18),
                                  _buildSectionCard(
                                    context,
                                    title: 'Notes',
                                    subtitle:
                                        'Special instructions attached to this booking.',
                                    children: [
                                      Text(
                                        _model.booking!.notes!,
                                        style: AppTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(),
                                              color: AppTheme.of(context).secondaryText,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 24),
                                if (_model.booking!.status == 'pending' ||
                                    _model.booking!.status == 'confirmed')
                                  FFButtonWidget(
                                    onPressed: _cancelBooking,
                                    text: 'Cancel Booking',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 54,
                                      color: AppTheme.of(context).error,
                                      textStyle: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            color: Colors.white,
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                if (_model.booking!.status == 'completed')
                                  FFButtonWidget(
                                    onPressed: () {},
                                    text: 'Leave a Review',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 54,
                                      color: AppTheme.of(context).primary,
                                      textStyle: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            color: Colors.white,
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                              ],
                            ),
                          ),
          ),
        ),
      );

  Widget _buildTopBar(BuildContext context) => Row(
        children: [
          Material(
            color: AppTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(18),
            child: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Details',
                  style: AppTheme.of(context).titleLarge.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: AppTheme.of(context).primaryText,
                      ),
                ),
                Text(
                  'Review progress, schedule, and payment state.',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onPressed,
    required Color iconColor,
  }) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppThemeData.shadowCard,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: iconColor),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
                      ),
                ),
                const SizedBox(height: 16),
                FFButtonWidget(
                  onPressed: onPressed,
                  text: actionLabel,
                  options: FFButtonOptions(
                    width: 140,
                    height: 44,
                    color: AppTheme.of(context).primary,
                    textStyle: AppTheme.of(context).bodySmall.override(
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

  Widget _buildStatusHero(BuildContext context) {
    final (statusColor, _) = _getStatusColors(_model.booking!.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.94),
            statusColor.withValues(alpha: 0.76),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatStatus(_model.booking!.status),
              style: AppTheme.of(context).bodySmall.override(
                    color: Colors.white,
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _model.serviceListing?['title'] ?? 'Unknown Service',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Booking reference ${_model.booking!.id.substring(0, 8).toUpperCase()}',
            style: AppTheme.of(context).bodyMedium.override(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(26),
          boxShadow: AppThemeData.shadowCard,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _model.serviceListing != null &&
                      _model.serviceListing!['thumbnail'] != null
                  ? Image.network(
                      _model.serviceListing!['thumbnail'],
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(context),
                    )
                  : _imageFallback(context),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _model.serviceListing?['category_name'] ?? 'Service',
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: AppTheme.of(context).secondaryText,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PHP ${(_model.booking!.totalPrice ?? 0).toStringAsFixed(2)}',
                    style: AppTheme.of(context).titleMedium.override(
                          color: AppTheme.of(context).primary,
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(26),
          boxShadow: AppThemeData.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: AppTheme.of(context).primaryText,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );

  Widget _buildInfoRow(BuildContext context, String label, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(),
                    ),
              ),
            ),
          ],
        ),
      );

  Widget _imageFallback(BuildContext context) => Container(
        width: 92,
        height: 92,
        color: const Color(0xFFE7ECF1),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.of(context).secondaryText,
        ),
      );
}
