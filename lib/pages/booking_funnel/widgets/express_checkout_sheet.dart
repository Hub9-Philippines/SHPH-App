import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/backend/supabase/supabase.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_switch.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/edit_address/edit_address_widget.dart';
import '/components/user_avatar.dart';
import '/l10n/app_localizations.dart';
import '/models/service_listing.dart';
import '/theme/app_theme.dart';
import '../booking_controller.dart';
import '../booking_models.dart';

/// Multi-step confirm-booking sheet (spec: service-search-workflow /
/// confirm booking): progress spine, specialist summary, service matrix,
/// location context, arrival-code security, dual-layer payments, sticky CTA.
class ExpressCheckoutSheet extends StatelessWidget {
  const ExpressCheckoutSheet({
    super.key,
    required this.controller,
    required this.quote,
    required this.isScheduled,
    required this.service,
    required this.onBack,
    required this.onConfirm,
  });

  final BookingFlowController controller;
  final BookingQuote quote;
  final bool isScheduled;
  final ServiceListing service;
  final VoidCallback onBack;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final step = controller.checkoutStep;

    void onStepBack() {
      if (controller.onFirstCheckoutStep) {
        onBack();
      } else {
        controller.goToStep(step - 1);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: theme.alternate,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            IconButton(
              onPressed: controller.isSubmitting ? null : onStepBack,
              style: IconButton.styleFrom(
                backgroundColor: theme.secondaryBackground,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700),
                      color: theme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ProgressLineTracker(step: step),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Flexible(
          child: SingleChildScrollView(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Column(
                key: ValueKey('checkout_step_$step'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (step == 0) ...[
                    _SpecialistSummary(service: service),
                    const SizedBox(height: AppThemeData.spaceLg),
                    _ServiceMatrix(controller: controller),
                  ],
                  if (step == 1) ...[
                    _LocationContextCard(
                      controller: controller,
                      onChangeAddress: () =>
                          _CheckoutSheets.pickAddress(context, controller),
                    ),
                    const SizedBox(height: AppThemeData.spaceLg),
                    const _ArrivalCodeRow(),
                  ],
                  if (step == 2) _PaymentMatrix(controller: controller),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppThemeData.spaceLg),
        _CheckoutFooter(
          controller: controller,
          quote: quote,
          isScheduled: isScheduled,
          onNextOrConfirm: step < BookingFlowController.checkoutStepCount - 1
              ? () => controller.goToStep(step + 1)
              : () => onConfirm(),
        ),
      ],
    );
  }
}

class _ProgressLineTracker extends StatelessWidget {
  const _ProgressLineTracker({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final steps = [l10n.bfServices, l10n.bfLocation, l10n.bfPayment];
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= step ? theme.primary : theme.alternate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[i],
                  style: theme.labelSmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: i == step ? FontWeight.w800 : FontWeight.w600,
                    ),
                    color: i <= step ? theme.primary : theme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (i < steps.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _SpecialistSummary extends StatelessWidget {
  const _SpecialistSummary({required this.service});

  final ServiceListing service;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          UserAvatar(
            photoUrl: service.providerPhoto,
            name: service.providerName ?? l10n.bfProvider,
            size: 44,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        service.providerName ?? l10n.bfAssignedProvider,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700),
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.verified_rounded,
                        size: 15, color: theme.primary),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 3),
                    Text(
                      l10n.bfReviewsCount(
                        service.ratingValue?.toStringAsFixed(1) ??
                            l10n.bfNewProvider,
                        service.reviewCount ?? 0,
                      ),
                      style:
                          theme.labelSmall.override(color: theme.secondaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (service.distanceKm != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.surfaceAlt,
                borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.near_me_rounded, size: 12, color: theme.primary),
                  const SizedBox(width: 3),
                  Text(
                    '${service.distanceKm!.toStringAsFixed(1)} km',
                    style: theme.labelSmall.override(
                      fontWeight: FontWeight.w700,
                      color: theme.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// TAIL2
class _ServiceMatrix extends StatelessWidget {
  const _ServiceMatrix({required this.controller});

  final BookingFlowController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);
    final draft = controller.draft;

    Widget row({
      required bool checked,
      required ValueChanged<bool?> onChanged,
      required String title,
      required String price,
      String? tag,
      bool locked = false,
    }) =>
        Padding(
          padding: const EdgeInsets.only(bottom: AppThemeData.spaceSm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
              border: Border.all(
                color: checked
                    ? theme.primary.withValues(alpha: 0.5)
                    : theme.border,
              ),
            ),
            child: Row(
              children: [
                Checkbox(value: checked, onChanged: locked ? null : onChanged),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: theme.bodyMedium.override(
                      fontWeight: FontWeight.w700,
                      color: theme.primaryText,
                    ),
                  ),
                ),
                if (tag != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppThemeData.accentYellow,
                      borderRadius:
                          BorderRadius.circular(AppThemeData.radiusPill),
                    ),
                    child: Text(
                      tag,
                      style: theme.labelSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                Text(
                  price,
                  style: theme.labelLarge.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                    color: theme.primary,
                  ),
                ),
              ],
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.bfServices),
        const SizedBox(height: AppThemeData.spaceSm),
        row(
          checked: true,
          onChanged: (_) {},
          locked: true,
          title: draft.serviceTitle ?? l10n.bfSelectedService,
          price: 'PHP ${(controller.quote.basePrice).toStringAsFixed(0)}',
        ),
        if (controller.quote.timePremium != 0)
          row(
            checked: true,
            onChanged: (_) {},
            locked: true,
            title: 'Time adjustment',
            price: 'PHP ${controller.quote.timePremium.toStringAsFixed(0)}',
          ),
        if (controller.quote.platformFee != 0)
          row(
            checked: true,
            onChanged: (_) {},
            locked: true,
            title: 'Platform fee',
            price: 'PHP ${controller.quote.platformFee.toStringAsFixed(0)}',
          ),
        if (controller.quote.vat != 0)
          row(
            checked: true,
            onChanged: (_) {},
            locked: true,
            title: 'VAT',
            price: 'PHP ${controller.quote.vat.toStringAsFixed(0)}',
          ),
      ],
    );
  }
}

// TAIL3
class _LocationContextCard extends StatelessWidget {
  const _LocationContextCard({
    required this.controller,
    required this.onChangeAddress,
  });

  final BookingFlowController controller;
  final VoidCallback onChangeAddress;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final address = controller.draft.address;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.bfServiceLocation),
        const SizedBox(height: AppThemeData.spaceSm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppThemeData.spaceLg),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
            border: Border.all(color: theme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place_rounded, size: 18, color: theme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.label,
                          style: theme.bodyMedium.override(
                            fontWeight: FontWeight.w700,
                            color: theme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${address.line1}, ${address.city}',
                          style: theme.bodySmall.override(
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onChangeAddress,
                    child: Text(
                      l10n.bfChange,
                      style: theme.labelSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                        ),
                        color: theme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppThemeData.spaceMd),
              _LandmarkField(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}

class _LandmarkField extends StatefulWidget {
  const _LandmarkField({required this.controller});

  final BookingFlowController controller;

  @override
  State<_LandmarkField> createState() => _LandmarkFieldState();
}

class _LandmarkFieldState extends State<_LandmarkField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.draft.landmarks,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return AppTextField(
      controller: _textController,
      onChanged: widget.controller.setLandmarks,
      placeholder: l10n.bfLandmarksPlaceholder,
      placeholderStyle: theme.bodySmall.override(
        font: GoogleFonts.plusJakartaSans(),
        color: theme.textTertiary,
      ),
      radius: AppThemeData.radiusMd,
      fillColor: theme.primaryBackground,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _ArrivalCodeRow extends StatefulWidget {
  const _ArrivalCodeRow();

  @override
  State<_ArrivalCodeRow> createState() => _ArrivalCodeRowState();
}

class _ArrivalCodeRowState extends State<_ArrivalCodeRow> {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Consumer<BookingFlowController>(
      builder: (context, controller, _) {
        return Container(
          padding: const EdgeInsets.all(AppThemeData.spaceLg),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            children: [
              Icon(Icons.password_rounded, size: 20, color: theme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.bfRequireArrivalCode,
                          style: theme.bodyMedium.override(
                            fontWeight: FontWeight.w700,
                            color: theme.primaryText,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => showModalBottomSheet<void>(
                            context: context,
                            builder: (sheetContext) => Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                l10n.bfArrivalCodeInfo,
                                style: theme.bodyMedium.override(
                                  color: theme.secondaryText,
                                ),
                              ),
                            ),
                          ),
                          child: Icon(Icons.info_outline_rounded,
                              size: 15, color: theme.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.bfProviderMustConfirmCode,
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              AppSwitch(
                value: controller.draft.requireArrivalCode,
                onChanged: controller.setRequireArrivalCode,
                activeColor: theme.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}

// TAIL4
class _PaymentMatrix extends StatelessWidget {
  const _PaymentMatrix({required this.controller});

  final BookingFlowController controller;

  static const _digitalOptions = <(BookingPaymentMethod, IconData, String)>[
    (BookingPaymentMethod.gcash, Icons.account_balance_wallet_rounded, 'GCash'),
    (BookingPaymentMethod.maya, Icons.wallet_rounded, 'Maya'),
    (BookingPaymentMethod.card, Icons.credit_card_rounded, 'Card'),
    (BookingPaymentMethod.qrPh, Icons.qr_code_2_rounded, 'QR Ph'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final draft = controller.draft;
    final isDigital = draft.paymentMethod != BookingPaymentMethod.cod;

    Widget tier({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) =>
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? theme.primary : theme.primaryBackground,
                borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
                border: Border.all(
                  color: selected ? theme.primary : theme.border,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Text(
                label,
                style: theme.titleSmall.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                  ),
                  color: selected ? Colors.white : theme.secondaryText,
                ),
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.bfPaymentMethod),
        const SizedBox(height: AppThemeData.spaceSm),
        Row(
          children: [
            tier(
              label: l10n.bfCash,
              selected: draft.paymentMethod == BookingPaymentMethod.cod,
              onTap: () =>
                  controller.setPaymentMethod(BookingPaymentMethod.cod),
            ),
            const SizedBox(width: AppThemeData.spaceSm),
            tier(
              label: l10n.bfDigital,
              selected:
                  isDigital && draft.paymentMethod != BookingPaymentMethod.cod,
              onTap: () =>
                  controller.setPaymentMethod(BookingPaymentMethod.gcash),
            ),
          ],
        ),
        if (isDigital) ...[
          const SizedBox(height: AppThemeData.spaceMd),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _digitalOptions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppThemeData.spaceSm),
              itemBuilder: (context, index) {
                final (method, glyph, label) = _digitalOptions[index];
                final active = draft.paymentMethod == method;
                return GestureDetector(
                  onTap: () => controller.setPaymentMethod(method),
                  child: Container(
                    width: 92,
                    decoration: BoxDecoration(
                      color: theme.primaryBackground,
                      borderRadius:
                          BorderRadius.circular(AppThemeData.radiusLg),
                      border: Border.all(
                        color: active ? theme.primary : theme.border,
                        width: active ? 1.8 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          glyph,
                          size: 26,
                          color: active ? theme.primary : theme.secondaryText,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.labelSmall.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                            color: active
                                ? theme.primaryText
                                : theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _CheckoutFooter extends StatelessWidget {
  const _CheckoutFooter({
    required this.controller,
    required this.quote,
    required this.isScheduled,
    required this.onNextOrConfirm,
  });

  final BookingFlowController controller;
  final BookingQuote quote;
  final bool isScheduled;
  final VoidCallback onNextOrConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final categoryLabel = (controller.draft.serviceCategoryName ?? '').trim();
    final ctaLabel = categoryLabel.isEmpty
        ? l10n.bfBookNow
        : l10n.bfBookCategoryNow(categoryLabel);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              controller.isLoadingQuote
                  ? 'Loading estimate...'
                  : controller.quoteError != null
                      ? 'Estimate unavailable'
                      : l10n.bfTotalPriceDue,
              style: theme.bodyLarge.override(
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
              ),
            ),
            const Spacer(),
            Text(
              controller.isLoadingQuote
                  ? '...'
                  : controller.serverQuote == null
                      ? '—'
                      : 'PHP ${quote.total.toStringAsFixed(0)}',
              style: theme.titleLarge.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                color: theme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppThemeData.spaceMd),
        if (controller.quoteError != null)
          TextButton.icon(
            onPressed:
                controller.isLoadingQuote ? null : controller.refreshQuote,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry estimate'),
          ),
        AppButton(
          width: double.infinity,
          height: 56,
          backgroundColor: AppThemeData.actionPrimary,
          foregroundColor: Colors.white,
          borderRadius: AppThemeData.radiusLg,
          onPressed: controller.isSubmitting ||
                  controller.isLoadingQuote ||
                  controller.quoteError != null ||
                  controller.serverQuote == null
              ? null
              : onNextOrConfirm,
          child: controller.checkoutStep <
                  BookingFlowController.checkoutStepCount - 1
              ? Text(
                  l10n.bfContinue,
                  style: theme.titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800),
                    color: theme.onPrimary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        size: 19, color: Colors.white),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isScheduled ? l10n.bfConfirmReserveSlot : ctaLabel,
                        style: theme.titleMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800),
                          color: theme.onPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _CheckoutSheets {
  _CheckoutSheets._();

  static Future<void> pickAddress(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    final result = await showModalBottomSheet<AddressesRow>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (sheetContext) => GestureDetector(
        onTap: () => FocusScope.of(sheetContext).unfocus(),
        child: Padding(
          padding: MediaQuery.viewInsetsOf(sheetContext),
          child: const EditAddressWidget(),
        ),
      ),
    );
    if (!context.mounted || result == null) return;
    final l10n = AppLocalizations.of(context)!;

    final appState = FFAppState();
    controller.setAddress(
      BookingAddress(
        label: appState.selectedAddressLabel.isNotEmpty
            ? appState.selectedAddressLabel
            : (result.addressLine2 ?? l10n.bfAddress),
        line1: appState.selectedAddressLine1.isNotEmpty
            ? appState.selectedAddressLine1
            : (result.addressLine1 ?? ''),
        city: appState.selectedAddressCity.isNotEmpty
            ? appState.selectedAddressCity
            : (result.city ?? ''),
        instructions: controller.draft.landmarks.isEmpty
            ? null
            : controller.draft.landmarks,
      ),
    );
    final lat = appState.selectedLatitude ?? result.latitude;
    final lng = appState.selectedLongitude ?? result.longitude;
    if (lat != null && lng != null) {
      controller.setCoordinates(latitude: lat, longitude: lng);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: AppTheme.of(context).titleSmall.override(
              fontWeight: FontWeight.w700,
            ),
      );
}
