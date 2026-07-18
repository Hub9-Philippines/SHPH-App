/// Dispute model.
class Dispute {
  const Dispute({
    required this.id,
    required this.bookingId,
    required this.reason,
    required this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.adminNotes,
    this.evidence,
    this.clientName,
    this.providerName,
    this.serviceName,
    this.booking,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) => Dispute(
        id: json['id']?.toString() ?? '',
        bookingId:
            json['booking']?.toString() ?? json['booking_id']?.toString() ?? '',
        reason: json['reason'] as String? ?? '',
        description: json['description'] as String? ?? '',
        status: json['status'] as String? ?? 'open',
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        adminNotes: json['admin_notes'] as String?,
        evidence: json['evidence'] as String?,
        clientName: json['client_name'] as String?,
        providerName: json['provider_name'] as String?,
        serviceName: json['service_name'] as String?,
        booking: json['booking_details'] as Map<String, dynamic>?,
      );

  final String id;
  final String bookingId;
  final String reason;
  final String description;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final String? adminNotes;
  final String? evidence;
  final String? clientName;
  final String? providerName;
  final String? serviceName;
  final Map<String, dynamic>? booking;
}
