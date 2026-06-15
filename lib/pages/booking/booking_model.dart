import 'package:flutter/material.dart';

import '/backend/supabase/database/tables/addresses.dart';
import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'booking_widget.dart' show BookingWidget;

class BookingModel extends FlutterFlowModel<BookingWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for backButton component.
  late BackButtonModel backButtonModel;

  // State fields
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TextEditingController notesController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  // Address selection
  AddressesRow? selectedAddress;

  @override
  void initState(BuildContext context) {
    backButtonModel = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    backButtonModel.dispose();
    notesController.dispose();
  }
}
