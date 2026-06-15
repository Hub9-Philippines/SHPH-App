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
        // Fetch service listing details
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
          backgroundColor: AppTheme.of(context).primaryBackground,
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
          ),
          body: _model.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _model.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppTheme.of(context).error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _model.errorMessage!,
                              textAlign: TextAlign.center,
                              style: AppTheme.of(context).bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            FFButtonWidget(
                              onPressed: _loadBookingDetails,
                              text: 'Retry',
                              options: FFButtonOptions(
                                width: 120,
                                height: 40,
                                color: AppTheme.of(context).primary,
                                textStyle: AppTheme.of(context)
                                    .bodySmall
                                    .override(
                                      color: AppTheme.of(context).primaryText,
                                    ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _model.booking == null
                      ? const Center(child: Text('No booking data'))
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status Banner
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_model.booking!.status)
                                      .withValues(alpha: 0.1),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _getStatusColor(
                                          _model.booking!.status),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                            _model.booking!.status),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _formatStatus(_model.booking!.status),
                                        style: AppTheme.of(context)
                                            .bodySmall
                                            .override(
                                              color: Colors.white,
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Service Details
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.of(context).alternate,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: _model.serviceListing != null &&
                                                _model.serviceListing![
                                                        'thumbnail'] !=
                                                    null
                                            ? Image.network(
                                                _model.serviceListing![
                                                    'thumbnail'],
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: AppTheme.of(context)
                                                      .secondaryText,
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color: AppTheme.of(context)
                                                        .primaryBackground,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                width: 80,
                                                height: 80,
                                                color: AppTheme.of(context)
                                                    .secondaryText,
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: AppTheme.of(context)
                                                      .primaryBackground,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _model.serviceListing?['title'] ??
                                                  'Unknown Service',
                                              style: AppTheme.of(context)
                                                  .titleMedium
                                                  .override(
                                                    font: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _model.serviceListing?[
                                                      'category_name'] ??
                                                  'Service',
                                              style: AppTheme.of(context)
                                                  .bodySmall
                                                  .override(
                                                    color: AppTheme.of(context)
                                                        .secondaryText,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₱${(_model.booking!.totalPrice ?? 0).toStringAsFixed(2)}',
                                              style: AppTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    color: AppTheme.of(context)
                                                        .primary,
                                                    font: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Booking Information
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Booking Information',
                                  style:
                                      AppTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold),
                                          ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Booking ID',
                                _model.booking!.id.substring(0, 8),
                              ),
                              _buildInfoRow(
                                'Date',
                                '${_model.booking!.bookingDate.day}/${_model.booking!.bookingDate.month}/${_model.booking!.bookingDate.year}',
                              ),
                              _buildInfoRow(
                                'Time',
                                _model.booking!.bookingTime,
                              ),
                              if (_model.booking!.notes != null &&
                                  _model.booking!.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Text(
                                        'Notes',
                                        style: AppTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color:
                                                AppTheme.of(context).alternate,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          _model.booking!.notes!,
                                          style:
                                              AppTheme.of(context).bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 24),
                              // Action Buttons
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    if (_model.booking!.status == 'pending' ||
                                        _model.booking!.status == 'confirmed')
                                      FFButtonWidget(
                                        onPressed: () {
                                          _cancelBooking();
                                        },
                                        text: 'Cancel Booking',
                                        options: FFButtonOptions(
                                          width: double.infinity,
                                          height: 50,
                                          color: AppTheme.of(context).error,
                                          textStyle: AppTheme.of(context)
                                              .titleSmall
                                              .override(
                                                color: Colors.white,
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    if (_model.booking!.status == 'completed')
                                      FFButtonWidget(
                                        onPressed: () {
                                          // TODO: Navigate to review page
                                        },
                                        text: 'Leave a Review',
                                        options: FFButtonOptions(
                                          width: double.infinity,
                                          height: 50,
                                          color: AppTheme.of(context).primary,
                                          textStyle: AppTheme.of(context)
                                              .titleSmall
                                              .override(
                                                color: AppTheme.of(context)
                                                    .primaryText,
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).width * 0.1),
                            ],
                          ),
                        ),
        ),
      );

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
            ),
            Text(
              value,
              style: AppTheme.of(context).bodyMedium,
            ),
          ],
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
