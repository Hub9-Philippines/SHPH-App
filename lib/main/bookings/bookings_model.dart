import 'package:flutter/material.dart';

import '/backend/supabase/database/tables/service_listings.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/bookings_service.dart';
import '/services/logging_service.dart';
import '/services/service_listing_service.dart';
import 'bookings_widget.dart' show BookingsWidget;

/// Filter chips shown above the bookings list.
enum BookingsFilter { all, pending, completed, canceled }

class BookingItem {
  BookingItem({
    required this.id,
    required this.serviceListingId,
    required this.status,
    required this.title,
    required this.serviceType,
    required this.date,
    required this.scheduledExecutionDate,
    required this.price,
    required this.imageUrl,
    this.providerName,
  });
  final String id;
  final int serviceListingId;
  final String status;
  final String title;
  final String serviceType;
  final String date;
  final DateTime? scheduledExecutionDate;
  final double price;
  final String imageUrl;
  final String? providerName;
}

class BookingsModel extends FlutterFlowModel<BookingsWidget> {
  // --- FILTER / SEARCH STATE ---
  BookingsFilter selectedFilter = BookingsFilter.all;
  String searchQuery = '';

  // --- DATA LIST ---
  List<BookingItem> bookings = [];

  // --- LOADING STATES ---
  bool isLoading = true;
  String? errorMessage;

  // Callback for widget rebuild
  VoidCallback? onStateChanged;

  // Store service listings data
  final Map<int, ServiceListingsRow> _serviceListingsCache = {};

  /// Bookings scoped by the active chip and narrowed by the search query
  /// (service title or provider name match).
  List<BookingItem> get filteredBookings {
    final query = searchQuery.trim().toLowerCase();
    return bookings.where((item) {
      if (!_matchesFilter(item.status)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return item.title.toLowerCase().contains(query) ||
          (item.providerName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  bool _matchesFilter(String status) {
    switch (selectedFilter) {
      case BookingsFilter.all:
        return true;
      case BookingsFilter.pending:
        // Any non-terminal state is still "pending" user-side.
        return status.toLowerCase() != 'completed' &&
            status.toLowerCase() != 'cancelled';
      case BookingsFilter.completed:
        return status.toLowerCase() == 'completed';
      case BookingsFilter.canceled:
        return status.toLowerCase() == 'cancelled';
    }
  }

  /// Context-aware empty-state copy: the active chip decides the pair; an
  /// active search query takes precedence with its own no-match variant.
  (String heading, String description) emptyStateCopy({
    required bool hasSearchQuery,
  }) {
    if (hasSearchQuery) {
      return (
        'No bookings matched',
        'Try another keyword or switch the status filter.',
      );
    }
    switch (selectedFilter) {
      case BookingsFilter.all:
        return (
          'No bookings found',
          "You haven't scheduled any services yet. Find a pro to get started!",
        );
      case BookingsFilter.pending:
        return (
          'No pending jobs',
          'Any service requests waiting for provider approval will appear here.',
        );
      case BookingsFilter.completed:
        return (
          'No completed visits yet',
          'Once a service technician finishes a job, your history will show up here.',
        );
      case BookingsFilter.canceled:
        return (
          'No canceled bookings',
          "Great! You don't have any canceled or interrupted service requests.",
        );
    }
  }

  void setFilter(BookingsFilter filter) {
    selectedFilter = filter;
    onStateChanged?.call();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    onStateChanged?.call();
  }

  @override
  void initState(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  Future<void> reloadBookings() => _loadBookings();

  Future<void> _loadBookings() async {
    try {
      final rows = await BookingsService.instance.getUserBookings();

      final serviceIds =
          rows.map((b) => b.serviceListingId).where((id) => id > 0).toSet();
      if (serviceIds.isNotEmpty) {
        try {
          for (final id in serviceIds) {
            final listing = await ServiceListingService.instance
                .fetchServiceListingById(id);
            if (listing != null) {
              _serviceListingsCache[id] = ServiceListingsRow({
                'id': listing.id,
                'category': listing.category,
                'category_name': listing.categoryName,
                'provider': listing.provider,
                'provider_name': listing.providerName,
                'provider_photo': listing.providerPhoto,
                'title': listing.title,
                'description': listing.description,
                'base_price': listing.basePrice,
                'price_unit': listing.priceUnit,
                'status': listing.status,
                'is_available': listing.isAvailable ?? 'true',
                'rating': listing.rating,
                'thumbnail': listing.thumbnail,
                'review_count': listing.reviewCount ?? 0,
                'is_time_material': listing.isTimeMaterial,
              });
            }
          }
        } catch (e) {
          LoggingService.error(
            'Error fetching service listings for bookings',
            tag: 'BookingsModel',
            error: e,
          );
        }
      }

      final items = <BookingItem>[];
      for (final booking in rows) {
        final serviceListing = _serviceListingsCache[booking.serviceListingId];
        items.add(
          BookingItem(
            id: booking.id,
            serviceListingId: booking.serviceListingId,
            status: _formatStatus(booking.status),
            title: serviceListing?.title ?? 'Unknown Service',
            serviceType: serviceListing?.categoryName ?? 'Service',
            date: _formatDate(booking.bookingDate),
            scheduledExecutionDate: booking.bookingDate,
            price: booking.totalPrice ?? 0.0,
            imageUrl: serviceListing?.thumbnail ?? '',
            providerName: serviceListing?.providerName,
          ),
        );
      }

      bookings = items;
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
  void dispose() {}
}
