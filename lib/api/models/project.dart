import '/utils/formatters.dart';

/// Project demand adapted from `feature/sync-from-shph-main` and verified
/// against the production web client's Projects store.
class ShphProject {
  const ShphProject({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.categoryName,
    this.client,
    this.clientName,
    this.isB2b = false,
    this.status = 'draft',
    this.estimatedBudgetMin,
    this.estimatedBudgetMax,
    this.estimatedHeadcount = 0,
    this.clientLat,
    this.clientLng,
    this.expiresAt,
    this.quotedAt,
    this.committedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.roleLines = const [],
  });

  factory ShphProject.fromJson(Map<String, dynamic> json) => ShphProject(
        id: Formatters.toNullableInt(json['id']) ?? 0,
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        category: Formatters.toNullableInt(json['category']) ?? 0,
        categoryName: json['category_name']?.toString(),
        client: Formatters.toNullableInt(json['client']),
        clientName: json['client_name']?.toString(),
        isB2b: json['is_b2b'] == true,
        status: json['status']?.toString() ?? 'draft',
        estimatedBudgetMin:
            Formatters.toNullableDouble(json['estimated_budget_min']),
        estimatedBudgetMax:
            Formatters.toNullableDouble(json['estimated_budget_max']),
        estimatedHeadcount:
            Formatters.toNullableInt(json['estimated_headcount']) ?? 0,
        clientLat: Formatters.toNullableDouble(json['client_lat']),
        clientLng: Formatters.toNullableDouble(json['client_lng']),
        expiresAt: json['expires_at']?.toString(),
        quotedAt: json['quoted_at']?.toString(),
        committedAt: json['committed_at']?.toString(),
        cancelledAt: json['cancelled_at']?.toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
        roleLines: Formatters.parseMapList(json['role_lines'])
            .map(ShphProjectRoleLine.fromJson)
            .toList(growable: false),
      );

  final int id;
  final String title;
  final String description;
  final int category;
  final String? categoryName;
  final int? client;
  final String? clientName;
  final bool isB2b;
  final String status;
  final double? estimatedBudgetMin;
  final double? estimatedBudgetMax;
  final int estimatedHeadcount;
  final double? clientLat;
  final double? clientLng;
  final String? expiresAt;
  final String? quotedAt;
  final String? committedAt;
  final String? cancelledAt;
  final String? createdAt;
  final String? updatedAt;
  final List<ShphProjectRoleLine> roleLines;

  bool get isDraft => status == 'draft';
  bool get isQuoted => status == 'quoted';
  bool get isMatching => status == 'matching';
  bool get isCommitted => status == 'committed';
  bool get isCancelled => status == 'cancelled';
  bool get isExpired => status == 'expired';
  bool get isActive => !isCancelled && !isExpired;
}

class ShphProjectRoleLine {
  const ShphProjectRoleLine({
    required this.id,
    required this.roleLabel,
    required this.headcount,
    this.project,
    this.category,
    this.categoryName,
    this.estRateMin,
    this.estRateMax,
    this.estSubtotalMin,
    this.estSubtotalMax,
    this.prospects = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ShphProjectRoleLine.fromJson(Map<String, dynamic> json) =>
      ShphProjectRoleLine(
        id: Formatters.toNullableInt(json['id']) ?? 0,
        project: Formatters.toNullableInt(json['project']),
        category: Formatters.toNullableInt(json['category']),
        categoryName: json['category_name']?.toString(),
        roleLabel: json['role_label']?.toString() ?? '',
        headcount: Formatters.toNullableInt(json['headcount']) ?? 1,
        estRateMin: Formatters.toNullableDouble(json['est_rate_min']),
        estRateMax: Formatters.toNullableDouble(json['est_rate_max']),
        estSubtotalMin: Formatters.toNullableDouble(json['est_subtotal_min']),
        estSubtotalMax: Formatters.toNullableDouble(json['est_subtotal_max']),
        prospects: Formatters.parseMapList(json['prospects'])
            .map(ShphProjectProspect.fromJson)
            .toList(growable: false),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );

  final int id;
  final int? project;
  final int? category;
  final String? categoryName;
  final String roleLabel;
  final int headcount;
  final double? estRateMin;
  final double? estRateMax;
  final double? estSubtotalMin;
  final double? estSubtotalMax;
  final List<ShphProjectProspect> prospects;
  final String? createdAt;
  final String? updatedAt;
}

class ShphProjectProspect {
  const ShphProjectProspect({
    required this.id,
    required this.provider,
    this.providerName,
    this.roleLine,
    this.listing,
    this.listingTitle,
    this.score = 0,
    this.distanceKm,
    this.ratingSnapshot,
    this.completedJobsSnapshot = 0,
    this.status = 'pending',
    this.agreedPrice,
    this.booking,
    this.createdAt,
    this.updatedAt,
  });

  factory ShphProjectProspect.fromJson(Map<String, dynamic> json) =>
      ShphProjectProspect(
        id: Formatters.toNullableInt(json['id']) ?? 0,
        roleLine: Formatters.toNullableInt(json['role_line']),
        provider: Formatters.toNullableInt(json['provider']) ?? 0,
        providerName: json['provider_name']?.toString(),
        listing: Formatters.toNullableInt(json['listing']),
        listingTitle: json['listing_title']?.toString(),
        score: Formatters.toNullableDouble(json['score']) ?? 0,
        distanceKm: Formatters.toNullableDouble(json['distance_km']),
        ratingSnapshot: Formatters.toNullableDouble(json['rating_snapshot']),
        completedJobsSnapshot:
            Formatters.toNullableInt(json['completed_jobs_snapshot']) ?? 0,
        status: json['status']?.toString() ?? 'pending',
        agreedPrice: Formatters.toNullableDouble(json['agreed_price']),
        booking: Formatters.toNullableInt(json['booking']),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );

  final int id;
  final int? roleLine;
  final int provider;
  final String? providerName;
  final int? listing;
  final String? listingTitle;
  final double score;
  final double? distanceKm;
  final double? ratingSnapshot;
  final int completedJobsSnapshot;
  final String status;
  final double? agreedPrice;
  final int? booking;
  final String? createdAt;
  final String? updatedAt;

  bool get isPending => status == 'pending' || status == 'suggested';
  bool get isShortlisted => status == 'shortlisted';
  bool get isInvited => status == 'invited';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
}
