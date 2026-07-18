import 'package:flutter/material.dart';

import '/components/back_button/back_button_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'security_settings_widget.dart' show SecuritySettingsWidget;

class SecuritySettingsModel extends FlutterFlowModel<SecuritySettingsWidget> {
  ///  State fields for stateful widgets in this page.

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late BackButtonModel backButtonModel;

  // Password visibility toggles
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    backButtonModel.dispose();
  }
}
