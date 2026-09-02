import 'package:flutter/material.dart';

import '/backend/supabase/database/tables/service_listings.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
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

  // Localization
  AppLocalizations? _l10n;

  void setLocalization(AppLocalizations l10n) {
    _l10n = l10n;
  }

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
    AppLocalizations? l10n,
  }) {
    final loc = l10n ?? _l10n;
    if (hasSearchQuery) {
      return (
        loc?.bkEmptySearchTitle ?? 'No bookings matched',
        loc?.bkEmptySearchDesc ?? 'Try another keyword or switch the status filter.',
      );
    }
    switch (selectedFilter) {
      case BookingsFilter.all:
        return (
          loc?.bkEmptyAllTitle ?? 'No bookings found',
          loc?.bkEmptyAllDesc ?? "You haven't scheduled any services yet. Find a pro to get started!",
        );
      case BookingsFilter.pending:
        return (
          loc?.bkEmptyPendingTitle ?? 'No pending jobs',
          loc?.bkEmptyPendingDesc ?? 'Any service requests waiting for provider approval will appear here.',
        );
      case BookingsFilter.completed:
        return (
          loc?.bkEmptyCompletedTitle ?? 'No completed visits yet',
          loc?.bkEmptyCompletedDesc ?? 'Once a service technician finishes a job, your history will show up here.',
        );
      case BookingsFilter.canceled:
        return (
          loc?.bkEmptyCanceledTitle ?? 'No canceled bookings',
          loc?.bkEmptyCanceledDesc ?? "Great! You don't have any canceled or interrupted service requests.",
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
            title: serviceListing?.title ??
                (_l10n?.bkFallbackUnknownService ?? 'Unknown Service'),
            serviceType: serviceListing?.categoryName ??
                (_l10n?.bkFallbackService ?? 'Service'),
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
      errorMessage = _l10n?.ehGenericError ?? 'Something went wrong. Please try again.';
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
      return _l10n?.bkStatusUnknown ?? 'Unknown';
    }
    switch (status.toLowerCase()) {
      case 'pending':
        return _l10n?.bkStatusPending ?? 'Pending';
      case 'confirmed':
        return _l10n?.bkStatusConfirmed ?? 'Confirmed';
      case 'in_progress':
        return _l10n?.bkStatusInProgress ?? 'In Progress';
      case 'completed':
        return _l10n?.bkStatusCompleted ?? 'Completed';
      case 'cancelled':
        return _l10n?.bkStatusCancelled ?? 'Cancelled';
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
