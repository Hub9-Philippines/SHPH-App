class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawResults = json['results'];
    return PaginatedResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: rawResults is List
          ? rawResults.whereType<Map<String, dynamic>>().map(fromJsonT).toList()
          : const [],
    );
  }

  final int count;
  final List<T> results;
  final String? next;
  final String? previous;
}
