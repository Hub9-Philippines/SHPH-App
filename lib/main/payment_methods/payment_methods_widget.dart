import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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
  late Future<List<Map<String, dynamic>>> _paymentMethodsFuture;

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
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _paymentMethodsFuture,
              builder: (context, snapshot) => Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppTheme.of(context).primary,
                      onRefresh: () async {
                        safeSetState(_loadPaymentMethods);
                      },
                      child: ListView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
                        children: [
                          _buildHeader(context, snapshot.data ?? []),
                          const SizedBox(height: 18),
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) ...[
                            const PaymentMethodCardSkeleton(),
                            const SizedBox(height: 12),
                            const PaymentMethodCardSkeleton(),
                            const SizedBox(height: 12),
                            const PaymentMethodCardSkeleton(),
                          ] else if (snapshot.hasError)
                            _buildErrorState(context, snapshot.error.toString())
                          else if ((snapshot.data ?? []).isEmpty)
                            _buildEmptyState(context)
                          else
                            ...(snapshot.data ?? []).map(
                              (method) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildPaymentCard(context, method),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomAction(context),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildTopBar(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(
          children: [
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/profile');
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.arrow_back_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Methods',
                    style: AppTheme.of(context).titleLarge.override(
                          font:
                              GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          color: const Color(0xFF16202A),
                        ),
                  ),
                  Text(
                    'Manage how you pay for bookings.',
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.poppins(),
                          color: const Color(0xFF6F7B86),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildHeader(BuildContext context, List<Map<String, dynamic>> methods) {
    final defaultCount = methods.where((method) => method['is_default'] == true).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF17212B),
            Color(0xFF23384D),
            Color(0xFF2F5368),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet setup',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Store your cards and e-wallets for a faster checkout experience.',
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(),
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child:
                    _WalletMetric(label: 'Saved', value: '${methods.length}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WalletMetric(label: 'Default', value: '$defaultCount'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Map<String, dynamic> method) {
    late final String title;
    late final String subtitle;
    late final IconData icon;
    late final Color tint;

    if ((method['type'] as String? ?? '') == 'card') {
      title =
          '${method['provider'] as String? ?? method['provider_name'] as String? ?? 'Card'} ending in ${method['last_four'] as String? ?? method['lastFour'] as String? ?? '****'}';
      subtitle =
          'Expires ${method['expiry_month'] as String? ?? '--'}/${method['expiry_year'] as String? ?? '----'}';
      icon = Icons.credit_card_rounded;
      tint = const Color(0xFF1B74E4);
    } else {
      title = method['provider'] as String? ?? method['provider_name'] as String? ?? 'E-Wallet';
      subtitle = method['phone_number'] as String? ?? '';
      icon = Icons.account_balance_wallet_rounded;
      tint = const Color(0xFF0F8A6C);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: method['is_default'] == true ? tint : const Color(0xFFE5E9EE),
          width: method['is_default'] == true ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: tint,
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
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFF16202A),
                            ),
                      ),
                    ),
                    if (method['is_default'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: tint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Default',
                          style: AppTheme.of(context).labelSmall.override(
                                color: tint,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
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
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => _showPaymentOptions(context, method),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.credit_card_off_rounded,
                size: 42,
                color: AppTheme.of(context).primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No payment methods yet',
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: const Color(0xFF16202A),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a card or e-wallet so checkout is faster when you book.',
              textAlign: TextAlign.center,
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      );

  Widget _buildErrorState(BuildContext context, String error) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(
              'Error loading payment methods',
              style: AppTheme.of(context).titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => safeSetState(_loadPaymentMethods),
              child: const Text('Retry'),
            ),
          ],
        ),
      );

  Widget _buildBottomAction(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: FFButtonWidget(
              onPressed: () => _showAddPaymentDialog(context),
              text: 'Add Payment Method',
              icon: const Icon(Icons.add_rounded, size: 18),
              options: FFButtonOptions(
                height: 54,
                color: AppTheme.of(context).primary,
                textStyle: AppTheme.of(context).titleSmall.override(
                      font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      color: Colors.white,
                    ),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      );

  void _showPaymentOptions(BuildContext context, Map<String, dynamic> method) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD6DBE1),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            if (method['is_default'] != true)
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: const Text('Set as default'),
                onTap: () async {
                  Navigator.pop(context);
                  await _model.setAsDefault(method['id']?.toString() ?? '');
                  safeSetState(_loadPaymentMethods);
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Set as default payment method'),
                      ),
                    );
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () async {
                Navigator.pop(context);
                if ((method['type'] as String? ?? '') == 'card') {
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
              leading:
                  const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text('Remove', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await _model.deletePaymentMethod(method['id']?.toString() ?? '');
                safeSetState(_loadPaymentMethods);
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Payment method removed')),
                  );
                }
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
              leading: const Icon(Icons.credit_card_rounded),
              title: const Text('Credit/Debit Card'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(AddCardPaymentWidget.routeName).then((_) {
                  safeSetState(_loadPaymentMethods);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_rounded),
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

class _WalletMetric extends StatelessWidget {
  const _WalletMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ),
      );
}
