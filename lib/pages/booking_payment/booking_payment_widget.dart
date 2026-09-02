import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/shph_api_exception.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BookingPaymentModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _confirmPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.bpSelectMethod),
          backgroundColor: AppTheme.of(context).error,
        ),
      );
      return;
    }

    if (widget.serviceId == null) {
      return;
    }

    setState(() => _model.isLoading = true);

    try {
      final amount = _parsePrice(widget.price) ?? 0;

      if (_selectedPaymentMethod == 'cash') {
        final booking = await BookingsService.instance.createBooking(
          serviceListingId: widget.serviceId!,
          bookingDateTime: _resolveBookingDateTime(),
          notes: widget.notes,
          totalPrice: amount,
          paymentStatus: 'pay_on_completion',
        );
        if (mounted) {
          if (booking != null) {
            _goToSuccess(booking.id);
          } else {
            _model.isLoading = false;
            _model.errorMessage = _l10n.bpFailedCreate;
          }
        }
        return;
      }

      final controller = PaymentController.instance;
      if (_selectedPaymentMethod == 'card') {
        await controller.initializeStripe(
          const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY',
              defaultValue: 'pk_test_placeholder'),
        );
        final result = await controller.processStripePayment(
          amount: amount,
          currency: 'PHP',
          description: widget.serviceName ?? 'Service Booking',
          l10n: _l10n,
        );
        if (result.status != PaymentStatus.success) {
          if (mounted) {
            _model.isLoading = false;
            _model.errorMessage = result.errorMessage ?? _l10n.bpPaymentFailed;
          }
          return;
        }
        final booking = await BookingsService.instance.createBooking(
          serviceListingId: widget.serviceId!,
          bookingDateTime: _resolveBookingDateTime(),
          notes: widget.notes,
          totalPrice: amount,
          paymentStatus: 'paid',
        );
        _goToSuccess(booking?.id);
      } else if (_selectedPaymentMethod == 'ewallet') {
        final result = await controller.processMayaPayment(
          amount: amount,
          currency: 'PHP',
          description: widget.serviceName ?? 'Service Booking',
          l10n: _l10n,
        );
        if (result.status != PaymentStatus.success) {
          if (mounted) {
            _model.isLoading = false;
            _model.errorMessage = result.errorMessage ?? _l10n.bpPaymentFailed;
          }
          return;
        }
        final booking = await BookingsService.instance.createBooking(
          serviceListingId: widget.serviceId!,
          bookingDateTime: _resolveBookingDateTime(),
          notes: widget.notes,
          totalPrice: amount,
          paymentStatus: 'paid',
        );
        _goToSuccess(booking?.id);
      } else {
        final booking = await BookingsService.instance.createBooking(
          serviceListingId: widget.serviceId!,
          bookingDateTime: _resolveBookingDateTime(),
          notes: widget.notes,
          totalPrice: amount,
          paymentStatus: 'authorized_escrow',
        );
        _goToSuccess(booking?.id);
      }
    } catch (e) {
      if (mounted) {
        _model.isLoading = false;
        _model.errorMessage =
            'Error: ${e is ShphApiException ? e.message : e.toString()}';
      }
    }
  }

  /// Navigates to the consolidated confirmation screen with the created
  /// booking's data so the receipt shows real values.
  void _goToSuccess(String? bookingId) {
    if (!mounted) {
      return;
    }
    context.pushNamed(
      BookingSuccessWidget.routeName,
      extra: <String, dynamic>{
        if (bookingId != null) 'bookingId': bookingId,
        'serviceName': widget.serviceName,
        'totalLabel': 'PHP ${(widget.price ?? '').trim()}',
        'scheduledText': _scheduledText(),
      },
    );
  }

  String _scheduledText() {
    final date = DateTime.tryParse(widget.bookingDate ?? '');
    if (date == null) {
      return _l10n.bpConfirmSlot;
    }
    final time = _resolveBookingDateTime();
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year} · $hour:$minute $suffix';
  }

  /// Merges the route's booking date + time-of-day into one DateTime, which
  /// the API forwards as the required `scheduled_at` field. Accepts both
  /// 24-hour ('14:30:00') and 12-hour ('2:30 PM') time strings.
  DateTime _resolveBookingDateTime() {
    final date =
        DateTime.tryParse(widget.bookingDate ?? '') ?? DateTime.now();
    final raw = (widget.bookingTime ?? '').trim().toUpperCase();
    final isPm = raw.endsWith('PM');
    final isAm = raw.endsWith('AM');
    final cleaned = raw.replaceAll(RegExp(r'[AP]M'), '').trim();
    final parts = cleaned.split(':');
    var hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    if (isPm && hour < 12) {
      hour += 12;
    }
    if (isAm && hour == 12) {
      hour = 0;
    }
    return DateTime(date.year, date.month, date.day, hour, minute);
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
          backgroundColor: AppTheme.of(context).secondaryBackground,
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
                                _l10n.bpSelectPayment,
                                style: AppTheme.of(context).titleLarge.override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: AppTheme.of(context).primaryText,
                                    ),
                              ),
                              Text(
                                _l10n.bpSelectPaymentSubtitle,
                                style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.plusJakartaSans(),
                                      color: AppTheme.of(context).secondaryText,
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
                        _l10n.bpChooseHowToPay,
                                style: AppTheme.of(context).titleMedium.override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: AppTheme.of(context).primaryText,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _l10n.bpEscrowSubtitle,
                                style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.plusJakartaSans(),
                                      color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildPaymentOption(
                        value: 'card',
                        icon: Icons.credit_card_rounded,
                        label: _l10n.bpCard,
                        sublabel: _l10n.bpCardSub,
                        tint: AppTheme.of(context).primary,
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentOption(
                        value: 'ewallet',
                        icon: Icons.account_balance_wallet_rounded,
                        label: _l10n.bpEwallet,
                        sublabel: _l10n.bpEwalletSub,
                        tint: AppTheme.of(context).success,
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentOption(
                        value: 'qr',
                        icon: Icons.qr_code_rounded,
                        label: _l10n.bpQr,
                        sublabel: _l10n.bpQrSub,
                        tint: AppTheme.of(context).tertiary,
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentOption(
                        value: 'cash',
                        icon: Icons.payments_rounded,
                        label: _l10n.bpCash,
                        sublabel: _l10n.bpCashSub,
                        tint: AppTheme.of(context).error,
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.of(context).primaryText,
              AppTheme.of(context).primary.withValues(alpha: 0.7),
              AppTheme.of(context).primary,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppThemeData.shadowLg,
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
                      widget.category ?? _l10n.bkFallbackService,
                      style: AppTheme.of(context).labelMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.serviceName ?? _l10n.bkFallbackService,
                    style: AppTheme.of(context).titleLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.price ?? 'PHP 0',
                    style: AppTheme.of(context).headlineSmall.override(
                          font: GoogleFonts.plusJakartaSans(
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
          color: AppTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppThemeData.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.bpSummaryTitle,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: AppTheme.of(context).primaryText,
                  ),
            ),
            const SizedBox(height: 14),
            _summaryRow(
              icon: Icons.calendar_today_rounded,
              label: _l10n.bpDate,
              value: _formattedBookingDate,
            ),
            const SizedBox(height: 12),
            _summaryRow(
              icon: Icons.access_time_rounded,
              label: _l10n.bpTime,
              value: widget.bookingTime ?? _l10n.bpNotSet,
            ),
            if ((widget.notes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _summaryRow(
                icon: Icons.sticky_note_2_outlined,
                label: _l10n.bpNotes,
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
              color: AppTheme.of(context).surfaceAlt,
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
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                        color: AppTheme.of(context).primaryText,
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
                _l10n.bpEscrowNotice,
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
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
            color: isSelected ? tint.withValues(alpha: 0.08) : AppTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? tint : const Color(0xFFE5E9EE),
              width: isSelected ? 1.6 : 1,
            ),
            boxShadow: AppThemeData.shadowCard,
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
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                            color: AppTheme.of(context).primaryText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sublabel,
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.plusJakartaSans(),
                            color: AppTheme.of(context).secondaryText,
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
                    color: isSelected ? tint : AppTheme.of(context).border,
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
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                          _l10n.bpTotal,
                          style: AppTheme.of(context).bodySmall.override(
                                font: GoogleFonts.plusJakartaSans(),
                                color: AppTheme.of(context).secondaryText,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.price ?? 'PHP 0',
                          style: AppTheme.of(context).titleLarge.override(
                                font: GoogleFonts.plusJakartaSans(
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
                          _model.isLoading ? _l10n.bpProcessing : _l10n.bpConfirm,
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 54,
                        color: _model.isLoading
                            ? AppTheme.of(context).alternate
                            : AppTheme.of(context).primary,
                        textStyle: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.plusJakartaSans(
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
                        font: GoogleFonts.plusJakartaSans(
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
      return _l10n.bpNotSet;
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
