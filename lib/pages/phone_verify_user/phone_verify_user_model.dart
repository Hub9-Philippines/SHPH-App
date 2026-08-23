import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'phone_verify_user_widget.dart' show PhoneVerifyUserWidget;

class PhoneVerifyUserModel extends FlutterFlowModel<PhoneVerifyUserWidget> {
  late PinInputController pinCodeController;
  String pinCodeValue = '';

  @override
  void initState(BuildContext context) {
    pinCodeController = PinInputController();
  }

  @override
  void dispose() {
    pinCodeController.dispose();
  }
}
