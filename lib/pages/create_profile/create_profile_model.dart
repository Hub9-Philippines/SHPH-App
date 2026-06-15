import 'package:flutter/material.dart';

import '/components/password_validation_item/password_validation_item_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_profile_widget.dart' show CreateProfileWidget;

class CreateProfileModel extends FlutterFlowModel<CreateProfileWidget> {
  ///  Local state fields for this page.

  bool isPasswordValid = false;

  bool isEmailvalid = true;

  bool firsthasValue = false;

  bool lasthasValue = false;

  bool isFocusOnPassword = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for FirstNameTextField widget.
  FocusNode? firstNameTextFieldFocusNode;
  TextEditingController? firstNameTextFieldTextController;
  String? Function(BuildContext, String?)?
      firstNameTextFieldTextControllerValidator;
  // State field(s) for LastNameTextField widget.
  FocusNode? lastNameTextFieldFocusNode;
  TextEditingController? lastNameTextFieldTextController;
  String? Function(BuildContext, String?)?
      lastNameTextFieldTextControllerValidator;
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
  // Model for PasswordValidation_Item component.
  late PasswordValidationItemModel passwordValidationItemModel1;
  // Model for PasswordValidation_Item component.
  late PasswordValidationItemModel passwordValidationItemModel2;
  // Model for PasswordValidation_Item component.
  late PasswordValidationItemModel passwordValidationItemModel3;
  // Model for PasswordValidation_Item component.
  late PasswordValidationItemModel passwordValidationItemModel4;
  // Model for PasswordValidation_Item component.
  late PasswordValidationItemModel passwordValidationItemModel5;
  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // Stores action output result for [Custom Action - insertProfileWithDebug] action in Button widget.
  String? register;

  @override
  void initState(BuildContext context) {
    passwordTextFieldVisibility = false;
    passwordValidationItemModel1 =
        createModel(context, PasswordValidationItemModel.new);
    passwordValidationItemModel2 =
        createModel(context, PasswordValidationItemModel.new);
    passwordValidationItemModel3 =
        createModel(context, PasswordValidationItemModel.new);
    passwordValidationItemModel4 =
        createModel(context, PasswordValidationItemModel.new);
    passwordValidationItemModel5 =
        createModel(context, PasswordValidationItemModel.new);
  }

  @override
  void dispose() {
    firstNameTextFieldFocusNode?.dispose();
    firstNameTextFieldTextController?.dispose();

    lastNameTextFieldFocusNode?.dispose();
    lastNameTextFieldTextController?.dispose();

    emailTextFieldFocusNode?.dispose();
    emailTextFieldTextController?.dispose();

    passwordTextFieldFocusNode?.dispose();
    passwordTextFieldTextController?.dispose();

    passwordValidationItemModel1.dispose();
    passwordValidationItemModel2.dispose();
    passwordValidationItemModel3.dispose();
    passwordValidationItemModel4.dispose();
    passwordValidationItemModel5.dispose();
  }
}
