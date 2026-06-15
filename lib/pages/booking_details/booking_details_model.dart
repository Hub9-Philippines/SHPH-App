import 'package:flutter/material.dart';

import '/backend/supabase/database/tables/bookings.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'booking_details_widget.dart' show BookingDetailsWidget;

class BookingDetailsModel extends FlutterFlowModel<BookingDetailsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for backButton component.
  late BackButtonModel backButtonModel;

  // State fields
  bool isLoading = true;
  String? errorMessage;
  BookingsRow? booking;
  Map<String, dynamic>? serviceListing;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    backButtonModel.dispose();
  }
}
