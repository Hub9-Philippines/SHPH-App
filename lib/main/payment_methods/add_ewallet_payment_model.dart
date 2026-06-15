import 'package:flutter/material.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_ewallet_payment_widget.dart' show AddEwalletPaymentWidget;

class AddEwalletPaymentModel extends FlutterFlowModel<AddEwalletPaymentWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for backButton component.
  late BackButtonModel backButtonModel;

  // State fields
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  String? selectedProvider;
  bool isDefault = false;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    backButtonModel.dispose();
    phoneNumberController.dispose();
    accountNameController.dispose();
  }
}
