import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/database/tables/payment_methods.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/theme/app_theme.dart';
import 'payment_methods_model.dart';

export 'payment_methods_model.dart';

class PaymentMethodsWidget extends StatefulWidget {
  const PaymentMethodsWidget({super.key});

  static String routeName = 'PaymentMethods';
  static String routePath = '/paymentMethods';

  @override
  State<PaymentMethodsWidget> createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget> {
  late PaymentMethodsModel _model;
  late Future<List<PaymentMethodsRow>> _paymentMethodsFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, PaymentMethodsModel.new);
    _loadPaymentMethods();
  }

  void _loadPaymentMethods() {
    _paymentMethodsFuture = _model.loadPaymentMethods();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppTheme.of(context).primaryText,
                size: 24,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/profile');
                }
              },
            ),
            title: Text(
              'Payment Methods',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
            actions: const [],
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              child: FutureBuilder<List<PaymentMethodsRow>>(
                future: _paymentMethodsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(height: 16),
                        const PaymentMethodCardSkeleton(),
                        const SizedBox(height: 12),
                        const PaymentMethodCardSkeleton(),
                        const SizedBox(height: 12),
                        const PaymentMethodCardSkeleton(),
                        const SizedBox(height: 24),
                        _buildAddPaymentMethod(context),
                      ],
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading payment methods',
                            style: AppTheme.of(context).bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: AppTheme.of(context).bodySmall.override(
                                  color: AppTheme.of(context).secondaryText,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              safeSetState(_loadPaymentMethods);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final paymentMethods = snapshot.data ?? [];

                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 16),
                      if (paymentMethods.isEmpty)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  size: 64,
                                  color: AppTheme.of(context).secondaryText,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No payment methods yet',
                                  style: AppTheme.of(context).titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add a card or e-wallet to get started',
                                  style: AppTheme.of(context)
                                      .bodySmall
                                      .override(
                                        color:
                                            AppTheme.of(context).secondaryText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...paymentMethods.map((method) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPaymentCard(
                              context,
                              method,
                            ),
                          )),
                      const SizedBox(height: 24),
                      _buildAddPaymentMethod(context),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

  Widget _buildPaymentCard(
    BuildContext context,
    PaymentMethodsRow method,
  ) {
    String title;
    String subtitle;
    IconData icon;

    if (method.type == 'card') {
      title =
          '${method.provider ?? 'Card'} ending in ${method.lastFour ?? '****'}';
      subtitle =
          'Expires ${method.expiryMonth ?? '--'}/${method.expiryYear ?? '----'}';
      icon = Icons.credit_card;
    } else {
      title = method.provider ?? 'E-Wallet';
      subtitle = method.phoneNumber ?? 'No phone number';
      icon = Icons.account_balance_wallet;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: method.isDefault
            ? Border.all(
                color: AppTheme.of(context).primary,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.of(context).primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.of(context).primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),
                    if (method.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Default',
                          style: AppTheme.of(context).bodySmall.override(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.of(context).bodySmall.override(
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showPaymentOptions(context, method);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddPaymentMethod(BuildContext context) => GestureDetector(
        onTap: () {
          _showAddPaymentDialog(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.of(context).primary.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: AppTheme.of(context).primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Add Payment Method',
                style: AppTheme.of(context).titleSmall.override(
                      color: AppTheme.of(context).primary,
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ],
          ),
        ),
      );

  void _showPaymentOptions(BuildContext context, PaymentMethodsRow method) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!method.isDefault)
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Set as default'),
                onTap: () async {
                  Navigator.pop(context);
                  await _model.setAsDefault(method.id);
                  safeSetState(_loadPaymentMethods);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Set as default payment method')),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () async {
                Navigator.pop(context);
                if (method.type == 'card') {
                  await context.pushNamed(
                    AddCardPaymentWidget.routeName,
                    extra: {'paymentMethod': method},
                  );
                } else {
                  await context.pushNamed(
                    AddEwalletPaymentWidget.routeName,
                    extra: {'paymentMethod': method},
                  );
                }
                safeSetState(_loadPaymentMethods);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _model.deletePaymentMethod(method.id);
                safeSetState(_loadPaymentMethods);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment method removed')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit/Debit Card'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(AddCardPaymentWidget.routeName).then((_) {
                  safeSetState(_loadPaymentMethods);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('E-Wallet (GCash, Maya)'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(AddEwalletPaymentWidget.routeName).then((_) {
                  safeSetState(_loadPaymentMethods);
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
