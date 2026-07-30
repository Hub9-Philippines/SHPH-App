import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/ai_composer_service.dart';
import '/services/logging_service.dart';
import 'ai_booking_composer_widget.dart' show AiBookingComposerWidget;

class AiBookingComposerModel
    extends FlutterFlowModel<AiBookingComposerWidget> {
  final promptController = TextEditingController();
  bool isLoading = false;
  Map<String, String?>? bookingData;

  Future<void> composeBooking() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) return;

    isLoading = true;
    try {
      bookingData =
          await AIBookingComposerService.instance.composeBooking(prompt: prompt);
    } catch (e) {
      LoggingService.error('AI composer failed: $e', tag: 'AiBookingComposer');
    } finally {
      isLoading = false;
    }
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    promptController.dispose();
  }
}
