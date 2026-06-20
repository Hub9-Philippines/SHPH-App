import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        final service = await Supabase.instance.client
            .from('service_listings')
            .select()
            .eq('id', booking.serviceListingId)
            .maybeSingle();

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
      setState(() {
        _model.isLoading = false;
        _model.errorMessage = 'Failed to load booking: $e';
      });
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

  Color _getStatusColor(String? status) {
    if (status == null) {
      return AppTheme.of(context).secondaryText;
    }
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA726);
      case 'confirmed':
        return const Color(0xFF42A5F5);
      case 'in_progress':
        return const Color(0xFF66BB6A);
      case 'completed':
        return const Color(0xFF9E9E9E);
      case 'cancelled':
        return const Color(0xFFEF5350);
      default:
        return AppTheme.of(context).secondaryText;
    }
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
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Text(
              'Booking Details',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: _model.isLoading
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
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusHero(context),
                              const SizedBox(height: 18),
                              _buildServiceCard(context),
                              const SizedBox(height: 18),
                              _buildSectionCard(
                                context,
                                title: 'Booking information',
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
                                ],
                              ),
                              if (_model.booking!.notes != null &&
                                  _model.booking!.notes!.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                _buildSectionCard(
                                  context,
                                  title: 'Notes',
                                  children: [
                                    Text(
                                      _model.booking!.notes!,
                                      style: AppTheme.of(context).bodyMedium,
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
                                    height: 52,
                                    color: AppTheme.of(context).error,
                                    textStyle: AppTheme.of(context)
                                        .titleSmall
                                        .override(
                                          color: Colors.white,
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              if (_model.booking!.status == 'completed')
                                FFButtonWidget(
                                  onPressed: () {},
                                  text: 'Leave a Review',
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 52,
                                    color: AppTheme.of(context).primary,
                                    textStyle: AppTheme.of(context)
                                        .titleSmall
                                        .override(
                                          color: Colors.white,
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                            ],
                          ),
                        ),
        ),
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
              color: AppTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.of(context).alternate),
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
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).bodyMedium,
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
    final statusColor = _getStatusColor(_model.booking!.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatStatus(_model.booking!.status),
              style: AppTheme.of(context).bodySmall.override(
                    color: Colors.white,
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _model.serviceListing?['title'] ?? 'Unknown Service',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Booking reference ${_model.booking!.id.substring(0, 8).toUpperCase()}',
            style: AppTheme.of(context).bodyMedium.override(
                  color: AppTheme.of(context).secondaryText,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.of(context).alternate),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _model.serviceListing != null &&
                      _model.serviceListing!['thumbnail'] != null
                  ? Image.network(
                      _model.serviceListing!['thumbnail'],
                      width: 88,
                      height: 88,
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
                          color: AppTheme.of(context).secondaryText,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PHP ${(_model.booking!.totalPrice ?? 0).toStringAsFixed(2)}',
                    style: AppTheme.of(context).titleMedium.override(
                          color: AppTheme.of(context).primary,
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w700),
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
    required List<Widget> children,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.of(context).alternate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      );

  Widget _buildInfoRow(BuildContext context, String label, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            Text(
              value,
              style: AppTheme.of(context).bodyMedium,
            ),
          ],
        ),
      );

  Widget _imageFallback(BuildContext context) => Container(
        width: 88,
        height: 88,
        color: AppTheme.of(context).secondaryText,
        child: Icon(
          Icons.image_not_supported,
          color: AppTheme.of(context).primaryBackground,
        ),
      );

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
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
