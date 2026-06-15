import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/bookings_service.dart';
import '/theme/app_theme.dart';
import 'booking_payment_model.dart';

export 'booking_payment_model.dart';

class BookingPaymentWidget extends StatefulWidget {
  const BookingPaymentWidget({
    super.key,
    this.serviceId,
    this.serviceName,
    this.category,
    this.price,
    this.imageUrl,
    this.bookingDate,
    this.bookingTime,
    this.notes,
  });

  final int? serviceId;
  final String? serviceName;
  final String? category;
  final String? price;
  final String? imageUrl;
  final String? bookingDate;
  final String? bookingTime;
  final String? notes;

  static String routeName = 'BookingPayment';
  static String routePath = '/booking-payment';

  @override
  State<BookingPaymentWidget> createState() => _BookingPaymentWidgetState();
}

class _BookingPaymentWidgetState extends State<BookingPaymentWidget> {
  late BookingPaymentModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BookingPaymentModel.new);
  }

  Future<void> _confirmPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _model.isLoading = true);

    try {
      // Determine payment status based on selection
      final paymentStatus = _selectedPaymentMethod == 'cash'
          ? 'pay_on_completion'
          : 'authorized_escrow';

      final booking = await BookingsService.instance.createBooking(
        serviceListingId: widget.serviceId!,
        bookingDate: DateTime.parse(widget.bookingDate!),
        bookingTime: widget.bookingTime!,
        notes: widget.notes,
        totalPrice: _parsePrice(widget.price),
        paymentStatus: paymentStatus,
      );

      if (booking != null && mounted) {
        // Clear navigation stack and go to success screen
        context.go('/booking-success');
      } else if (mounted) {
        setState(() {
          _model.isLoading = false;
          _model.errorMessage = 'Failed to create booking. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _model.isLoading = false;
          _model.errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  double? _parsePrice(String? price) {
    if (price == null) {
      return null;
    }
    final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanPrice);
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
              'Select Payment',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Summary
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).secondaryBackground,
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
                          child: widget.imageUrl != null
                              ? Image.network(
                                  widget.imageUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 80,
                                    height: 80,
                                    color: AppTheme.of(context).secondaryText,
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
                                  color: AppTheme.of(context).secondaryText,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color:
                                        AppTheme.of(context).primaryBackground,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.serviceName ?? 'Service',
                                style:
                                    AppTheme.of(context).titleMedium.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.bookingDate != null
                                    ? '${DateTime.parse(widget.bookingDate!).day}/${DateTime.parse(widget.bookingDate!).month}/${DateTime.parse(widget.bookingDate!).year} at ${widget.bookingTime}'
                                    : 'Date & Time',
                                style: AppTheme.of(context).bodySmall.override(
                                      color: AppTheme.of(context).secondaryText,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.price ?? '₱0',
                                style: AppTheme.of(context).bodyMedium.override(
                                      color: AppTheme.of(context).primary,
                                      font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
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
                // Escrow Notice
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2196F3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF1976D2),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Important: For card and e-wallet transactions, your payment is held securely in escrow. The service provider will not receive the funds until you explicitly confirm the job is finished via the Bookings page.',
                            style: AppTheme.of(context).bodySmall.override(
                                  color: const Color(0xFF0D47A1),
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Payment Methods
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Method',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Credit/Debit Card
                      _buildPaymentOption(
                        value: 'card',
                        icon: FontAwesomeIcons.creditCard,
                        label: 'Credit / Debit Card',
                        sublabel: 'Visa, Mastercard',
                      ),
                      const SizedBox(height: 12),
                      // E-Wallets
                      _buildPaymentOption(
                        value: 'ewallet',
                        icon: FontAwesomeIcons.wallet,
                        label: 'E-Wallets',
                        sublabel: 'GCash, Maya',
                      ),
                      const SizedBox(height: 12),
                      // QR Ph
                      _buildPaymentOption(
                        value: 'qr',
                        icon: FontAwesomeIcons.qrcode,
                        label: 'QR Ph Code',
                        sublabel: 'Standard Philippine digital QR',
                      ),
                      const SizedBox(height: 12),
                      // Cash on Completion
                      _buildPaymentOption(
                        value: 'cash',
                        icon: FontAwesomeIcons.moneyBill,
                        label: 'Cash on Completion',
                        sublabel: 'Pay the pro directly after the job',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).width * 0.1),
              ],
            ),
          ),
          // Bottom Action Bar
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_model.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _model.errorMessage!,
                        style: AppTheme.of(context).bodySmall.override(
                              color: AppTheme.of(context).error,
                            ),
                      ),
                    ),
                  FFButtonWidget(
                    onPressed: _model.isLoading ? null : _confirmPayment,
                    text:
                        _model.isLoading ? 'Processing...' : 'Confirm Payment',
                    options: FFButtonOptions(
                      width: double.infinity,
                      color: _model.isLoading
                          ? AppTheme.of(context).alternate
                          : AppTheme.of(context).primary,
                      textStyle: AppTheme.of(context).titleMedium.override(
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                            color: AppTheme.of(context).primaryText,
                          ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildPaymentOption({
    required String value,
    required dynamic icon,
    required String label,
    required String sublabel,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).primary.withValues(alpha: 0.1)
              : AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.of(context).primary
                : AppTheme.of(context).alternate,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: AppTheme.of(context).primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.of(context).bodyMedium.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sublabel,
                    style: AppTheme.of(context).bodySmall.override(
                          color: AppTheme.of(context).secondaryText,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.of(context).primary
                      : AppTheme.of(context).alternate,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.of(context).primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
