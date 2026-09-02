import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/invite_earn_banner.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'booking_controller.dart';
import 'booking_models.dart';

/// Data-driven booking confirmation layout. Rendered directly by the
/// `/booking-success` route (post-payment) and fed by [BookingSuccessScreen]
/// inside the funnel flow.
class BookingConfirmationView extends StatelessWidget {
  const BookingConfirmationView({
    super.key,
    this.bookingId,
    this.serviceTitle,
    this.providerName,
    this.scheduledText,
    this.totalLabel,
    this.paymentLabel,
  });

  final String? bookingId;
  final String? serviceTitle;
  final String? providerName;
  final String? scheduledText;
  final String? totalLabel;
  final String? paymentLabel;

  static const String _inviteUrl = 'https://serbisyohubph.com/invite';

  void _shareInviteLink(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(const ClipboardData(text: _inviteUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.bfInviteCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _addToCalendar(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final title = Uri.encodeComponent(
      serviceTitle ?? l10n.bsCalTitle,
    );
    // Floating local time; Google Calendar accepts yyyyMMdd'T'HHmmss.
    final start = DateTime.now().add(const Duration(days: 1));
    String fmt(DateTime d) =>
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}00';
    final url = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=$title&dates=${fmt(start)}/${fmt(start.add(const Duration(hours: 2)))}'
      '&details=${Uri.encodeComponent(l10n.bsCalDesc(bookingId ?? ''))}',
    );
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showCalendarFallback(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showCalendarFallback(context);
      }
    }
  }

  void _showCalendarFallback(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.bfCouldNotOpenCalendar),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _trackBooking(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (bookingId == null || bookingId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bfTrackingAfterAccept),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingDetailsWidget(bookingId: bookingId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: theme.secondaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CheckHero(),
              const SizedBox(height: 20),
              Text(
                l10n.bfBookingConfirmedExclaim,
                style: theme.headlineSmall.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.bfRequestInBody,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 20),
              _ReceiptCard(
                bookingId: bookingId,
                serviceTitle: serviceTitle,
                providerName: providerName ?? l10n.bfToBeAssigned,
                scheduledText:
                    scheduledText ?? l10n.bfConfirmSlotSoon,
                totalLabel:
                    totalLabel ?? paymentLabel ?? l10n.bfAsQuotedAtCheckout,
              ),
              const SizedBox(height: 20),
              AppButton(
                width: double.infinity,
                height: 54,
                backgroundColor: AppThemeData.actionPrimary,
                foregroundColor: Colors.white,
                borderRadius: AppThemeData.radiusMd,
                onPressed: () => _trackBooking(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_searching_rounded,
                        size: 19, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(l10n.bfTrackMyBooking),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AppButton(
                width: double.infinity,
                height: 52,
                variant: AppButtonVariant.outlined,
                backgroundColor: theme.primaryBackground,
                foregroundColor: AppThemeData.actionPrimary,
                borderSide: const BorderSide(
                    color: AppThemeData.actionPrimary),
                borderRadius: AppThemeData.radiusMd,
                onPressed: () => _addToCalendar(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_available_rounded,
                        size: 19, color: AppThemeData.actionPrimary),
                    const SizedBox(width: 8),
                    Text(l10n.bfAddToCalendar),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: theme.border),
              InviteEarnBanner(
                onShare: () => _shareInviteLink(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated scale/fade green checkmark hero.
class _CheckHero extends StatefulWidget {
  const _CheckHero();

  @override
  State<_CheckHero> createState() => _CheckHeroState();
}

class _CheckHeroState extends State<_CheckHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppThemeData.successBrand.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(14),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppThemeData.successBrand,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x337C5CFC),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
}

/// Bordered receipt with the essential booking data points.
class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.providerName,
    required this.scheduledText,
    required this.totalLabel,
    this.bookingId,
    this.serviceTitle,
  });

  final String? bookingId;
  final String? serviceTitle;
  final String providerName;
  final String scheduledText;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bfBookingSummary,
            style: theme.titleSmall.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              color: theme.primaryText,
            ),
          ),
          if (serviceTitle != null && serviceTitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              serviceTitle!,
              style: theme.bodySmall.override(
                font: GoogleFonts.plusJakartaSans(),
                color: theme.secondaryText,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _ReceiptRow(
            label: l10n.bfBookingId,
            value: (bookingId == null || bookingId!.isEmpty)
                ? l10n.bfPendingAssignment
                : bookingId!.length > 8
                    ? bookingId!.substring(0, 8).toUpperCase()
                    : bookingId!,
          ),
          const SizedBox(height: 10),
          _ReceiptRow(label: l10n.bfDateAndTime, value: scheduledText),
          const SizedBox(height: 10),
          _ReceiptRow(label: l10n.bfServiceProvider, value: providerName),
          const SizedBox(height: 10),
          Divider(color: theme.border, height: 1),
          const SizedBox(height: 10),
          _ReceiptRow(
            label: l10n.bfTotalAmount,
            value: totalLabel,
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.bodyMedium.override(
              font:
                  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              color: theme.secondaryText,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.bodyMedium.override(
              font: GoogleFonts.plusJakartaSans(
                fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
              ),
              color: emphasized
                  ? AppThemeData.successBrand
                  : theme.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}

/// Funnel-flow wrapper: reads [BookingFlowController] state and renders the
/// shared confirmation view.
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Consumer<BookingFlowController>(
        builder: (context, controller, _) {
          final l10n = AppLocalizations.of(context)!;
          final draft = controller.draft;
          String? schedule;
          if (draft.scheduledDate != null) {
            final d = draft.scheduledDate!;
            final time = draft.scheduledTime != null
                ? formatTimeOfDay(draft.scheduledTime!)
                : null;
            schedule =
                '${d.day}/${d.month}/${d.year}${time == null ? '' : ' · $time'}';
          } else {
            schedule = l10n.bfProviderMatchingNow;
          }
          return BookingConfirmationView(
            bookingId: controller.activeReferenceId,
            serviceTitle: controller.selectedServiceLabel(l10n),
            providerName: l10n.bfToBeAssigned,
            scheduledText: schedule,
            paymentLabel: controller.paymentLabel(l10n),
          );
        },
      );
}
