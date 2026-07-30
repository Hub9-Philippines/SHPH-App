import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/rooms_service.dart';
import 'room_create_widget.dart' show RoomCreateWidget;

class RoomCreateModel extends FlutterFlowModel<RoomCreateWidget> {
  String title = '';
  String description = '';
  String menuOrService = '';
  String eventDate = '';
  String eventTime = '';
  String eventLocation = '';
  int headsRequired = 3;
  double pricePerHead = 100.0;
  int? category;
  bool isSubmitting = false;

  @override
  void initState(BuildContext context) {}

  Map<String, dynamic> toPayload() => {
        'title': title,
        'description': description,
        'menu_or_service': menuOrService,
        'event_date': eventDate,
        'event_time': eventTime,
        'event_location': eventLocation,
        'heads_required': headsRequired,
        'price_per_head': pricePerHead.toStringAsFixed(2),
        'category': category,
      };

  Future<Map<String, dynamic>?> submit() async {
    isSubmitting = true;
    try {
      return await RoomsService.instance.createRoom(toPayload());
    } finally {
      isSubmitting = false;
    }
  }

  @override
  void dispose() {}
}
