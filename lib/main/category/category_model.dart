import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '../../components/categories_widget/categories_widget.dart';
import 'category_widget.dart' show CategoryWidget;

class CategoryModel extends FlutterFlowModel<CategoryWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for categoriesWidget component.
  late CategoriesWidgetModel categoriesWidgetModel;

  @override
  void initState(BuildContext context) {
    categoriesWidgetModel = createModel(context, CategoriesWidgetModel.new);
  }

  @override
  void dispose() {
    categoriesWidgetModel.dispose();
  }
}
