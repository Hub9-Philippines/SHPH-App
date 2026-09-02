import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/components/screen_header.dart';
import '/l10n/app_localizations.dart';
import '/models/service_listing.dart';
import '/theme/app_theme.dart';
import '../booking_funnel/widgets/booking_flow_route.dart';
import 'tm_controller.dart';
import 'tm_estimate_screen.dart';
import 'tm_models.dart';

class TMSubCategoryScreen extends StatelessWidget {
  const TMSubCategoryScreen({
    required this.selectedService,
    super.key,
  });

  static const String routeName = 'TMSubCategory';
  static const String routePath = '/tm/sub-category';

  final ServiceListing selectedService;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (ctx) => TMFlowController(
          selectedService: selectedService,
          l10n: AppLocalizations.of(ctx)!,
        ),
        child: const _TMSubCategoryView(),
      );
}

class _TMSubCategoryView extends StatelessWidget {
  const _TMSubCategoryView();

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
            ScreenHeader(title: l10n.tmChooseJobType),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: theme.alternate),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.tmTimeMaterialFlow,
                              style: theme.labelMedium.override(
                                color: theme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            controller.selectedServiceLabel,
                            style: theme.headlineSmall.override(
                              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.tmPickClosestJobType,
                            style: theme.bodyMedium.override(
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: controller.subCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = controller.subCategories[index];
                        return _TMSubCategoryCard(
                          option: option,
                          onTap: () => _openEstimate(context, controller, option),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEstimate(
    BuildContext context,
    TMFlowController controller,
    TMSubCategoryOption option,
  ) {
    controller.selectSubCategory(option);
    Navigator.of(context).push(
      buildBookingFlowRoute(
        ChangeNotifierProvider.value(
          value: controller,
          child: TMEstimateScreen(subCategory: option),
        ),
      ),
    );
  }
}

class _TMSubCategoryCard extends StatelessWidget {
  const _TMSubCategoryCard({
    required this.option,
    required this.onTap,
  });

  final TMSubCategoryOption option;
  final VoidCallback onTap;

  String _localizedTitle(BuildContext context, String? key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'tmSubHomeLockout':
        return l10n.tmSubHomeLockout;
      case 'tmSubLockRepair':
        return l10n.tmSubLockRepair;
      case 'tmSubLockReplace':
        return l10n.tmSubLockReplace;
      case 'tmSubPipeLeak':
        return l10n.tmSubPipeLeak;
      case 'tmSubFaucetValve':
        return l10n.tmSubFaucetValve;
      case 'tmSubDrainClog':
        return l10n.tmSubDrainClog;
      case 'tmSubOutletSwitch':
        return l10n.tmSubOutletSwitch;
      case 'tmSubBreakerTrip':
        return l10n.tmSubBreakerTrip;
      case 'tmSubLightingRepair':
        return l10n.tmSubLightingRepair;
      case 'tmSubWasherDryer':
        return l10n.tmSubWasherDryer;
      case 'tmSubRefrigerator':
        return l10n.tmSubRefrigerator;
      case 'tmSubSmallAppliance':
        return l10n.tmSubSmallAppliance;
      case 'tmSubQuickRepair':
        return l10n.tmSubQuickRepair;
      case 'tmSubDiagnostic':
        return l10n.tmSubDiagnostic;
      case 'tmSubUrgent':
        return l10n.tmSubUrgent;
      default:
        return option.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.alternate),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  option.icon,
                  color: theme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizedTitle(context, option.titleKey),
                      style: theme.bodyLarge.override(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: theme.primary.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        option.estimateLabel,
                        style: theme.labelMedium.override(
                          color: theme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_rounded,
                color: theme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
