import 'package:flutter/material.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'i_d_verify_widget.dart' show IDVerifyWidget;

class IDVerifyModel extends FlutterFlowModel<IDVerifyWidget> {
  ///  Local state fields for this page.

  List<String> scannedIDPath = [];
  void addToScannedIDPath(String item) => scannedIDPath.add(item);
  void removeFromScannedIDPath(String item) => scannedIDPath.remove(item);
  void removeAtIndexFromScannedIDPath(int index) =>
      scannedIDPath.removeAt(index);
  void insertAtIndexInScannedIDPath(int index, String item) =>
      scannedIDPath.insert(index, item);
  void updateScannedIDPathAtIndex(int index, Function(String) updateFn) =>
      scannedIDPath[index] = updateFn(scannedIDPath[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - scanDocument] action in Button widget.
  List<String>? scannedID;
  // Model for backButton component.
  late BackButtonModel backButtonModel;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    backButtonModel.dispose();
  }

  /// Action blocks.
  Future showScannedID(BuildContext context) async {}
}
