import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/database/tables/payment_methods.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/skeleton_loading/skeleton_loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/l10n/app_localizations.dart';
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

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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
          backgroundColor: AppTheme.of(context).secondaryBackground,
          body: SafeArea(
            child: FutureBuilder<List<PaymentMethodsRow>>(
              future: _paymentMethodsFuture,
              builder: (context, snapshot) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 2,
                          shadowColor: Colors.black26,
                          child: InkWell(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
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
                                _l10n.pmTitle,
                                style:
                                    AppTheme.of(context).titleLarge.override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                              ),
                              Text(
                                _l10n.pmSubtitle,
                                style:
                                    AppTheme.of(context).bodySmall.override(
                                          font: GoogleFonts.plusJakartaSans(),
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildPaymentCard(BuildContext context, PaymentMethodsRow method) {
    late final String title;
    late final String subtitle;
    late final IconData icon;
    late final Color tint;

    if (method.type == 'card') {
      title =
          '${method.provider ?? 'Card'} ${_l10n.pmEndingIn(method.lastFour ?? '****')}';
      subtitle =
          _l10n.pmExpires(method.expiryMonth ?? '--', method.expiryYear ?? '----');
      icon = Icons.credit_card_rounded;
      tint = const Color(0xFF1B74E4);
    } else {
      title = method.provider ?? _l10n.pmEwallet;
      subtitle = method.phoneNumber ?? _l10n.pmNoPhone;
      icon = Icons.account_balance_wallet_rounded;
      tint = const Color(0xFF0F8A6C);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: method.isDefault ? tint : AppTheme.of(context).border,
          width: method.isDefault ? 1.5 : 1,
        ),
        boxShadow: AppThemeData.shadowCard,
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
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                              ),
                              color: AppTheme.of(context).primaryText,
                            ),
                      ),
                    ),
                    if (method.isDefault)
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
                          _l10n.adDefault,
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = AppTheme.of(context);
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.border),
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
              _l10n.pmEmptyTitle,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: AppTheme.of(context).primaryText,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _l10n.pmEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      );
  }

  Widget _buildErrorState(BuildContext context, String error) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(
              _l10n.pmErrorLoading,
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
            AppButton(
              onPressed: () => safeSetState(_loadPaymentMethods),
              child: Text(_l10n.retry),
            ),
          ],
        ),
      );

  Widget _buildBottomAction(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: AppThemeData.shadowCard,
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: FFButtonWidget(
              onPressed: () => _showAddPaymentDialog(context),
              text: _l10n.pmAddTitle,
              icon: const Icon(Icons.add_rounded, size: 18),
              options: FFButtonOptions(
                height: 54,
                color: AppTheme.of(context).primary,
                textStyle: AppTheme.of(context).titleSmall.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      color: AppTheme.of(context).onPrimary,
                    ),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      );

  void _showPaymentOptions(BuildContext context, PaymentMethodsRow method) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.of(context).border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            if (!method.isDefault)
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: Text(_l10n.pmSetDefault),
                onTap: () async {
                  Navigator.pop(context);
                  await _model.setAsDefault(method.id);
                  safeSetState(_loadPaymentMethods);
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(_l10n.pmSetDefaultFull),
                      ),
                    );
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(_l10n.pmEdit),
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
              leading:
                  Icon(Icons.delete_outline_rounded, color: AppTheme.of(context).error),
              title: Text(_l10n.pmRemove, style: TextStyle(color: AppTheme.of(context).error)),
              onTap: () async {
                Navigator.pop(context);
                await _model.deletePaymentMethod(method.id);
                safeSetState(_loadPaymentMethods);
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text(_l10n.pmRemoved)),
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
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(_l10n.pmAddTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card_rounded),
              title: Text(_l10n.pmCreditDebitCard),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(AddCardPaymentWidget.routeName).then((_) {
                  safeSetState(_loadPaymentMethods);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_rounded),
              title: Text(_l10n.pmEwalletOptions),
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
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(_l10n.cancel),
          ),
        ],
      ),
    );
  }
}
