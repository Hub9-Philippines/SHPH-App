import '/utils/formatters.dart';

/// Group-Demand ROOM (SHPH-133): N participants → 1 shared slot → N settlements.
///
/// Mirrors `shph-api/services/serializers.py::RoomSerializer`.
/// Note: `id` is a 24-char ObjectId string (same as ServiceBooking).
class ShphRoom {
  const ShphRoom({
    required this.id,
    required this.title,
    required this.category,
    required this.headsRequired,
    required this.pricePerHead,
    required this.eventDate,
    required this.eventTime,
    this.organizer,
    this.organizerName,
    this.categoryName,
    this.hostListing,
    this.description = '',
    this.menuOrService = '',
    this.eventLocation = '',
    this.latitude,
    this.longitude,
    this.radiusKm = 4,
    this.feeBreakdown = const {},
    this.joinToken,
    this.status = 'open',
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.lockedAt,
    this.settledAt,
    this.seatsRemaining = 0,
    this.isFull = false,
    this.participants = const [],
  });

  factory ShphRoom.fromJson(Map<String, dynamic> json) => ShphRoom(
        id: json['id']?.toString() ?? '',
        organizer: json['organizer'] as int?,
        organizerName: json['organizer_name'] as String?,
        category: json['category'] as int? ?? 0,
        categoryName: json['category_name'] as String?,
        hostListing: json['host_listing'] as int?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        menuOrService: json['menu_or_service'] as String? ?? '',
        eventDate: json['event_date'] as String? ?? '',
        eventTime: json['event_time'] as String? ?? '',
        eventLocation: json['event_location'] as String? ?? '',
        latitude: Formatters.toNullableDouble(json['latitude']),
        longitude: Formatters.toNullableDouble(json['longitude']),
        radiusKm: json['radius_km'] as int? ?? 4,
        headsRequired: json['heads_required'] as int? ?? 0,
        pricePerHead: Formatters.toNullableDouble(json['price_per_head']) ?? 0,
        feeBreakdown: _map(json['fee_breakdown']),
        joinToken: json['join_token'] as String?,
        status: json['status'] as String? ?? 'open',
        expiresAt: json['expires_at'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        lockedAt: json['locked_at'] as String?,
        settledAt: json['settled_at'] as String?,
        seatsRemaining: json['seats_remaining'] as int? ?? 0,
        isFull: json['is_full'] as bool? ?? false,
        participants: _participants(json['participants']),
      );

  final String id;
  final int? organizer;
  final String? organizerName;
  final int category;
  final String? categoryName;
  final int? hostListing;
  final String title;
  final String description;
  final String menuOrService;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final double? latitude;
  final double? longitude;
  final int radiusKm;
  final int headsRequired;
  final double pricePerHead;
  final Map<String, dynamic> feeBreakdown;
  final String? joinToken;
  final String status;
  final String? expiresAt;
  final String? createdAt;
  final String? updatedAt;
  final String? lockedAt;
  final String? settledAt;
  final int seatsRemaining;
  final bool isFull;
  final List<ShphRoomParticipant> participants;

  bool get isOpen => status == 'open';
  bool get isLocked => status == 'locked';
  bool get isSettled => status == 'settled';
  bool get isCancelled => status == 'cancelled';
  bool get isExpired => status == 'expired';
  bool get canJoin => isOpen && !isFull;

  static List<ShphRoomParticipant> _participants(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ShphRoomParticipant.fromJson)
        .toList();
  }

  static Map<String, dynamic> _map(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    return const {};
  }
}

/// Through model linking users to a Room with their role and settlement state.
class ShphRoomParticipant {
  const ShphRoomParticipant({
    required this.id,
    required this.user,
    this.userDisplayName,
    this.role = 'joiner',
    this.status = 'joined',
    this.booking,
    this.joinedAt,
    this.paidAt,
    this.cancelledAt,
  });

  factory ShphRoomParticipant.fromJson(Map<String, dynamic> json) =>
      ShphRoomParticipant(
        id: json['id'] as int? ?? 0,
        user: json['user'] as int? ?? 0,
        userDisplayName: json['user_display_name'] as String?,
        role: json['role'] as String? ?? 'joiner',
        status: json['status'] as String? ?? 'joined',
        booking: json['booking'] as int?,
        joinedAt: json['joined_at'] as String?,
        paidAt: json['paid_at'] as String?,
        cancelledAt: json['cancelled_at'] as String?,
      );

  final int id;
  final int user;
  final String? userDisplayName;
  final String role;
  final String status;
  final int? booking;
  final String? joinedAt;
  final String? paidAt;
  final String? cancelledAt;

  bool get isOrganizer => role == 'organizer';
  bool get isHostProvider => role == 'host_provider';
  bool get isJoiner => role == 'joiner';
  bool get hasJoined => status == 'joined';
  bool get hasPaid => status == 'paid';
  bool get isSettled => status == 'settled';
  bool get isCancelled => status == 'cancelled';
}
