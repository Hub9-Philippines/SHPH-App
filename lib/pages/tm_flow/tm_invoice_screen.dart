import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/components/cupertino_ui/app_button.dart';
import '/components/screen_header.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import '../booking_funnel/widgets/booking_flow_route.dart';
import 'tm_controller.dart';
import 'tm_payment_screen.dart';

class TMInvoiceScreen extends StatelessWidget {
  const TMInvoiceScreen({super.key});

  static const String routeName = 'TMInvoice';
  static const String routePath = '/tm/invoice';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Consumer<TMFlowController>(
      builder: (context, controller, _) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              ScreenHeader(title: l10n.tmFinalInvoice),
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
                      Text(
                        controller.selectedServiceLabel,
                        style: theme.titleMedium.override(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _InvoiceRow(
                        label: l10n.tmBaseLaborFee,
                        value: controller.baseLaborCost,
                      ),
                      if (controller.approvedHardwareCost > 0) ...[
                        const SizedBox(height: 12),
                        _InvoiceRow(
                          label: l10n.tmApprovedHardwareLabel,
                          value: controller.approvedHardwareCost,
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      _InvoiceRow(
                        label: l10n.tmTotalDue,
                        value: controller.totalInvoiceAmount,
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.tmFinalAmountReflects,
                  style: theme.bodyMedium.override(
                    color: theme.secondaryText,
                  ),
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
                            child: const TMPaymentScreen(),
                          ),
                        ),
                      );
                    },
                    backgroundColor: theme.primary,
                    foregroundColor: theme.onPrimary,
                    borderRadius: 18,
                    width: double.infinity,
                    child: Text(
                      l10n.tmPayNow,
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
  },
);
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: (emphasize ? theme.titleSmall : theme.bodyMedium).override(
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          'Php ${value.toStringAsFixed(0)}',
          style: (emphasize ? theme.titleSmall : theme.bodyMedium).override(
            color: emphasize ? theme.primary : theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
