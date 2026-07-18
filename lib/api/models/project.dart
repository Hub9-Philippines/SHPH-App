/// Project Demand (SHPH-134): smart time-frame demand for B2B/project work.
///
/// Mirrors `shph-api/projects/serializers.py::ProjectDemandSerializer`.
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
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: json['category'] as int? ?? 0,
        categoryName: json['category_name'] as String?,
        client: json['client'] as int?,
        clientName: json['client_name'] as String?,
        isB2b: json['is_b2b'] as bool? ?? false,
        status: json['status'] as String? ?? 'draft',
        estimatedBudgetMin: _toDouble(json['estimated_budget_min']),
        estimatedBudgetMax: _toDouble(json['estimated_budget_max']),
        estimatedHeadcount: json['estimated_headcount'] as int? ?? 0,
        clientLat: _toDouble(json['client_lat']),
        clientLng: _toDouble(json['client_lng']),
        expiresAt: json['expires_at'] as String?,
        quotedAt: json['quoted_at'] as String?,
        committedAt: json['committed_at'] as String?,
        cancelledAt: json['cancelled_at'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        roleLines: _roleLines(json['role_lines']),
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

  static List<ShphProjectRoleLine> _roleLines(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ShphProjectRoleLine.fromJson)
        .toList();
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

/// A single role within a project demand (e.g. "3 masonry workers").
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
        id: json['id'] as int? ?? 0,
        project: json['project'] as int?,
        category: json['category'] as int?,
        categoryName: json['category_name'] as String?,
        roleLabel: json['role_label'] as String? ?? '',
        headcount: json['headcount'] as int? ?? 1,
        estRateMin: _toDouble(json['est_rate_min']),
        estRateMax: _toDouble(json['est_rate_max']),
        estSubtotalMin: _toDouble(json['est_subtotal_min']),
        estSubtotalMax: _toDouble(json['est_subtotal_max']),
        prospects: _prospects(json['prospects']),
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
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

  static List<ShphProjectProspect> _prospects(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ShphProjectProspect.fromJson)
        .toList();
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

/// A ranked provider candidate for a role line.
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
    this.status = 'suggested',
    this.agreedPrice,
    this.booking,
    this.createdAt,
    this.updatedAt,
  });

  factory ShphProjectProspect.fromJson(Map<String, dynamic> json) =>
      ShphProjectProspect(
        id: json['id'] as int? ?? 0,
        roleLine: json['role_line'] as int?,
        provider: json['provider'] as int? ?? 0,
        providerName: json['provider_name'] as String?,
        listing: json['listing'] as int?,
        listingTitle: json['listing_title'] as String?,
        score: _toDouble(json['score']) ?? 0,
        distanceKm: _toDouble(json['distance_km']),
        ratingSnapshot: _toDouble(json['rating_snapshot']),
        completedJobsSnapshot: json['completed_jobs_snapshot'] as int? ?? 0,
        status: json['status'] as String? ?? 'suggested',
        agreedPrice: _toDouble(json['agreed_price']),
        booking: json['booking'] as int?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
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

  bool get isSuggested => status == 'suggested';
  bool get isShortlisted => status == 'shortlisted';
  bool get isInvited => status == 'invited';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
