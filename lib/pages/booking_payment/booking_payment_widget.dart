import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/shph_api.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/bookings_service.dart';
import '/services/payment_controller.dart';
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
  final _voucherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BookingPaymentModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    _voucherController.dispose();
    super.dispose();
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
      final price = _parsePrice(widget.price);
      final amountInCents = price != null ? (price * 100).round() : 0;

      if (_selectedPaymentMethod == 'wallet') {
        final walletData = await BookingsService.instance.getWallet();
        final balance = (walletData['balance'] as num?)?.toDouble() ?? 0.0;

        if (price != null && balance < price) {
          if (mounted) {
            setState(() {
              _model.isLoading = false;
              _model.errorMessage =
                  'Insufficient wallet balance (PHP ${balance.toStringAsFixed(2)}). '
                  'Please top up or choose another method.';
            });
          }
          return;
        }

        final booking = await BookingsService.instance.createBooking(
          serviceListingId: widget.serviceId!,
          bookingDate: DateTime.parse(widget.bookingDate!),
          bookingTime: widget.bookingTime!,
          notes: widget.notes,
          totalPrice: price,
          paymentStatus: 'wallet',
        );

        if (!mounted) return;

        if (booking == null) {
          setState(() {
            _model.isLoading = false;
            _model.errorMessage = 'Failed to create booking. Please try again.';
          });
          return;
        }

        final paid = await BookingsService.instance.payWithWallet(booking.id);
        if (!mounted) return;

        if (paid) {
          context.go('/booking-success');
        } else {
          setState(() {
            _model.isLoading = false;
            _model.errorMessage = 'Wallet payment failed. Please try again.';
          });
        }
        return;
      }

      if (_selectedPaymentMethod == 'card') {
        final intent = await BookingsService.instance.createPaymentIntent(
          amount: amountInCents,
          currency: 'PHP',
        );

        final clientSecret = intent['client_secret'] as String?;
        if (clientSecret == null) {
          if (mounted) {
            setState(() {
              _model.isLoading = false;
              _model.errorMessage = 'Failed to initialize payment.';
            });
          }
          return;
        }

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'SerbisyoHub',
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        final paymentIntentId = clientSecret.split('_secret_').first;

        await BookingsService.instance.confirmPayment(
          paymentIntentId: paymentIntentId,
          paymentDetails: {},
        );

        final booking = await BookingsService.instance.createBooking(
          serviceListingId: widget.serviceId!,
          bookingDate: DateTime.parse(widget.bookingDate!),
          bookingTime: widget.bookingTime!,
          notes: widget.notes,
          totalPrice: price,
          paymentStatus: 'authorized_escrow',
        );

        if (!mounted) return;

        if (booking != null) {
          context.go('/booking-success');
        } else {
          setState(() {
            _model.isLoading = false;
            _model.errorMessage = 'Booking created but confirmation pending.';
          });
        }
        return;
      }

      final paymentStatus = _selectedPaymentMethod == 'cash'
          ? 'pay_on_completion'
          : 'authorized_escrow';

      final booking = await BookingsService.instance.createBooking(
        serviceListingId: widget.serviceId!,
        bookingDate: DateTime.parse(widget.bookingDate!),
        bookingTime: widget.bookingTime!,
        notes: widget.notes,
        totalPrice: price,
        paymentStatus: paymentStatus,
      );

      if (!mounted) return;

      if (booking != null) {
        context.go('/booking-success');
      } else {
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF4F7FB),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
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
                                'Select Payment',
                                style: AppTheme.of(context).titleLarge.override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: const Color(0xFF14213D),
                                    ),
                              ),
                              Text(
                                'Review the booking and choose how you want to pay.',
                                style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.poppins(),
                                      color: const Color(0xFF64748B),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceHero(context),
                      const SizedBox(height: 18),
                      _buildScheduleSummary(),
                      const SizedBox(height: 18),
                      _buildEscrowNotice(context),
                      const SizedBox(height: 18),
                      Text(
                        'Choose how you want to pay',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFF14213D),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Card, wallet, and QR payments are protected through escrow until the job is completed.',
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.poppins(),
                              color: const Color(0xFF64748B),
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _voucherController,
                        decoration: InputDecoration(
                          hintText: 'Enter promo code',
                          prefixIcon: const Icon(Icons.discount_rounded),
                          suffixIcon: TextButton(
                            onPressed: () async {
                              final code = _voucherController.text.trim();
                              if (code.isEmpty) return;
                              try {
                                final result = await ShphPaymentsApi
                                    .instance
                                    .validateVoucher(code);
                                if (!mounted) return;
                                final valid = result['valid'] == true;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      valid
                                          ? 'Promo applied! ${(result['discount'] as num?)?.toStringAsFixed(0) ?? ''} off'
                                          : (result['error'] as String?) ??
                                              'Invalid promo code',
                                    ),
                                    backgroundColor:
                                        valid ? Color(0xFF059669) : null,
                                  ),
                                );
                              } catch (_) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Error validating promo'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Apply'),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
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
                        value: 'wallet',
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'SHPH Wallet',
                        sublabel: 'Pay with your wallet balance',
                        tint: const Color(0xFF2563EB),
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
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(),
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
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A17212B),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: widget.imageUrl != null
                  ? Image.network(
                      widget.imageUrl!,
                      width: 92,
                      height: 92,
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.category ?? 'Service',
                      style: AppTheme.of(context).labelMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.serviceName ?? 'Service',
                    style: AppTheme.of(context).titleLarge.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.price ?? 'PHP 0',
                    style: AppTheme.of(context).headlineSmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                          ),
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildScheduleSummary() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking summary',
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: const Color(0xFF14213D),
                  ),
            ),
            const SizedBox(height: 14),
            _summaryRow(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value: _formattedBookingDate,
            ),
            const SizedBox(height: 12),
            _summaryRow(
              icon: Icons.access_time_rounded,
              label: 'Time',
              value: widget.bookingTime ?? 'Not set',
            ),
            if ((widget.notes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _summaryRow(
                icon: Icons.sticky_note_2_outlined,
                label: 'Notes',
                value: widget.notes!.trim(),
              ),
            ],
          ],
        ),
      );

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF334155)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.poppins(),
                        color: const Color(0xFF64748B),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                        ),
                        color: const Color(0xFF14213D),
                      ),
                ),
              ],
            ),
          ),
        ],
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
            _model.errorMessage = null;
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: tint),
              ),
              const SizedBox(width: 14),
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
                            color: const Color(0xFF14213D),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sublabel,
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.poppins(),
                            color: const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? tint : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: tint,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentImageFallback(BuildContext context) => Container(
        width: 92,
        height: 92,
        color: Colors.white.withValues(alpha: 0.16),
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white,
          size: 34,
        ),
      );

  Widget _buildBottomBar() => Container(
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
                                color: const Color(0xFF64748B),
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
                      text:
                          _model.isLoading ? 'Processing...' : 'Confirm Payment',
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
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                        color: AppTheme.of(context).error,
                      ),
                ),
              ],
            ],
          ),
        ),
      );

  String get _formattedBookingDate {
    if (widget.bookingDate == null) {
      return 'Not set';
    }

    final date = DateTime.tryParse(widget.bookingDate!);
    if (date == null) {
      return widget.bookingDate!;
    }

    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }
}
