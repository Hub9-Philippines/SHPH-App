import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'phone_verify_user_widget.dart' show PhoneVerifyUserWidget;

class PhoneVerifyUserModel extends FlutterFlowModel<PhoneVerifyUserWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for backButton component.
  late BackButtonModel backButtonModel;
  // State field(s) for MaterialPinField widget.
  late PinInputController pinCodeController;
  String pinCodeValue = '';

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
    pinCodeController = PinInputController();
  }

  @override
  void dispose() {
    backButtonModel.dispose();
    pinCodeController.dispose();
  }
}
