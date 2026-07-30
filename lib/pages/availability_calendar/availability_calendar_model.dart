import 'package:flutter/material.dart';

import '/services/availability_service.dart';
import '/services/logging_service.dart';

class AvailabilityCalendarModel {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> slots = [];
  bool isLoading = false;

  Future<void> loadSlots({String? providerId}) async {
    isLoading = true;
    try {
      final dateStr =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      slots = await AvailabilityService.instance.getSlots(
        providerId: providerId,
        date: dateStr,
      );
    } catch (e) {
      LoggingService.error('Error loading slots: $e',
          tag: 'AvailabilityCalendarModel');
    } finally {
      isLoading = false;
    }
  }

  Future<bool> addSlot({
    required String startTime,
    required String endTime,
  }) async {
    try {
      final dateStr =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      final result = await AvailabilityService.instance.createSlot(
        date: dateStr,
        startTime: startTime,
        endTime: endTime,
      );
      if (result != null) {
        await loadSlots();
        return true;
      }
      return false;
    } catch (e) {
      LoggingService.error('Error adding slot: $e',
          tag: 'AvailabilityCalendarModel');
      return false;
    }
  }

  Future<bool> removeSlot(String slotId) async {
    try {
      final success = await AvailabilityService.instance.deleteSlot(slotId);
      if (success) {
        await loadSlots();
        return true;
      }
      return false;
    } catch (e) {
      LoggingService.error('Error removing slot: $e',
          tag: 'AvailabilityCalendarModel');
      return false;
    }
  }

  void goToNextMonth() {
    selectedDate = DateTime(selectedDate.year, selectedDate.month + 1);
  }

  void goToPreviousMonth() {
    selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
  }

  void selectDate(DateTime date) {
    selectedDate = date;
  }

  void dispose() {}
}
