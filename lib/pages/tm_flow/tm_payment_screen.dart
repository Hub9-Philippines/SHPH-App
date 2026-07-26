import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/components/screen_header.dart';
import '/theme/app_theme.dart';
import '../booking_funnel/widgets/booking_flow_route.dart';
import 'tm_controller.dart';
import 'tm_rating_screen.dart';

class TMPaymentScreen extends StatefulWidget {
  const TMPaymentScreen({super.key});

  static const String routeName = 'TMPayment';
  static const String routePath = '/tm/payment';

  @override
  State<TMPaymentScreen> createState() => _TMPaymentScreenState();
}

class _TMPaymentScreenState extends State<TMPaymentScreen> {
  late String _selectedPaymentMethod;
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = context.read<TMFlowController>().paymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Consumer<TMFlowController>(
      builder: (context, controller, _) {
        _handleControllerErrors(controller);
        return Scaffold(
          backgroundColor: theme.primaryBackground,
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                const ScreenHeader(title: 'Pay for Service'),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
                    children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount due',
                      style: theme.bodyMedium.override(
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Php ${controller.totalInvoiceAmount.toStringAsFixed(0)}',
                      style: theme.displaySmall.override(
                        font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _PaymentChoiceCard(
                label: 'GCash',
                subtitle: 'Fast mobile wallet payment',
                selected: _selectedPaymentMethod == 'GCash',
                icon: Icons.account_balance_wallet_rounded,
                onTap: () {
                  context.read<TMFlowController>().setPaymentMethod('GCash');
                  setState(() => _selectedPaymentMethod = 'GCash');
                },
              ),
              const SizedBox(height: 12),
              _PaymentChoiceCard(
                label: 'Card',
                subtitle: 'Visa, Mastercard, and debit cards',
                selected: _selectedPaymentMethod == 'Card',
                icon: Icons.credit_card_rounded,
                onTap: () {
                  context.read<TMFlowController>().setPaymentMethod('Card');
                  setState(() => _selectedPaymentMethod = 'Card');
                },
              ),
              const SizedBox(height: 12),
              _PaymentChoiceCard(
                label: 'Cash on Completion',
                subtitle: 'Record settlement after direct payment',
                selected: _selectedPaymentMethod == 'Cash on Completion',
                icon: Icons.payments_rounded,
                onTap: () {
                  context
                      .read<TMFlowController>()
                      .setPaymentMethod('Cash on Completion');
                  setState(() => _selectedPaymentMethod = 'Cash on Completion');
                },
              ),
            ],
          ),
        ),
      ],
    ),
  ),
  bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isProcessingPayment
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          final success = await controller.processPayment();
                          if (!mounted || !success) {
                            return;
                          }
                          await navigator.pushReplacement(
                            buildBookingFlowRoute(
                              ChangeNotifierProvider.value(
                                value: controller,
                                child: const TMRatingScreen(),
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.secondaryBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: controller.isProcessingPayment
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(theme.secondaryBackground),
                          ),
                        )
                      : Text(
                          'Pay Now',
                          style: theme.titleMedium.override(
                            color: theme.secondaryBackground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleControllerErrors(TMFlowController controller) {
    final error = controller.lastErrorMessage;
    if (error == null || error == _lastShownError) {
      return;
    }
    _lastShownError = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      controller.clearLastError();
    });
  }
}

class _PaymentChoiceCard extends StatelessWidget {
  const _PaymentChoiceCard({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? theme.primary : theme.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: theme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
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
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? theme.primary : theme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
