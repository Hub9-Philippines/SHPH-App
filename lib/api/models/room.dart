import '/utils/formatters.dart';

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
        organizer: Formatters.toNullableInt(json['organizer']),
        organizerName: json['organizer_name']?.toString(),
        category: Formatters.toNullableInt(json['category']) ?? 0,
        categoryName: json['category_name']?.toString(),
        hostListing: Formatters.toNullableInt(json['host_listing']),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        menuOrService: json['menu_or_service']?.toString() ?? '',
        eventDate: json['event_date']?.toString() ?? '',
        eventTime: json['event_time']?.toString() ?? '',
        eventLocation: json['event_location']?.toString() ?? '',
        latitude: Formatters.toNullableDouble(json['latitude']),
        longitude: Formatters.toNullableDouble(json['longitude']),
        radiusKm: Formatters.toNullableInt(json['radius_km']) ?? 4,
        headsRequired: Formatters.toNullableInt(json['heads_required']) ?? 0,
        pricePerHead: Formatters.toNullableDouble(json['price_per_head']) ?? 0,
        feeBreakdown: json['fee_breakdown'] is Map
            ? (json['fee_breakdown'] as Map).cast<String, dynamic>()
            : const {},
        joinToken: json['join_token']?.toString(),
        status: json['status']?.toString() ?? 'open',
        expiresAt: json['expires_at']?.toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
        lockedAt: json['locked_at']?.toString(),
        settledAt: json['settled_at']?.toString(),
        seatsRemaining: Formatters.toNullableInt(json['seats_remaining']) ?? 0,
        isFull: json['is_full'] == true,
        participants: Formatters.parseMapList(json['participants'])
            .map(ShphRoomParticipant.fromJson)
            .toList(growable: false),
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
  bool get canJoin => isOpen && !isFull && seatsRemaining > 0;
}

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
        id: Formatters.toNullableInt(json['id']) ?? 0,
        user: Formatters.toNullableInt(json['user']) ?? 0,
        userDisplayName: json['user_display_name']?.toString(),
        role: json['role']?.toString() ?? 'joiner',
        status: json['status']?.toString() ?? 'joined',
        booking: json['booking']?.toString(),
        joinedAt: json['joined_at']?.toString(),
        paidAt: json['paid_at']?.toString(),
        cancelledAt: json['cancelled_at']?.toString(),
      );

  final int id;
  final int user;
  final String? userDisplayName;
  final String role;
  final String status;
  final String? booking;
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
