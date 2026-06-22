library;

enum DispatchStatus {
  searching,
  offered,
  assigned,
  completed,
  timedOut,
  cancelled;

  String get dbValue => name;

  static DispatchStatus fromDb(String value) =>
      DispatchStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => DispatchStatus.searching,
      );
}

enum OfferStatus {
  pending,
  accepted,
  rejected,
  timedOut;

  String get dbValue => name;

  static OfferStatus fromDb(String value) =>
      OfferStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => OfferStatus.pending,
      );
}

class DispatchJobRequest {
  const DispatchJobRequest({
    required this.id,
    required this.serviceType,
    required this.locationLat,
    required this.locationLng,
    required this.requestedTime,
    required this.status,
    required this.createdAt,
    this.clientId,
    this.assignedProviderId,
    this.bookingId,
  });

  factory DispatchJobRequest.fromJson(Map<String, dynamic> json) =>
      DispatchJobRequest(
        id: json['id'] as String,
        clientId: json['client_id'] as String?,
        serviceType: json['service_type'] as String,
        locationLat: (json['location_lat'] as num).toDouble(),
        locationLng: (json['location_lng'] as num).toDouble(),
        requestedTime: DateTime.parse(json['requested_time'] as String),
        status: DispatchStatus.fromDb(
          json['status'] as String? ?? 'searching',
        ),
        createdAt: DateTime.parse(json['created_at'] as String),
        assignedProviderId: json['assigned_provider_id'] as String?,
        bookingId: json['booking_id'] as String?,
      );

  final String id;
  final String? clientId;
  final String serviceType;
  final double locationLat;
  final double locationLng;
  final DateTime requestedTime;
  final DispatchStatus status;
  final DateTime createdAt;
  final String? assignedProviderId;
  final String? bookingId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_id': clientId,
        'service_type': serviceType,
        'location_lat': locationLat,
        'location_lng': locationLng,
        'requested_time': requestedTime.toIso8601String(),
        'status': status.dbValue,
        'created_at': createdAt.toIso8601String(),
        'assigned_provider_id': assignedProviderId,
        'booking_id': bookingId,
      };
}

class DispatchOffer {
  const DispatchOffer({
    required this.id,
    required this.jobId,
    required this.providerId,
    required this.status,
    required this.offeredAt,
    this.respondedAt,
  });

  factory DispatchOffer.fromJson(Map<String, dynamic> json) => DispatchOffer(
        id: json['id'] as String,
        jobId: json['job_id'] as String,
        providerId: json['provider_id'] as String,
        status: OfferStatus.fromDb(json['status'] as String? ?? 'pending'),
        offeredAt: DateTime.parse(json['offered_at'] as String),
        respondedAt: json['responded_at'] != null
            ? DateTime.parse(json['responded_at'] as String)
            : null,
      );

  final String id;
  final String jobId;
  final String providerId;
  final OfferStatus status;
  final DateTime offeredAt;
  final DateTime? respondedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'job_id': jobId,
        'provider_id': providerId,
        'status': status.dbValue,
        'offered_at': offeredAt.toIso8601String(),
        'responded_at': respondedAt?.toIso8601String(),
      };
}

class ClientJobView {
  const ClientJobView({
    required this.job,
    this.offer,
    this.providerProfile,
  });

  final DispatchJobRequest job;
  final DispatchOffer? offer;
  final Map<String, dynamic>? providerProfile;
}

class ProviderOfferView {
  const ProviderOfferView({
    required this.offer,
    required this.job,
    this.clientDisplayName,
  });

  final DispatchOffer offer;
  final DispatchJobRequest job;
  final String? clientDisplayName;
}
