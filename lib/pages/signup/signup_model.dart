import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'signup_widget.dart' show SignupWidget;

class SignupModel extends FlutterFlowModel<SignupWidget> {
  ///  Local state fields for this page.

  bool isPhoneValid = false;
  bool isLoading = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PhoneField widget.
  FocusNode? phoneFieldFocusNode;
  TextEditingController? phoneFieldTextController;
  late MaskTextInputFormatter phoneFieldMask;
  String? Function(BuildContext, String?)? phoneFieldTextControllerValidator;

  // State field(s) for the registration form.
  TextEditingController? firstNameTextController;
  FocusNode? firstNameFocusNode;
  TextEditingController? middleNameTextController;
  FocusNode? middleNameFocusNode;
  TextEditingController? lastNameTextController;
  FocusNode? lastNameFocusNode;
  TextEditingController? emailTextController;
  FocusNode? emailFocusNode;
  TextEditingController? passwordTextController;
  FocusNode? passwordFocusNode;
  TextEditingController? confirmPasswordTextController;
  FocusNode? confirmPasswordFocusNode;

  String? errorMessage;
  // Model for backButton component.
  late BackButtonModel backButtonModel;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    phoneFieldFocusNode?.dispose();
    phoneFieldTextController?.dispose();

    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();
    middleNameFocusNode?.dispose();
    middleNameTextController?.dispose();
    lastNameFocusNode?.dispose();
    lastNameTextController?.dispose();
    emailFocusNode?.dispose();
    emailTextController?.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
    confirmPasswordFocusNode?.dispose();
    confirmPasswordTextController?.dispose();

    backButtonModel.dispose();
  }
}
