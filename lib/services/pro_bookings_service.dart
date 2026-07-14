import 'dart:convert';

import '/api/bridges/api_row_mapper.dart';
import '/api/resources/bookings_api.dart';
import '/api/resources/payouts_api.dart';
import '/services/logging_service.dart';

class ProBookingsService {
  ProBookingsService._();
  static final ProBookingsService instance = ProBookingsService._();
  static const _tmMetaPrefix = 'TM_META:';
  final _api = ShphBookingsApi.instance;

  bool isTimeMaterialBooking(Map<String, dynamic> booking) =>
      tmMetadata(booking)['flow'] == 'tm';

  Map<String, dynamic> tmMetadata(Map<String, dynamic> booking) {
    final notes = booking['notes'] as String?;
    if (notes == null || !notes.contains(_tmMetaPrefix)) return {};
    try {
      final value = jsonDecode(notes
          .substring(notes.indexOf(_tmMetaPrefix) + _tmMetaPrefix.length)
          .trim());
      return value is Map ? value.map((k, v) => MapEntry(k.toString(), v)) : {};
    } catch (_) {
      return {};
    }
  }

  String? tmSubCategoryTitle(Map<String, dynamic> booking) =>
      tmMetadata(booking)['sub_category_title'] as String?;
  String? tmStage(Map<String, dynamic> booking) =>
      tmMetadata(booking)['stage'] as String?;
  String tmStageLabel(Map<String, dynamic> booking) =>
      switch (tmStage(booking) ?? '') {
        'broadcast' => 'Awaiting provider',
        'matched' => 'Matched',
        'provider_accepted' => 'Accepted',
        'in_progress' => 'In progress',
        'hardware_pending' => 'Hardware pending',
        'hardware_approved' => 'Hardware approved',
        'completed' => 'Completed',
        'paid' => 'Paid',
        'rated' => 'Rated',
        _ => 'TM request',
      };

  Future<List<Map<String, dynamic>>> _bookings() async =>
      (await _api.listBookings())
          .results
          .map((b) => ApiRowMapper.bookingToRow(b).data)
          .toList();

  Future<List<Map<String, dynamic>>> getPendingJobRequests() =>
      _filtered({'pending'});
  Future<List<Map<String, dynamic>>> getScheduledJobs() =>
      _filtered({'accepted', 'confirmed', 'in_progress', 'completed'});

  Future<List<Map<String, dynamic>>> _filtered(Set<String> statuses) async {
    try {
      return (await _bookings())
          .where((b) => statuses.contains(b['status']))
          .toList();
    } catch (e) {
      LoggingService.error('API provider bookings failed: $e',
          tag: 'ProBookingsService');
      return [];
    }
  }

  Future<Map<String, dynamic>> getEarningsSummary() async {
    try {
      final data = await ShphPayoutsApi.instance.getEarningsSummary();
      num number(String snake, String camel) =>
          (data[snake] ?? data[camel] ?? 0) as num;
      return {
        'totalEarnings': number('total_earned', 'totalEarnings').toDouble(),
        'thisMonth': number('this_month', 'thisMonth').toDouble(),
        'lastMonth': number('last_month', 'lastMonth').toDouble(),
        'thisWeek': number('this_week', 'thisWeek').toDouble(),
        'lastWeek': number('last_week', 'lastWeek').toDouble(),
        'totalJobs': data['total_jobs'] ?? data['totalJobs'] ?? 0,
        'weeklyData': data['weekly_data'] ?? data['weeklyData'] ?? [],
        'recentTransactions':
            data['recent_transactions'] ?? data['recentTransactions'] ?? [],
      };
    } catch (e) {
      LoggingService.error('API earnings failed: $e',
          tag: 'ProBookingsService');
      return {
        'totalEarnings': 0.0,
        'thisMonth': 0.0,
        'lastMonth': 0.0,
        'thisWeek': 0.0,
        'lastWeek': 0.0,
        'totalJobs': 0,
        'weeklyData': [],
        'recentTransactions': []
      };
    }
  }

  Future<bool> acceptJob(String bookingId) =>
      _run(() => _api.acceptBooking(bookingId), 'accept job');
  Future<bool> rejectJob(String bookingId, {String? reason}) =>
      _run(() => _api.rejectBooking(bookingId, reason: reason), 'reject job');
  Future<bool> completeJob(String bookingId) => _run(() async {
        await _api.updateBooking(bookingId, data: {'status': 'completed'});
      }, 'complete job');

  Future<bool> markJobInProgress(String bookingId) =>
      _updateBookingAndTmMetadata(bookingId,
          status: 'in_progress',
          metadataUpdates: {'flow': 'tm', 'stage': 'in_progress'});

  Future<bool> requestTMHardware({
    required String bookingId,
    required String title,
    required String description,
    required double additionalCost,
  }) =>
      _updateBookingAndTmMetadata(
        bookingId,
        status: 'in_progress',
        extraData: {'hardware_parts_cost': additionalCost},
        metadataUpdates: {
          'flow': 'tm',
          'stage': 'hardware_pending',
          'hardware_request': {
            'id': 'provider-${DateTime.now().millisecondsSinceEpoch}',
            'title': title,
            'description': description,
            'additional_cost': additionalCost
          },
        },
      );

  Future<Map<String, int>> getBookingCounts() async {
    try {
      final bookings = await _bookings();
      int count(Set<String> values) =>
          bookings.where((b) => values.contains(b['status'])).length;
      return {
        'pending': count({'pending'}),
        'accepted': count({'accepted', 'confirmed', 'in_progress'}),
        'completed': count({'completed'}),
        'total': bookings.length
      };
    } catch (e) {
      LoggingService.error('API booking counts failed: $e',
          tag: 'ProBookingsService');
      return {'pending': 0, 'accepted': 0, 'completed': 0, 'total': 0};
    }
  }

  Future<bool> _updateBookingAndTmMetadata(
    String bookingId, {
    String? status,
    Map<String, dynamic>? extraData,
    Map<String, dynamic>? metadataUpdates,
  }) async {
    try {
      final current = await _api.getBooking(bookingId);
      final notes = metadataUpdates == null
          ? current.notes
          : _mergeTmMetadata(current.notes, metadataUpdates);
      await _api.updateBooking(bookingId, data: {
        if (status != null) 'status': status,
        if (extraData != null) ...extraData,
        if (notes != null) 'notes': notes,
      });
      return true;
    } catch (e) {
      LoggingService.error('API TM booking update failed: $e',
          tag: 'ProBookingsService');
      return false;
    }
  }

  String _mergeTmMetadata(String? notes, Map<String, dynamic> updates) {
    final raw = notes ?? '';
    final index = raw.indexOf(_tmMetaPrefix);
    final text = (index >= 0 ? raw.substring(0, index) : raw).trimRight();
    final current = tmMetadata({'notes': notes})..addAll(updates);
    return '${text.isEmpty ? '' : '$text\n'}$_tmMetaPrefix${jsonEncode(current)}';
  }

  Future<bool> _run(Future<void> Function() action, String label) async {
    try {
      await action();
      return true;
    } catch (e) {
      LoggingService.error('API $label failed: $e', tag: 'ProBookingsService');
      return false;
    }
  }
}
