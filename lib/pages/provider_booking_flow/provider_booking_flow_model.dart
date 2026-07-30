import 'dart:async';

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/services/provider_bookings_service.dart';
import 'provider_booking_flow_widget.dart' show ProviderBookingFlowWidget;

class ProviderBookingFlowModel
    extends FlutterFlowModel<ProviderBookingFlowWidget> {
  Map<String, dynamic>? booking;
  bool isLoading = true;
  String? fetchError;
  bool transitioning = false;
  String step = 'accepted';
  int? jobStartTimeMs;
  int elapsedSeconds = 0;
  Timer? timer;

  @override
  void initState(BuildContext context) {}

  Future<void> loadBooking(String id) async {
    isLoading = true;
    fetchError = null;
    try {
      booking = await ProviderBookingsService.instance.getBooking(id);
      if (booking != null) {
        step = _statusToStep(booking!['status']?.toString() ?? '');
        if (step == 'in_progress') _startTimer();
      }
    } catch (e) {
      fetchError = 'Failed to load booking.';
    } finally {
      isLoading = false;
    }
  }

  Future<bool> updateStatus(String status, {String? pin}) async {
    if (transitioning) return false;
    transitioning = true;
    final id = booking?['id']?.toString();
    if (id == null) return false;
    try {
      final svc = ProviderBookingsService.instance;
      bool ok;
      switch (status) {
        case 'en_route':
          ok = await svc.acceptBooking(id);
          break;
        case 'arrived':
          ok = await svc.confirmArrival(id);
          break;
        case 'in_progress':
          ok = await svc.startService(id, pin: pin);
          break;
        case 'completed':
          ok = await svc.completeJob(id);
          break;
        default:
          ok = false;
      }
      if (ok) {
        step = status;
        booking = {...?booking, 'status': status};
        if (status == 'in_progress') _startTimer();
        if (status == 'completed') _stopTimer();
      }
      return ok;
    } finally {
      transitioning = false;
    }
  }

  Future<bool> updatePartsCost(double cost, String? description) async {
    final id = booking?['id']?.toString();
    if (id == null) return false;
    try {
      await ProviderBookingsService.instance
          .updateBooking(id, {'hardware_parts_cost': cost, 'hardware_parts_description': description ?? ''});
      booking = {...?booking, 'hardware_parts_cost': cost, 'hardware_parts_description': description};
      return true;
    } catch (e) {
      return false;
    }
  }

  String get elapsedDisplay {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    jobStartTimeMs = DateTime.now().millisecondsSinceEpoch;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (jobStartTimeMs != null) {
        elapsedSeconds =
            (DateTime.now().millisecondsSinceEpoch - jobStartTimeMs!) ~/ 1000;
      }
    });
  }

  void _stopTimer() {
    timer?.cancel();
    timer = null;
  }

  String _statusToStep(String status) {
    switch (status) {
      case 'confirmed':
      case 'accepted':
        return 'accepted';
      case 'en_route':
        return 'en_route';
      case 'arrived':
        return 'arrived';
      case 'in_progress':
        return 'in_progress';
      case 'completed':
        return 'completed';
      default:
        return 'accepted';
    }
  }

  @override
  void dispose() {
    _stopTimer();
  }
}
