import 'database.dart';

abstract class SupabaseTable<T extends SupabaseDataRow> {
  String get tableName;
  T createRow(Map<String, dynamic> data);

  Future<List<T>> queryRows({
    required PostgrestTransformBuilder Function(PostgrestFilterBuilder) queryFn,
    int? limit,
  }) async =>
      _apiOnly();

  Future<List<T>> querySingleRow({
    required PostgrestTransformBuilder Function(PostgrestFilterBuilder) queryFn,
  }) async =>
      _apiOnly();

  Future<T> insert(Map<String, dynamic> data) async => _apiOnly();

  Future<List<T>> update({
    required Map<String, dynamic> data,
    required PostgrestTransformBuilder Function(PostgrestFilterBuilder)
        matchingRows,
    bool returnRows = false,
  }) async =>
      _apiOnly();

  Future<List<T>> delete({
    required PostgrestTransformBuilder Function(PostgrestFilterBuilder)
        matchingRows,
    bool returnRows = false,
  }) async =>
      _apiOnly();
}

Never _apiOnly() => throw UnsupportedError(
      'Direct database access has been removed. Use the matching SHPH API service.',
    );

extension NullSafePostgrestFilters on PostgrestFilterBuilder {
  PostgrestFilterBuilder eqOrNull(String column, dynamic value) =>
      value != null ? eq(column, value) : this;

  PostgrestFilterBuilder neqOrNull(String column, dynamic value) =>
      value != null ? neq(column, value) : this;

  PostgrestFilterBuilder ltOrNull(String column, dynamic value) =>
      value != null ? lt(column, value) : this;

  PostgrestFilterBuilder lteOrNull(String column, dynamic value) =>
      value != null ? lte(column, value) : this;

  PostgrestFilterBuilder gtOrNull(String column, dynamic value) =>
      value != null ? gt(column, value) : this;

  PostgrestFilterBuilder gteOrNull(String column, dynamic value) =>
      value != null ? gte(column, value) : this;

  PostgrestFilterBuilder containsOrNull(String column, dynamic value) =>
      value != null ? contains(column, value) : this;

  PostgrestFilterBuilder overlapsOrNull(String column, dynamic value) =>
      value != null ? overlaps(column, value) : this;

  PostgrestFilterBuilder inFilterOrNull(String column, List<dynamic>? values) =>
      values != null ? inFilter(column, values) : this;
}

extension NullSafeSupabaseStreamFilters on SupabaseStreamFilterBuilder {
  SupabaseStreamBuilder eqOrNull(String column, dynamic value) =>
      value != null ? eq(column, value) : this;

  SupabaseStreamBuilder neqOrNull(String column, dynamic value) =>
      value != null ? neq(column, value) : this;

  SupabaseStreamBuilder ltOrNull(String column, dynamic value) =>
      value != null ? lt(column, value) : this;

  SupabaseStreamBuilder lteOrNull(String column, dynamic value) =>
      value != null ? lte(column, value) : this;

  SupabaseStreamBuilder gtOrNull(String column, dynamic value) =>
      value != null ? gt(column, value) : this;

  SupabaseStreamBuilder gteOrNull(String column, dynamic value) =>
      value != null ? gte(column, value) : this;

  SupabaseStreamBuilder inFilterOrNull(String column, List<Object>? values) =>
      values != null ? inFilter(column, values) : this;
}

class PostgresTime {
  PostgresTime(this.time);
  DateTime? time;

  static PostgresTime? tryParse(String formattedString) {
    final datePrefix = DateTime.now().toIso8601String().split('T').first;
    return PostgresTime(
        DateTime.tryParse('${datePrefix}T$formattedString')?.toLocal());
  }

  String? toIso8601String() => time?.toIso8601String().split('T').last;

  @override
  String toString() => toIso8601String() ?? '';
}
