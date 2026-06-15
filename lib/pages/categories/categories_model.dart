import 'package:flutter/material.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../components/categories_widget/categories_widget.dart';
import 'categories_widget.dart' show CategoriesWidget;

class CategoriesModel extends FlutterFlowModel<CategoriesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for categoriesWidget component.
  late CategoriesWidgetModel categoriesWidgetModel;
  // Model for backButton component.
  late BackButtonModel backButtonModel;

  @override
  void initState(BuildContext context) {
    categoriesWidgetModel = createModel(context, CategoriesWidgetModel.new);
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    categoriesWidgetModel.dispose();
    backButtonModel.dispose();
  }
}
