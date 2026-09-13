import 'package:flutter/material.dart';

enum BookingUrgency { rightNow, laterToday, scheduled }

enum ServiceType { standard, deep, premium }

enum BookingPaymentMethod { gcash, maya, card, qrPh, cod }

double? bookingNumber(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

/// Checkout step labels for the confirm-booking progress spine.
const List<String> kCheckoutSteps = ['Services', 'Location', 'Payment'];

@immutable
class BookingAddress {
  const BookingAddress({
    required this.label,
    required this.line1,
    required this.city,
    this.instructions,
  });

  final String label;
  final String line1;
  final String city;
  final String? instructions;
}

@immutable
class BookingDraft {
  const BookingDraft({
    required this.urgency,
    required this.rooms,
    required this.cleaningType,
    required this.paymentMethod,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.serviceListingId,
    this.serviceTitle,
    this.serviceCategoryName,
    this.serviceCategoryId,
    this.serviceDescription,
    this.serviceImageUrl,
    this.serviceBasePrice,
    this.servicePriceUnit,
    this.scheduledDate,
    this.scheduledTime,
    this.liveSearchToken,
    this.reservationToken,
    this.landmarks = '',
    this.requireArrivalCode = true,
  });

  final int? serviceListingId;
  final String? serviceTitle;
  final String? serviceCategoryName;
  final int? serviceCategoryId;
  final String? serviceDescription;
  final String? serviceImageUrl;
  final double? serviceBasePrice;
  final String? servicePriceUnit;
  final BookingUrgency urgency;
  final int rooms;
  final ServiceType cleaningType;
  final BookingPaymentMethod paymentMethod;
  final BookingAddress address;
  final double latitude;
  final double longitude;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;
  final String? liveSearchToken;
  final String? reservationToken;

  /// Optional building/room/floor/landmark context for the provider.
  final String landmarks;

  /// Client preference: require a start PIN before work begins.
  final bool requireArrivalCode;

  BookingDraft copyWith({
    int? serviceListingId,
    String? serviceTitle,
    String? serviceCategoryName,
    int? serviceCategoryId,
    String? serviceDescription,
    String? serviceImageUrl,
    double? serviceBasePrice,
    String? servicePriceUnit,
    BookingUrgency? urgency,
    int? rooms,
    ServiceType? cleaningType,
    BookingPaymentMethod? paymentMethod,
    BookingAddress? address,
    double? latitude,
    double? longitude,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    String? liveSearchToken,
    String? reservationToken,
    String? landmarks,
    bool? requireArrivalCode,
  }) =>
      BookingDraft(
        serviceListingId: serviceListingId ?? this.serviceListingId,
        serviceTitle: serviceTitle ?? this.serviceTitle,
        serviceCategoryName: serviceCategoryName ?? this.serviceCategoryName,
        serviceCategoryId: serviceCategoryId ?? this.serviceCategoryId,
        serviceDescription: serviceDescription ?? this.serviceDescription,
        serviceImageUrl: serviceImageUrl ?? this.serviceImageUrl,
        serviceBasePrice: serviceBasePrice ?? this.serviceBasePrice,
        servicePriceUnit: servicePriceUnit ?? this.servicePriceUnit,
        urgency: urgency ?? this.urgency,
        rooms: rooms ?? this.rooms,
        cleaningType: cleaningType ?? this.cleaningType,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        address: address ?? this.address,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        liveSearchToken: liveSearchToken ?? this.liveSearchToken,
        reservationToken: reservationToken ?? this.reservationToken,
        landmarks: landmarks ?? this.landmarks,
        requireArrivalCode: requireArrivalCode ?? this.requireArrivalCode,
      );
}

@immutable
class BookingQuote {
  const BookingQuote({
    required this.basePrice,
    this.roomSubtotal = 0,
    this.cleaningTypeAdjustment = 0,
    this.urgencyAdjustment = 0,
    this.timePremium = 0,
    this.platformFee = 0,
    this.vat = 0,
    this.platformFeePercent,
    this.vatPercent,
    required this.total,
  });

  final double basePrice;
  final double roomSubtotal;
  final double cleaningTypeAdjustment;
  final double urgencyAdjustment;
  final double timePremium;
  final double platformFee;
  final double vat;
  final String? platformFeePercent;
  final String? vatPercent;
  final double total;

  factory BookingQuote.fromApi(Map<String, dynamic> json) {
    final basePrice = bookingNumber(json['base_price']);
    final total = bookingNumber(json['total']);
    if (basePrice == null || total == null) {
      throw const FormatException('Booking estimate is missing a price');
    }
    return BookingQuote(
      basePrice: basePrice,
      timePremium: bookingNumber(json['time_premium']) ?? 0,
      platformFee: bookingNumber(json['platform_fee']) ?? 0,
      vat: bookingNumber(json['vat']) ?? 0,
      platformFeePercent: json['platform_fee_percent']?.toString(),
      vatPercent: json['vat_percent']?.toString(),
      total: total,
    );
  }
}

String serviceDisplayTitle(BookingDraft draft) =>
    draft.serviceTitle ?? 'Choose a service';

String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minuteText = time.minute.toString().padLeft(2, '0');
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minuteText $suffix';
}
