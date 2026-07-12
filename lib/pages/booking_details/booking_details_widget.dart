import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/shph_api.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/pages/booking_funnel/booking_models.dart';
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
  int? _sharedEtaMinutes;
  Timer? _etaTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BookingDetailsModel.new);
    _loadBookingDetails();
  }

  @override
  void dispose() {
    _etaTimer?.cancel();
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
        final serviceResult =
            await ShphServicesApi.instance.getListing(booking.serviceListingId);
        final service = serviceResult.toJson();

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
          const SnackBar(
            content: Text('Failed to cancel booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rescheduleBooking() async {
    final currentDate = _model.booking!.bookingDate;
    final currentTime = _model.booking!.bookingTime;

    final date = await showDatePicker(
      context: context,
      initialDate: currentDate.isAfter(DateTime.now()) ? currentDate : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(currentTime.split(':').first) ?? 9,
        minute: int.tryParse(currentTime.split(':').last) ?? 0,
      ),
    );
    if (time == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Booking'),
        content: Text(
          'Change booking to ${date.month}/${date.day} at ${formatTimeOfDay(time)}?',
        ),
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

    if (confirmed != true || !mounted) return;

    final success = await BookingsService.instance.rescheduleBooking(
      _model.booking!.id,
      newDate: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      newTime: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    );

    if (!mounted) return;

    if (success.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking rescheduled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadBookingDetails();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reschedule booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addTip() async {
    final controller = TextEditingController();
    final amount = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add a Tip'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter tip amount',
            prefixText: 'PHP ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Send Tip'),
          ),
        ],
      ),
    );
    if (amount == null || !mounted) return;
    final parsed = double.tryParse(amount);
    if (parsed == null || parsed <= 0) return;
    try {
      await ShphPaymentsApi.instance.tipBookingProvider(
        _model.booking!.id,
        amount: parsed,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tip sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send tip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadCompletionPhoto() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Completion Photo'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Paste photo URL or leave blank to skip',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (url == null || !mounted) return;
    try {
      if (url.isNotEmpty) {
        final httpClient = HttpClient();
        final request = await httpClient.getUrl(Uri.parse(url));
        final response = await request.close();
        final bytes = <int>[];
        await for (final chunk in response) {
          bytes.addAll(chunk);
        }
        await ShphBookingsApi.instance.completePhoto(
          _model.booking!.id,
          fileBytes: bytes,
          fileName:
              'completion_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }
      await BookingsService.instance.updateBookingStatus(
        _model.booking!.id,
        'completed',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking completed!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBookingDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _approvePartsCost() async {
    try {
      await ShphBookingsApi.instance.approvePartsCost(_model.booking!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parts cost approved'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBookingDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectPartsCost() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Parts Cost'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Reason for rejection...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    try {
      await ShphBookingsApi.instance.rejectPartsCost(
        _model.booking!.id,
        reason: reason.isNotEmpty ? reason : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parts cost rejected'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBookingDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareEta() async {
    final controller = TextEditingController();
    final minutes = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share ETA'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Estimated minutes until arrival',
            suffixText: 'min',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Share')),
        ],
      ),
    );
    if (minutes == null || minutes.isEmpty || !mounted) return;
    final parsed = int.tryParse(minutes);
    if (parsed == null || parsed < 0) return;
    try {
      await ShphBookingsApi.instance.shareEta(_model.booking!.id, minutes: parsed);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ETA shared with client'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share ETA: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _viewInvoice() async {
    if (_model.booking == null) return;
    try {
      final invoice = await ShphBookingsApi.instance.getInvoice(_model.booking!.id);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invoice'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow(ctx, 'Booking', _model.booking!.id.substring(0, 8)),
                _buildInfoRow(ctx, 'Amount', 'PHP ${(_model.booking!.totalPrice ?? 0).toStringAsFixed(2)}'),
                _buildInfoRow(ctx, 'Status', invoice['status']?.toString() ?? _model.booking!.paymentStatus ?? 'N/A'),
                if (invoice['invoice_number'] != null)
                  _buildInfoRow(ctx, 'Invoice #', invoice['invoice_number'].toString()),
                if (invoice['issued_at'] != null)
                  _buildInfoRow(ctx, 'Issued', invoice['issued_at'].toString()),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load invoice: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _getPaymentStatus() async {
    if (_model.booking == null) return;
    try {
      final payment = await ShphPaymentsApi.instance.getBookingPayment(_model.booking!.id);
      if (!mounted || payment.isEmpty) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Payment Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(ctx, 'Status', payment['status']?.toString() ?? 'N/A'),
              if (payment['amount'] != null)
                _buildInfoRow(ctx, 'Amount', 'PHP ${(payment['amount'] as num).toStringAsFixed(2)}'),
              if (payment['method'] != null)
                _buildInfoRow(ctx, 'Method', payment['method'].toString()),
              if (payment['paid_at'] != null)
                _buildInfoRow(ctx, 'Paid At', payment['paid_at'].toString()),
              if (payment['transaction_id'] != null)
                _buildInfoRow(ctx, 'Transaction ID', payment['transaction_id'].toString()),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load payment details: $e'), backgroundColor: Colors.red),
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

  Color _getStatusColor(String? status) {
    if (status == null) {
      return AppTheme.of(context).secondaryText;
    }
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'confirmed':
        return const Color(0xFF2563EB);
      case 'in_progress':
        return const Color(0xFF16A34A);
      case 'completed':
        return const Color(0xFF64748B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.of(context).secondaryText;
    }
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Payment status',
                                              style: AppTheme.of(context).bodyMedium.override(
                                                    font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                                    color: const Color(0xFF64748B),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: _getPaymentStatus,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _model.booking!.paymentStatus ?? 'Pending',
                                                    style: AppTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.poppins(),
                                                          color: _model.booking!.paymentStatus == 'paid' ? Colors.green : Colors.orange,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (_model.booking!.status != 'pending') ...[
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: _viewInvoice,
                                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                                    label: const Text('View Invoice'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    ),
                                  ),
                                ],
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
                                              font: GoogleFonts.poppins(),
                                              color: const Color(0xFF64748B),
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 24),
                                if (_model.booking!.status == 'pending' ||
                                    _model.booking!.status == 'confirmed') ...[
                                  FFButtonWidget(
                                    onPressed: _rescheduleBooking,
                                    text: 'Reschedule',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 54,
                                      color: AppTheme.of(context).primary,
                                      textStyle: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            color: Colors.white,
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
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
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ],
                                if (_model.booking!.status == 'completed')
                                  FFButtonWidget(
                                    onPressed: () async {
                                      final providerId = _model.serviceListing?['provider_id'] as int?;
                                      await context.pushNamed(
                                        LeaveReviewWidget.routeName,
                                        extra: {
                                          'bookingId': _model.booking!.id,
                                          'providerId': providerId ?? 0,
                                        },
                                      );
                                      _loadBookingDetails();
                                    },
                                    text: 'Leave a Review',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 54,
                                      color: AppTheme.of(context).primary,
                                      textStyle: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            color: Colors.white,
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                if (_model.booking!.status == 'completed') ...[
                                  const SizedBox(height: 12),
                                  FFButtonWidget(
                                    onPressed: _addTip,
                                    text: 'Add a Tip',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 54,
                                      color: const Color(0xFFF59E0B),
                                      textStyle: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            color: Colors.white,
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ],
                                if (_model.booking!.status == 'in_progress') ...[
                                  const SizedBox(height: 12),
                                  FFButtonWidget(
                                    onPressed: _uploadCompletionPhoto,
                                    text: 'Mark Complete with Photo',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 54,
                                      color: const Color(0xFF16A34A),
                                      textStyle: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            color: Colors.white,
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ],
                                if (_model.booking!.status == 'confirmed' ||
                                    _model.booking!.status == 'in_progress') ...[
                                  _buildPartsCostSection(context),
                                  const SizedBox(height: 12),
                                  FFButtonWidget(
                                    onPressed: _shareEta,
                                    text: 'Share ETA',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 54,
                                      color: const Color(0xFF3B82F6),
                                      textStyle: AppTheme.of(context).titleSmall.override(
                                        color: Colors.white,
                                        font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
          ),
        ),
      );

  Widget _buildTopBar(BuildContext context) => Row(
        children: [
          Material(
            color: Colors.white,
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
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                        color: const Color(0xFF14213D),
                      ),
                ),
                Text(
                  'Review progress, schedule, and payment state.',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.poppins(),
                        color: const Color(0xFF64748B),
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
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(),
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
                          font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _model.serviceListing?['title'] ?? 'Unknown Service',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
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
                          font: GoogleFonts.poppins(),
                          color: const Color(0xFF64748B),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PHP ${(_model.booking!.totalPrice ?? 0).toStringAsFixed(2)}',
                    style: AppTheme.of(context).titleMedium.override(
                          color: AppTheme.of(context).primary,
                          font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: const Color(0xFF14213D),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.poppins(),
                    color: const Color(0xFF64748B),
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
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      color: const Color(0xFF64748B),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(),
                    ),
              ),
            ),
          ],
        ),
      );

  Widget _buildPartsCostSection(BuildContext context) {
    final partsCost = _model.serviceListing?['parts_cost'];
    final partsStatus = _model.serviceListing?['parts_status'];
    if (partsCost == null || partsStatus != 'pending') {
      return const SizedBox.shrink();
    }
    final amount = (partsCost as num).toDouble();
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: _buildSectionCard(
        context,
        title: 'Parts Cost Approval',
        subtitle: 'The provider has submitted a parts cost for this job.',
        children: [
          _buildInfoRow(
            context,
            'Parts Cost',
            'PHP ${amount.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FFButtonWidget(
                  onPressed: _approvePartsCost,
                  text: 'Approve',
                  options: FFButtonOptions(
                    height: 48,
                    color: const Color(0xFF16A34A),
                    textStyle: AppTheme.of(context).bodySmall.override(
                      color: Colors.white,
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FFButtonWidget(
                  onPressed: _rejectPartsCost,
                  text: 'Reject',
                  options: FFButtonOptions(
                    height: 48,
                    color: AppTheme.of(context).error,
                    textStyle: AppTheme.of(context).bodySmall.override(
                      color: Colors.white,
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
