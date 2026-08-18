import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '/main.dart';
import '/theme/app_theme.dart';
import 'booking_controller.dart';
import 'booking_models.dart';
import 'widgets/booking_status_scaffold.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) => Consumer<BookingFlowController>(
        builder: (context, controller, _) {
          final draft = controller.draft;
          final location = LatLng(draft.latitude, draft.longitude);

          return BookingStatusScaffold(
            location: location,
            markerHue: BitmapDescriptor.hueGreen,
            topCard: _SuccessTopCard(
              serviceTitle: controller.selectedServiceLabel,
              referenceId: controller.activeReferenceId,
            ),
            center: const _SuccessBadge(),
            bottomSheet: BookingStatusBottomSheet(
              child: _SuccessSheet(
                draft: draft,
                paymentLabel: controller.paymentLabel,
                onBackHome: () => Navigator.of(context, rootNavigator: true)
                    .pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const NavBarPage(
                      initialPage: 'Home',
                      disableResizeToAvoidBottomInset: true,
                    ),
                  ),
                  (route) => false,
                ),
              ),
            ),
          );
        },
      );
}

class _SuccessTopCard extends StatelessWidget {
  const _SuccessTopCard({
    required this.serviceTitle,
    this.referenceId,
  });

  final String serviceTitle;
  final String? referenceId;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primaryBackground.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppThemeData.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceTitle,
                style: theme.bodyLarge.override(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reservation confirmed',
                style: theme.titleMedium.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your slot is reserved and ready for provider assignment.',
                style: theme.bodyMedium.override(
                  color: theme.secondaryText,
                ),
              ),
              if ((referenceId ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Reference: $referenceId',
                    style: theme.labelMedium.override(
                      color: theme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.96),
        shape: BoxShape.circle,
        boxShadow: AppThemeData.shadowLg,
      ),
      child: Icon(
        Icons.check_circle_rounded,
        size: 58,
        color: theme.primary,
      ),
    );
  }
}

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet({
    required this.draft,
    required this.paymentLabel,
    required this.onBackHome,
  });

  final BookingDraft draft;
  final String paymentLabel;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
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
        const SizedBox(height: 16),
        Text(
          'Slot reserved',
          style: theme.titleLarge.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'We will notify you once a provider is assigned to your scheduled booking.',
          style: theme.bodyMedium.override(
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.primary.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: theme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next step',
                      style: theme.bodyMedium.override(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'We will send an update as soon as a provider accepts your scheduled request.',
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SuccessMetaRow(
          icon: Icons.calendar_today_rounded,
          title: 'Scheduled visit',
          subtitle: _scheduleText(draft),
        ),
        const SizedBox(height: 12),
        _SuccessMetaRow(
          icon: Icons.tune_rounded,
          title: 'Service setup',
          subtitle: _serviceSetupText(draft),
        ),
        const SizedBox(height: 12),
        _SuccessMetaRow(
          icon: Icons.place_rounded,
          title: draft.address.label,
          subtitle: '${draft.address.line1}, ${draft.address.city}',
        ),
        const SizedBox(height: 12),
        _SuccessMetaRow(
          icon: Icons.payments_rounded,
          title: 'Payment method',
          subtitle: paymentLabel,
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onBackHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              'Back to Home',
              style: theme.titleMedium.override(
                color: theme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _scheduleText(BookingDraft draft) {
    if (draft.scheduledDate != null && draft.scheduledTime != null) {
      return '${draft.scheduledDate!.month}/${draft.scheduledDate!.day}/${draft.scheduledDate!.year} at ${formatTimeOfDay(draft.scheduledTime!)}';
    }
    return 'Your booking has been confirmed.';
  }

  String _serviceSetupText(BookingDraft draft) {
    final category = (draft.serviceCategoryName ?? '').trim();
    final categoryText = category.isEmpty ? 'Service' : category;
    return '$categoryText • ${draft.rooms} ${draft.rooms == 1 ? 'unit' : 'units'} • ${draft.cleaningType.name}';
  }
}

class _SuccessMetaRow extends StatelessWidget {
  const _SuccessMetaRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.bodyMedium.override(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.bodySmall.override(
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
