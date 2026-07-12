import 'package:flutter/material.dart';

import '/backend/supabase/database/tables/addresses.dart';
import '/backend/supabase/database/tables/service_listings.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/bookings_service.dart';
import '/services/logging_service.dart';
import 'bookings_widget.dart' show BookingsWidget;

// 1. Define the model class here or in a separate file
class BookingItem {
  BookingItem({
    required this.id,
    required this.status,
    required this.title,
    required this.serviceType,
    required this.date,
    required this.scheduledExecutionDate,
    required this.price,
    required this.imageUrl,
    this.addressLabel,
    this.clientLatitude,
    this.clientLongitude,
  });
  final String id;
  final String status;
  final String title;
  final String serviceType;
  final String date;
  final DateTime? scheduledExecutionDate;
  final double price;
  final String imageUrl;
  final String? addressLabel;
  final double? clientLatitude;
  final double? clientLongitude;
}

class BookingsModel extends FlutterFlowModel<BookingsWidget> {
  // --- STATE FIELDS ---
  int? selectedTabIndex = 0;
  PageController? pageViewController;

  // --- DATA LISTS ---
  // These lists will hold your dynamic production data
  List<BookingItem> inProgressList = [];
  List<BookingItem> completedList = [];

  // --- LOADING STATES ---
  bool isLoading = true;
  String? errorMessage;

  // Callback for widget rebuild
  VoidCallback? onStateChanged;

  // Store service listings data
  final Map<int, ServiceListingsRow> _serviceListingsCache = {};

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  @override
  void initState(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  Future<void> reloadBookings() => _loadBookings();

  Future<void> _loadBookings() async {
    try {
      final bookings = await BookingsService.instance.getUserBookings();

      final serviceIds =
          bookings.map((b) => b.serviceListingId).where((id) => id > 0).toSet();
      if (serviceIds.isNotEmpty) {
        try {
          final services = await ServiceListingsTable().queryRows(
            queryFn: (q) => q.inFilter('id', serviceIds.toList()),
          );
          for (final service in services) {
            _serviceListingsCache[service.id] = service;
          }
        } catch (e) {
          LoggingService.error(
            'Error fetching service listings for bookings',
            tag: 'BookingsModel',
            error: e,
          );
        }
      }

      final addressIds =
          bookings.map((b) => b.addressId).where((id) => id != null).map((id) => id!).toSet();
      final Map<int, AddressesRow> addressCache = {};
      if (addressIds.isNotEmpty) {
        try {
          final addresses = await AddressesTable().queryRows(
            queryFn: (q) => q.inFilter('id', addressIds.toList()),
          );
          for (final addr in addresses) {
            addressCache[addr.id] = addr;
          }
        } catch (_) {}
      }

      final inProgress = <BookingItem>[];
      final completed = <BookingItem>[];

      for (final booking in bookings) {
        final serviceListing = _serviceListingsCache[booking.serviceListingId];
        final addr = booking.addressId != null
            ? addressCache[booking.addressId]
            : null;
        final addressLabel = addr != null
            ? '${addr.addressLine1 ?? ''}${addr.city != null && addr.city!.isNotEmpty ? ', ${addr.city}' : ''}'
            : null;
        final bookingItem = BookingItem(
          id: booking.id,
          status: _formatStatus(booking.status),
          title: serviceListing?.title ?? 'Unknown Service',
          serviceType: serviceListing?.categoryName ?? 'Service',
          date: _formatDate(booking.bookingDate),
          scheduledExecutionDate: booking.bookingDate,
          price: booking.totalPrice ?? 0.0,
          imageUrl: serviceListing?.thumbnail ?? '',
          addressLabel: addressLabel,
        );

        if (booking.status.toLowerCase() == 'completed' ||
            booking.status.toLowerCase() == 'cancelled') {
          completed.add(bookingItem);
        } else {
          inProgress.add(bookingItem);
        }
      }

      inProgressList = inProgress;
      completedList = completed;
      isLoading = false;
      onStateChanged?.call();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load bookings: $e';
      LoggingService.error(
        'Error loading bookings',
        tag: 'BookingsModel',
        error: e,
      );
      onStateChanged?.call();
    }
  }

  String _formatStatus(String? status) {
    if (status == null) {
      return 'Unknown';
    }
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'TBD';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    pageViewController?.dispose();
  }
}
