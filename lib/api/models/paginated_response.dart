class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final List<T> results;
  final String? next;
  final String? previous;

  factory PaginatedResponse.fromJson(
    dynamic data,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    if (data is List) {
      final items = data
          .whereType<Map<String, dynamic>>()
          .map(fromJsonT)
          .toList();
      return PaginatedResponse(
        count: items.length,
        results: items,
      );
    }
    if (data is Map<String, dynamic>) {
      final rawResults = data['results'];
      final items = rawResults is List
          ? rawResults
              .whereType<Map<String, dynamic>>()
              .map(fromJsonT)
              .toList()
          : <T>[];
      return PaginatedResponse(
        count: data['count'] as int? ?? items.length,
        next: data['next'] as String?,
        previous: data['previous'] as String?,
        results: items,
      );
    }
    return const PaginatedResponse(count: 0, results: []);
  }
}
