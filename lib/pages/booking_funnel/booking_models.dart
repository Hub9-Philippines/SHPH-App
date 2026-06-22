import 'package:flutter/material.dart';

enum BookingUrgency { rightNow, laterToday, scheduled }

enum ServiceType { standard, deep, premium }

enum BookingPaymentMethod { gcash, card, cod }

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
    this.serviceDescription,
    this.serviceImageUrl,
    this.serviceBasePrice,
    this.servicePriceUnit,
    this.scheduledDate,
    this.scheduledTime,
    this.liveSearchToken,
    this.reservationToken,
  });

  final int? serviceListingId;
  final String? serviceTitle;
  final String? serviceCategoryName;
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

  BookingDraft copyWith({
    int? serviceListingId,
    String? serviceTitle,
    String? serviceCategoryName,
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
  }) =>
      BookingDraft(
        serviceListingId: serviceListingId ?? this.serviceListingId,
        serviceTitle: serviceTitle ?? this.serviceTitle,
        serviceCategoryName: serviceCategoryName ?? this.serviceCategoryName,
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
      );
}

@immutable
class BookingQuote {
  const BookingQuote({
    required this.basePrice,
    required this.roomSubtotal,
    required this.cleaningTypeAdjustment,
    required this.urgencyAdjustment,
    required this.total,
  });

  final double basePrice;
  final double roomSubtotal;
  final double cleaningTypeAdjustment;
  final double urgencyAdjustment;
  final double total;
}

String serviceDisplayTitle(BookingDraft draft) =>
    draft.serviceTitle ?? 'Choose a service';

String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minuteText = time.minute.toString().padLeft(2, '0');
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minuteText $suffix';
}
