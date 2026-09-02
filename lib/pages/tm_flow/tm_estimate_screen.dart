import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/screen_header.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import '../booking_funnel/widgets/booking_flow_route.dart';
import 'tm_broadcast_screen.dart';
import 'tm_controller.dart';
import 'tm_models.dart';

class TMEstimateScreen extends StatelessWidget {
  const TMEstimateScreen({
    required this.subCategory,
    super.key,
  });

  static const String routeName = 'TMEstimate';
  static const String routePath = '/tm/estimate';

  final TMSubCategoryOption subCategory;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<TMFlowController>();

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            ScreenHeader(title: l10n.tmEstimate),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: theme.alternate),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        subCategory.icon,
                        color: theme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      controller.selectedServiceLabel,
                      style: theme.bodyMedium.override(
                        color: theme.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subCategory.title,
                      style: theme.headlineSmall.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subCategory.subtitle,
                      style: theme.bodyMedium.override(
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.surfaceAlt,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: theme.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tmEstimatedServiceFee,
                            style: theme.labelLarge.override(
                              color: theme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subCategory.estimateLabel,
                            style: theme.displaySmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                              ),
                              color: theme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.tmFinalChargesMayChange,
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
              const SizedBox(height: 18),
              _InfoCard(
                icon: Icons.timer_outlined,
                title: l10n.tmOnDemandDispatch,
                subtitle: l10n.tmSearchNearbyFirst,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.receipt_long_rounded,
                title: l10n.tmTimePlusMaterials,
                subtitle: l10n.tmLaborEstimatedUpfront,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AppButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      buildBookingFlowRoute(
                        ChangeNotifierProvider.value(
                          value: controller,
                          child: const TMBroadcastScreen(),
                        ),
                      ),
                    );
                  },
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  borderRadius: 18,
                  width: double.infinity,
                  child: Text(
                    l10n.tmFindProvider,
                    style: theme.titleMedium.override(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.bodyLarge.override(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
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
      ),
    );
  }
}
