import 'package:flutter/material.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'booking_payment_widget.dart' show BookingPaymentWidget;

class BookingPaymentModel extends FlutterFlowModel<BookingPaymentWidget> {
  late BackButtonModel backButtonModel;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    backButtonModel.dispose();
  }
}
