import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'contact_provider_widget.dart' show ContactProviderWidget;

class ContactProviderModel extends FlutterFlowModel<ContactProviderWidget> {
  ///  State fields for stateful widgets in this page.

  // State fields
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
  }
}
