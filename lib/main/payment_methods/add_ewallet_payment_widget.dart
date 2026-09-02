import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/base_auth_user_provider.dart';
import '/backend/supabase/database/tables/payment_methods.dart';
import '/components/back_button/back_button_widget.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'add_ewallet_payment_model.dart';

export 'add_ewallet_payment_model.dart';

class AddEwalletPaymentWidget extends StatefulWidget {
  const AddEwalletPaymentWidget({
    super.key,
    this.paymentMethod,
  });

  static String routeName = 'AddEwalletPayment';
  static String routePath = '/addEwalletPayment';

  final PaymentMethodsRow? paymentMethod;

  @override
  State<AddEwalletPaymentWidget> createState() =>
      _AddEwalletPaymentWidgetState();
}

class _AddEwalletPaymentWidgetState extends State<AddEwalletPaymentWidget> {
  late AddEwalletPaymentModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, AddEwalletPaymentModel.new);

    // Populate fields if editing
    if (widget.paymentMethod != null) {
      _model.selectedProvider = widget.paymentMethod!.provider;
      _model.phoneNumberController.text =
          widget.paymentMethod!.phoneNumber ?? '';
      _model.accountNameController.text =
          widget.paymentMethod!.accountName ?? '';
      _model.isDefault = widget.paymentMethod!.isDefault;
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveEwallet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.pmNotAuthenticated)),
      );
      return;
    }

    try {
      final existingMethods = await PaymentMethodsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId),
      );
      final shouldBeDefault = _model.isDefault || existingMethods.isEmpty;

      if (shouldBeDefault) {
        await PaymentMethodsTable().update(
          data: {'is_default': false},
          matchingRows: (f) => f.eq('user_id', userId),
        );
      }

      if (widget.paymentMethod != null) {
        // Update existing
        await PaymentMethodsTable().update(
          data: {
            'provider': _model.selectedProvider,
            'phone_number': _model.phoneNumberController.text,
            'account_name': _model.accountNameController.text,
            'is_default': shouldBeDefault,
          },
          matchingRows: (f) => f.eq('id', widget.paymentMethod!.id),
        );
      } else {
        // Insert new
        await PaymentMethodsTable().insert({
          'user_id': userId,
          'type': 'ewallet',
          'provider': _model.selectedProvider,
          'phone_number': _model.phoneNumberController.text,
          'account_name': _model.accountNameController.text,
          'is_default': shouldBeDefault,
        });
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.paymentMethod != null
                  ? _l10n.pewUpdated
                  : _l10n.pewAdded)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.pewSaveError(e))),
        );
      }
    }
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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: CupertinoPageHeader(
              title: _l10n.pewTitle,
              backgroundColor: AppTheme.of(context).primaryBackground,
              leading: wrapWithModel(
                model: _model.backButtonModel,
                updateCallback: () => safeSetState(() {}),
                child: const BackButtonWidget(),
              ),
              titleStyle: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _l10n.pewInfoHeader,
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        initialValue: _model.selectedProvider,
                        decoration: InputDecoration(
                          labelText: _l10n.pewProvider,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'GCash', child: Text('GCash')),
                          DropdownMenuItem(value: 'Maya', child: Text('Maya')),
                          DropdownMenuItem(
                              value: 'ShopeePay', child: Text('ShopeePay')),
                          DropdownMenuItem(
                              value: 'GrabPay', child: Text('GrabPay')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _model.selectedProvider = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _l10n.pewSelectProvider;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _model.phoneNumberController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          PhoneNumberFormatter(),
                        ],
                        maxLength: 13,
                        decoration: InputDecoration(
                          labelText: _l10n.pewPhoneNumber,
                          hintText: '0917 123 4567',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _l10n.pewEnterPhone;
                          }
                          final digits = value.replaceAll(' ', '');
                          if (digits.length != 11) {
                            return _l10n.pewValidPhone;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _model.accountNameController,
                        textCapitalization: TextCapitalization.words,
                        label: _l10n.pewAccountName,
                        placeholder: 'John Doe',
                        radius: 12,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _l10n.pewEnterAccountName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CheckboxListTile(
                        value: _model.isDefault,
                        onChanged: (value) {
                          setState(() {
                            _model.isDefault = value ?? false;
                          });
                        },
                        title: Text(_l10n.pmSetDefaultFull),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 24),
                      FFButtonWidget(
                        onPressed: _saveEwallet,
                        text: _l10n.pewTitle,
                        options: FFButtonOptions(
                          width: double.infinity,
                          color: AppTheme.of(context).primary,
                          textStyle: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600),
                                color: AppTheme.of(context).primaryText,
                              ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 11) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i == 4 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
