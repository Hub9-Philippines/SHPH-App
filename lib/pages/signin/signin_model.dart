import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '/backend/supabase/supabase.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'signin_widget.dart' show SigninWidget;

class SigninModel extends FlutterFlowModel<SigninWidget> {
  ///  Local state fields for this page.

  bool isPhoneValid = false;
  bool isEmailvalid = true;
  bool isLoading = false;
  String? errorMessage;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for PhoneField widget.
  FocusNode? phoneFieldFocusNode;
  TextEditingController? phoneFieldTextController;
  late MaskTextInputFormatter phoneFieldMask;
  String? Function(BuildContext, String?)? phoneFieldTextControllerValidator;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<ProfilesRow>? isPhoneExists;
  bool isPhoneLoginLoading = false;
  bool isEmailLoginLoading = false;
  // State field(s) for EmailTextField widget.
  FocusNode? emailTextFieldFocusNode;
  TextEditingController? emailTextFieldTextController;
  String? Function(BuildContext, String?)?
      emailTextFieldTextControllerValidator;
  // State field(s) for PasswordTextField widget.
  FocusNode? passwordTextFieldFocusNode;
  TextEditingController? passwordTextFieldTextController;
  late bool passwordTextFieldVisibility;
  String? Function(BuildContext, String?)?
      passwordTextFieldTextControllerValidator;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<ProfilesRow>? emailSignup;
  // Model for backButton component.
  late BackButtonModel backButtonModel;

  @override
  void initState(BuildContext context) {
    passwordTextFieldVisibility = false;
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    phoneFieldFocusNode?.dispose();
    phoneFieldTextController?.dispose();

    emailTextFieldFocusNode?.dispose();
    emailTextFieldTextController?.dispose();

    passwordTextFieldFocusNode?.dispose();
    passwordTextFieldTextController?.dispose();

    backButtonModel.dispose();
  }
}
