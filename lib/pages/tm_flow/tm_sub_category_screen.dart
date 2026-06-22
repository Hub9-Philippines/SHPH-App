import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
        create: (_) => TMFlowController(selectedService: selectedService),
        child: const _TMSubCategoryView(),
      );
}

class _TMSubCategoryView extends StatelessWidget {
  const _TMSubCategoryView();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final controller = context.watch<TMFlowController>();

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Choose a Job Type',
          style: theme.titleLarge.override(
            font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
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
                        'Time-Material flow',
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
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pick the closest job type so we can give a tighter estimate before searching for nearby providers.',
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
                      option.title,
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
                        color: const Color(0xFFF6FBFF),
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
