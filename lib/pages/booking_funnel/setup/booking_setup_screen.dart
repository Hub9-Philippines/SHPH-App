import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/components/cupertino_ui/app_button.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import '../booking_controller.dart';
import '../checkout/checkout_screen.dart';
import '../widgets/booking_flow_route.dart';
import '../widgets/details_stage_content.dart';

class BookingSetupScreen extends StatelessWidget {
  const BookingSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_rounded,
              size: 24, color: theme.primaryText),
        ),
        titleSpacing: 0,
        title: Text(
          l10n.bfServiceSetup,
          style: theme.titleLarge.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: DetailsStageContent(),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AppButton(
                    onPressed: () async {
                      final controller =
                          context.read<BookingFlowController>();
                      if (!controller.hasValidSchedule) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.bfScheduleMandatoryError),
                          ),
                        );
                        return;
                      }
                      final guarded =
                          await BookingFlowController.checkAndGuardActiveMatching(
                        context,
                      );
                      if (guarded || !context.mounted) {
                        return;
                      }

                      unawaited(
                        Navigator.of(context).push(
                          buildBookingFlowRoute(
                            ChangeNotifierProvider.value(
                              value: controller,
                              child: const CheckoutScreen(),
                            ),
                          ),
                        ),
                      );
                    },
                    backgroundColor: theme.primary,
                    foregroundColor: theme.onPrimary,
                    borderRadius: 16,
                    child: Text(
                      l10n.bfContinueToCheckout,
                      style: theme.titleMedium.override(
                        fontWeight: FontWeight.w700,
                        color: theme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
