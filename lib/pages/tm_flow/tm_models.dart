import 'package:flutter/material.dart';

@immutable
class TMSubCategoryOption {
  const TMSubCategoryOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.estimateMin,
    required this.estimateMax,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final double estimateMin;
  final double estimateMax;

  String get estimateLabel =>
      'Php ${estimateMin.toStringAsFixed(0)}-${estimateMax.toStringAsFixed(0)}';
}

@immutable
class TMProviderProfile {
  const TMProviderProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.completedJobs,
    required this.etaMinutes,
    required this.vehicleLabel,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int completedJobs;
  final int etaMinutes;
  final String vehicleLabel;
  final double? latitude;
  final double? longitude;
}

@immutable
class TMHardwareRequest {
  const TMHardwareRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.additionalCost,
  });

  final String id;
  final String title;
  final String description;
  final double additionalCost;
}

@immutable
class TMBookingSnapshot {
  const TMBookingSnapshot({
    required this.requestId,
    required this.status,
    this.stage,
    this.dispatchMode,
    this.paymentStatus,
    this.totalPrice,
    this.provider,
    this.hardwareRequest,
  });

  final String requestId;
  final String status;
  final String? stage;
  final String? dispatchMode;
  final String? paymentStatus;
  final double? totalPrice;
  final TMProviderProfile? provider;
  final TMHardwareRequest? hardwareRequest;
}
