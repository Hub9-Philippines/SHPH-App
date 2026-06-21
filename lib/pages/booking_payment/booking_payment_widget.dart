import 'package:flutter/material.dart';
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
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F7FA),
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Text(
              'Select Payment',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: const Color(0xFF16202A),
                  ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
            children: [
              _buildServiceHero(context),
              const SizedBox(height: 18),
              _buildEscrowNotice(context),
              const SizedBox(height: 18),
              Text(
                'Choose how you want to pay',
                style: AppTheme.of(context).titleMedium.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      color: const Color(0xFF16202A),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Card, wallet, and QR payments are protected through escrow until the job is completed.',
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.poppins(),
                      color: const Color(0xFF6F7B86),
                    ),
              ),
              const SizedBox(height: 16),
              _buildPaymentOption(
                value: 'card',
                icon: Icons.credit_card_rounded,
                label: 'Credit / Debit Card',
                sublabel: 'Visa, Mastercard',
                tint: const Color(0xFF1B74E4),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                value: 'ewallet',
                icon: Icons.account_balance_wallet_rounded,
                label: 'E-Wallets',
                sublabel: 'GCash, Maya',
                tint: const Color(0xFF0F8A6C),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                value: 'qr',
                icon: Icons.qr_code_rounded,
                label: 'QR Ph Code',
                sublabel: 'Standard Philippine digital QR',
                tint: const Color(0xFF7C5CFC),
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                value: 'cash',
                icon: Icons.payments_rounded,
                label: 'Cash on Completion',
                sublabel: 'Pay the pro directly after the job',
                tint: const Color(0xFFEF6C57),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 20,
                  offset: Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total',
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.poppins(),
                                    color: const Color(0xFF6F7B86),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.price ?? 'PHP 0',
                              style: AppTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: AppTheme.of(context).primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: _model.isLoading ? null : _confirmPayment,
                          text: _model.isLoading
                              ? 'Processing...'
                              : 'Confirm Payment',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 54,
                            color: _model.isLoading
                                ? AppTheme.of(context).alternate
                                : AppTheme.of(context).primary,
                            textStyle: AppTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: Colors.white,
                                ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_model.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _model.errorMessage!,
                      style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).error,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildServiceHero(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF17212B),
              Color(0xFF23384D),
              Color(0xFF2F5368),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: widget.imageUrl != null
                  ? Image.network(
                      widget.imageUrl!,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _paymentImageFallback(context),
                    )
                  : _paymentImageFallback(context),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.serviceName ?? 'Service',
                    style: AppTheme.of(context).titleLarge.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.category ?? 'Service',
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.poppins(),
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.bookingDate != null
                        ? '${DateTime.parse(widget.bookingDate!).day}/${DateTime.parse(widget.bookingDate!).month}/${DateTime.parse(widget.bookingDate!).year} at ${widget.bookingTime}'
                        : 'Date & Time',
                    style: AppTheme.of(context).labelLarge.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildEscrowNotice(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4FF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFC9E1FF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1B74E4).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Color(0xFF1B74E4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Card, e-wallet, and QR payments are held in escrow. The provider receives the funds only after you confirm the work is done from your bookings page.',
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      color: const Color(0xFF17426E),
                    ),
              ),
            ),
          ],
        ),
      );

  Widget _buildPaymentOption({
    required String value,
    required IconData? icon,
    required String label,
    required String sublabel,
    required Color tint,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? tint.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? tint : const Color(0xFFE5E9EE),
              width: isSelected ? 1.6 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: tint,
                    size: 22,
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
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                            color: const Color(0xFF16202A),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sublabel,
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(),
                            color: const Color(0xFF6F7B86),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? tint : const Color(0xFF9AA6B2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentImageFallback(BuildContext context) => Container(
        width: 88,
        height: 88,
        color: Colors.white.withValues(alpha: 0.14),
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white,
        ),
      );
}
