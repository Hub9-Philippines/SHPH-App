import 'package:flutter/material.dart';

import '/components/back_button/back_button_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'favorites_widget.dart' show FavoritesWidget;

class FavoritesModel extends FlutterFlowModel<FavoritesWidget> {
  ///  State fields for stateful widgets in this page.

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late BackButtonModel backButtonModel;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    backButtonModel.dispose();
  }
}
