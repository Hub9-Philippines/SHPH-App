import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'email_verify_widget.dart' show EmailVerifyWidget;

class EmailVerifyModel extends FlutterFlowModel<EmailVerifyWidget> {
  FocusNode? pinCodeFocusNode;
  TextEditingController? pinCodeController;
  String? Function(BuildContext, String?)? pinCodeControllerValidator;

  bool isVerifying = false;
  String? errorMessage;

  @override
  void initState(BuildContext context) {
    pinCodeController = TextEditingController();
    pinCodeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    pinCodeFocusNode?.dispose();
    pinCodeController?.dispose();
  }
}
