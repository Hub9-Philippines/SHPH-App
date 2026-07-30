import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/subcategory_service.dart';
import 'subcategory_widget.dart' show SubcategoryWidget;

class SubcategoryModel extends FlutterFlowModel<SubcategoryWidget> {
  List<Map<String, dynamic>> subcategories = [];
  bool isLoading = true;

  @override
  void initState(BuildContext context) {}

  Future<void> loadSubcategories(int parentId) async {
    isLoading = true;
    try {
      subcategories = await SubcategoryService.instance
          .getSubcategories(parentId);
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {}
}
