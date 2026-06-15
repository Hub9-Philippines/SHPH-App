import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/backend/supabase/database/tables/payment_methods.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import 'add_card_payment_model.dart';

export 'add_card_payment_model.dart';

class AddCardPaymentWidget extends StatefulWidget {
  const AddCardPaymentWidget({
    super.key,
    this.paymentMethod,
  });

  static String routeName = 'AddCardPayment';
  static String routePath = '/addCardPayment';

  final PaymentMethodsRow? paymentMethod;

  @override
  State<AddCardPaymentWidget> createState() => _AddCardPaymentWidgetState();
}

class _AddCardPaymentWidgetState extends State<AddCardPaymentWidget> {
  late AddCardPaymentModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, AddCardPaymentModel.new);

    // Populate fields if editing
    if (widget.paymentMethod != null) {
      _model.selectedProvider = widget.paymentMethod!.provider;
      _model.cardNumberController.text =
          '**** **** **** ${widget.paymentMethod!.lastFour ?? ''}';
      _model.expiryMonthController.text =
          widget.paymentMethod!.expiryMonth ?? '';
      _model.expiryYearController.text = widget.paymentMethod!.expiryYear ?? '';
      _model.isDefault = widget.paymentMethod!.isDefault;
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      final cardNumber = _model.cardNumberController.text.replaceAll(' ', '');
      final lastFour = cardNumber.length >= 4
          ? cardNumber.substring(cardNumber.length - 4)
          : cardNumber;

      if (widget.paymentMethod != null) {
        // Update existing
        await PaymentMethodsTable().update(
          data: {
            'provider': _model.selectedProvider,
            'expiry_month': _model.expiryMonthController.text,
            'expiry_year': _model.expiryYearController.text,
            'is_default': _model.isDefault,
          },
          matchingRows: (f) => f.eq('id', widget.paymentMethod!.id),
        );
      } else {
        // Insert new
        await PaymentMethodsTable().insert({
          'user_id': userId,
          'type': 'card',
          'provider': _model.selectedProvider,
          'last_four': lastFour,
          'expiry_month': _model.expiryMonthController.text,
          'expiry_year': _model.expiryYearController.text,
          'is_default': _model.isDefault,
        });
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.paymentMethod != null
                  ? 'Card updated successfully'
                  : 'Card added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving card: $e')),
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
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: wrapWithModel(
              model: _model.backButtonModel,
              updateCallback: () => safeSetState(() {}),
              child: const BackButtonWidget(),
            ),
            title: Text(
              'Add Card',
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
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card Information',
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _model.cardNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CardNumberFormatter(),
                        ],
                        maxLength: 19,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          hintText: '1234 5678 9012 3456',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          final digits = value.replaceAll(' ', '');
                          if (digits.length < 13 || digits.length > 19) {
                            return 'Please enter a valid card number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _model.selectedProvider,
                        decoration: InputDecoration(
                          labelText: 'Card Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Visa', child: Text('Visa')),
                          DropdownMenuItem(
                              value: 'Mastercard', child: Text('Mastercard')),
                          DropdownMenuItem(
                              value: 'Amex', child: Text('American Express')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _model.selectedProvider = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select card type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _model.expiryMonthController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              maxLength: 2,
                              decoration: InputDecoration(
                                labelText: 'MM',
                                hintText: '12',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final month = int.tryParse(value);
                                if (month == null || month < 1 || month > 12) {
                                  return 'Invalid month';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _model.expiryYearController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              maxLength: 4,
                              decoration: InputDecoration(
                                labelText: 'YYYY',
                                hintText: '2025',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final year = int.tryParse(value);
                                if (year == null ||
                                    year < DateTime.now().year) {
                                  return 'Invalid year';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _model.cardHolderController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Cardholder Name',
                          hintText: 'John Doe',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter cardholder name';
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
                        title: const Text('Set as default payment method'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 24),
                      FFButtonWidget(
                        onPressed: _saveCard,
                        text: 'Add Card',
                        options: FFButtonOptions(
                          width: double.infinity,
                          color: AppTheme.of(context).primary,
                          textStyle: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.poppins(
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

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
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
