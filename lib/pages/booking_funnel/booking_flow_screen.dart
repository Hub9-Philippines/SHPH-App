import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/backend/supabase/database/tables/addresses.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_pickers.dart';
import '/components/edit_address/edit_address_widget.dart';
import '/l10n/app_localizations.dart';
import '/models/service_listing.dart';
import '/pages/booking_payment/booking_payment_widget.dart';
import '/theme/app_theme.dart';
import 'booking_controller.dart';
import 'booking_models.dart';
import 'widgets/address_banner.dart';
import 'widgets/details_stage_content.dart';
import 'widgets/review_stage_content.dart';
import 'widgets/time_selection_panel.dart';

class BookingFlowScreen extends StatelessWidget {
  const BookingFlowScreen({
    required this.selectedService,
    this.initialUrgency,
    this.initialScheduledDate,
    this.initialScheduledTime,
    super.key,
  });

  static String routeName = 'BookingFlow';
  static String routePath = '/booking-flow';

  final ServiceListing selectedService;
  final BookingUrgency? initialUrgency;
  final DateTime? initialScheduledDate;
  final TimeOfDay? initialScheduledTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fallbackHome = l10n?.bfHome ?? 'Home';
    final appState = FFAppState();
    final resolvedUrgency = initialUrgency ?? BookingUrgency.rightNow;
    final initialDraft = BookingDraft(
      dispatchMode: resolvedUrgency == BookingUrgency.scheduled
          ? BookingDispatchMode.scheduled
          : BookingDispatchMode.onDemand,
      urgency: resolvedUrgency,
      rooms: 1,
      cleaningType: ServiceType.standard,
      paymentMethod: BookingPaymentMethod.gcash,
      address: BookingAddress(
        label: appState.selectedAddressLabel.isNotEmpty
            ? appState.selectedAddressLabel
            : fallbackHome,
        line1: appState.selectedAddressLine1.isNotEmpty
            ? appState.selectedAddressLine1
            : '123 Example Street',
        city: appState.selectedAddressCity.isNotEmpty
            ? appState.selectedAddressCity
            : 'Metro Manila',
      ),
      latitude: appState.selectedLatitude ?? 14.5995,
      longitude: appState.selectedLongitude ?? 120.9842,
      serviceListingId: selectedService.id,
      serviceCategoryId: selectedService.category,
      serviceTitle: selectedService.title,
      serviceCategoryName: selectedService.categoryName,
      serviceDescription: selectedService.description,
      serviceImageUrl: selectedService.thumbnail,
      serviceBasePrice: selectedService.basePrice,
      servicePriceUnit: selectedService.priceUnit,
      scheduledDate: initialScheduledDate,
      scheduledTime: initialScheduledTime,
    );

    return ChangeNotifierProvider(
      create: (_) => BookingFlowController(initialDraft: initialDraft),
      child: _CleaningBookingFlowView(selectedService: selectedService),
    );
  }
}

class _CleaningBookingFlowView extends StatefulWidget {
  const _CleaningBookingFlowView({required this.selectedService});

  final ServiceListing selectedService;

  @override
  State<_CleaningBookingFlowView> createState() =>
      _CleaningBookingFlowViewState();
}

class _CleaningBookingFlowViewState extends State<_CleaningBookingFlowView> {
  static const List<IconData> _stageIcons = [
    Icons.place_rounded,
    Icons.schedule_rounded,
    Icons.tune_rounded,
    Icons.receipt_long_rounded,
  ];

  /// The single expanded accordion stage (0..3).
  int _activeStage = 0;

  /// Highest stage the client has unlocked so far (0..3).
  int _maxUnlocked = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controller = context.read<BookingFlowController>();
      if (controller.serverQuote == null) {
        unawaited(controller.refreshQuote());
      }
      BookingFlowController.checkAndGuardActiveMatching(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _stageDone(int stage, BookingFlowController controller) {
    switch (stage) {
      case 0:
        return controller.hasValidAddress;
      case 1:
        return controller.hasValidSchedule;
      case 3:
        return controller.serverQuote != null && !controller.isLoadingQuote;
      default:
        return true;
    }
  }

  String _stageSummary(
    int stage,
    BookingFlowController controller,
    AppLocalizations l10n,
  ) {
    final draft = controller.draft;
    switch (stage) {
      case 0:
        return '${draft.address.label} — ${draft.address.line1}, ${draft.address.city}';
      case 1:
        final isScheduled = draft.dispatchMode == BookingDispatchMode.scheduled ||
            draft.urgency == BookingUrgency.scheduled;
        return isScheduled
            ? formatScheduleLabel(draft, l10n)
            : formatAsapLabel(draft, l10n);
      case 2:
        return '${draft.rooms} · ${controller.cleaningTypeLabel(l10n)}';
      case 3:
        return controller.serverQuote != null
            ? 'PHP ${controller.quote.total.toStringAsFixed(0)}'
            : l10n.bfEstimatedTotal;
      default:
        return '';
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _onHeaderTap(int stage) {
    if (stage > _maxUnlocked || stage == _activeStage) {
      return;
    }
    setState(() {
      _activeStage = stage;
    });
    _scrollToTop();
  }

  void _onContinue(BookingFlowController controller, AppLocalizations l10n) {
    final stage = _activeStage;
    if (stage == 0) {
      if (!controller.hasValidAddress) {
        _showSnack(l10n.bkErrSelectAddress);
        return;
      }
    } else if (stage == 1) {
      if (!controller.hasValidSchedule) {
        _showSnack(l10n.bfScheduleMandatoryError);
        return;
      }
    } else if (stage == 3) {
      _proceedToPayment(controller);
      return;
    }
    setState(() {
      if (stage + 1 > _maxUnlocked) {
        _maxUnlocked = stage + 1;
      }
      _activeStage = stage + 1;
    });
    _scrollToTop();
  }

  /// Review → payment handoff. Extras must match the contract read by
  /// `app_router.dart` (`BookingPaymentWidget` route).
  void _proceedToPayment(BookingFlowController controller) {
    if (controller.serverQuote == null || controller.isLoadingQuote) {
      return;
    }
    final draft = controller.draft;
    final service = widget.selectedService;
    final total = controller.quote.total > 0
        ? controller.quote.total
        : (draft.serviceBasePrice ?? service.basePrice ?? 0);
    final date = draft.scheduledDate ?? DateTime.now();
    final time = draft.scheduledTime ?? TimeOfDay.now();
    context.pushNamed(
      BookingPaymentWidget.routeName,
      extra: <String, dynamic>{
        'serviceId': draft.serviceListingId ?? service.id,
        'serviceName': draft.serviceTitle ?? service.title,
        'category': draft.serviceCategoryName ?? service.categoryName,
        'price': 'PHP ${total.toStringAsFixed(0)}',
        'imageUrl': draft.serviceImageUrl ?? service.thumbnail,
        'bookingDate': date.toIso8601String(),
        'bookingTime': time.format(context),
        'notes': draft.landmarks.trim().isEmpty ? null : draft.landmarks.trim(),
        'providerName': service.providerName,
        'providerPhoto': service.providerPhoto,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Consumer<BookingFlowController>(
          builder: (context, controller, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(controller, l10n, theme),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    for (var stage = 0; stage < 4; stage++)
                      _StageCard(
                        title: [
                          l10n.bfLocation,
                          l10n.bfTime,
                          l10n.bfDetails,
                          l10n.bfReview,
                        ][stage],
                        summary: _stageSummary(stage, controller, l10n),
                        icon: _stageIcons[stage],
                        active: stage == _activeStage,
                        locked: stage > _maxUnlocked,
                        done: _stageDone(stage, controller),
                        onTap: () => _onHeaderTap(stage),
                        child: _stageBody(stage, controller, l10n),
                      ),
                  ],
                ),
              ),
              _buildBottomBar(controller, l10n, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BookingFlowController controller,
    AppLocalizations l10n,
    AppThemeData theme,
  ) =>
      Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBackButton(
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.selectedServiceLabel(l10n),
                  style: theme.titleLarge.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _heroSubtitle(controller, l10n),
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _stageBody(
    int stage,
    BookingFlowController controller,
    AppLocalizations l10n,
  ) {
    switch (stage) {
      case 0:
        return AddressBanner(
          address: controller.draft.address,
          onTap: () => _editBookingAddress(context, controller),
        );
      case 1:
        return TimeSelectionPanel(
          serviceTitle: controller.selectedServiceLabel(l10n),
          urgency: controller.draft.urgency,
          scheduledDate: controller.draft.scheduledDate,
          scheduledTime: controller.draft.scheduledTime,
          onUrgencyChanged: controller.setUrgency,
          onPickLaterToday: _pickLaterToday,
          onPickScheduledSlot: _pickScheduledSlot,
          onNext: () {},
          embedded: true,
          showNextButton: false,
        );
      case 2:
        return const DetailsStageContent(scrollable: false);
      case 3:
        return ReviewStageContent(
          controller: controller,
          onPickAddress: () => _editBookingAddress(context, controller),
          onBack: () => setState(() => _activeStage = 2),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomBar(
    BookingFlowController controller,
    AppLocalizations l10n,
    AppThemeData theme,
  ) {
    final onReview = _activeStage == 3;
    final canProceed =
        controller.serverQuote != null && !controller.isLoadingQuote;
    final totalLabel = controller.serverQuote != null
        ? 'PHP ${controller.quote.total.toStringAsFixed(0)}'
        : controller.isLoadingQuote
            ? '…'
            : '—';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(
          top: BorderSide(color: theme.alternate.withValues(alpha: 0.6)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.bfEstimatedTotal,
                  style: theme.bodySmall.override(
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalLabel,
                  style: theme.titleMedium.override(
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 52,
            child: AppButton(
              minWidth: 168,
              onPressed: onReview && !canProceed
                  ? null
                  : () => _onContinue(controller, l10n),
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
              borderRadius: 16,
              child: Text(
                onReview ? l10n.bkProceed : l10n.bfContinue,
                style: theme.titleSmall.override(
                  fontWeight: FontWeight.w700,
                  color: theme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLaterToday(BuildContext context) async {
    final controller = context.read<BookingFlowController>();
    final outerContext = context;

    final picked = await showAppTimePicker(
      context: outerContext,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) {
      return;
    }
    if (!outerContext.mounted) {
      return;
    }

    controller.setSchedule(time: picked, urgency: BookingUrgency.laterToday);
  }

  Future<void> _pickScheduledSlot(BuildContext context) async {
    final controller = context.read<BookingFlowController>();
    final date = await showAppDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }
    final time = await showAppTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) {
      return;
    }

    if (!context.mounted) {
      return; // Safe check before calling updates
    }

    controller.setSchedule(
      date: date,
      time: time,
      urgency: BookingUrgency.scheduled,
    );
  }

  Future<void> _editBookingAddress(
    BuildContext context,
    BookingFlowController controller,
  ) async {
    final result = await showModalBottomSheet<AddressesRow>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: const EditAddressWidget(),
        ),
      ),
    );
    if (!context.mounted || result == null) {
      return;
    }
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
      ),
    );

    final latitude = appState.selectedLatitude ?? result.latitude;
    final longitude = appState.selectedLongitude ?? result.longitude;
    if (latitude == null || longitude == null) {
      return;
    }

    controller.setCoordinates(latitude: latitude, longitude: longitude);
  }

  String _heroSubtitle(BookingFlowController controller, AppLocalizations l10n) {
    final category = controller.draft.serviceCategoryName;
    if (category != null && category.isNotEmpty) {
      return l10n.bfHeroCategoryReady(category);
    }
    return l10n.bfHeroFastDispatch;
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.title,
    required this.summary,
    required this.icon,
    required this.active,
    required this.locked,
    required this.done,
    required this.onTap,
    required this.child,
  });

  final String title;
  final String summary;
  final IconData icon;
  final bool active;
  final bool locked;
  final bool done;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: active
              ? theme.primary.withValues(alpha: 0.45)
              : theme.alternate,
          width: active ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: locked ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: active
                          ? theme.primary.withValues(alpha: 0.12)
                          : theme.primaryBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: locked ? theme.secondaryText : theme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.titleSmall.override(
                            fontWeight: FontWeight.w700,
                            color:
                                locked ? theme.secondaryText : theme.primaryText,
                          ),
                        ),
                        if (!active) ...[
                          const SizedBox(height: 2),
                          Text(
                            summary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodySmall.override(
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (active)
                    Icon(
                      Icons.expand_less_rounded,
                      color: theme.secondaryText,
                    )
                  else if (locked)
                    Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: theme.secondaryText,
                    )
                  else if (done)
                    Icon(
                      Icons.check_circle_rounded,
                      color: theme.primary,
                      size: 20,
                    )
                  else
                    Icon(
                      Icons.expand_more_rounded,
                      color: theme.secondaryText,
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: active
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TopBackButton extends StatelessWidget {
  const _TopBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.primaryBackground.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.alternate.withValues(alpha: 0.4),
            ),
            boxShadow: AppThemeData.shadowCard,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 22,
            color: theme.primaryText,
          ),
        ),
      ),
    );
  }
}
