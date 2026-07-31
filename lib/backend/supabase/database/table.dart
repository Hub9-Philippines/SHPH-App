import 'row.dart';

/// Lightweight, backend-agnostic query filter used by generated table
/// classes. Supabase has been removed; table queries are resolved through
/// [DataTableStore] which routes to the SHPH API (or returns empty stubs).
class TableFilter {
  TableFilter(this.tableName);

  final String tableName;
  final Map<String, dynamic> equals = {};
  final List<String> orFilters = [];
  final Map<String, List<dynamic>> inFilters = {};
  final List<({String column, bool ascending})> orderBy = [];
  int? limitValue;

  TableFilter eq(String column, dynamic value) {
    equals[column] = value;
    return this;
  }

  TableFilter eqOrNull(String column, dynamic value) =>
      value != null ? eq(column, value) : this;

  TableFilter or(String filter) {
    orFilters.add(filter);
    return this;
  }

  TableFilter inFilter(String column, List<dynamic>? values) {
    if (values != null && values.isNotEmpty) {
      inFilters[column] = values;
    }
    return this;
  }

  TableFilter order(String column, {bool ascending = true}) {
    orderBy.add((column: column, ascending: ascending));
    return this;
  }

  TableFilter limit(int limit) {
    limitValue = limit;
    return this;
  }
}

/// Registers a data source for a given table name. Sources are expected to
/// query the SHPH API. Unregistered tables resolve to empty stubs.
abstract class TableDataSource {
  Future<List<Map<String, dynamic>>> query(TableFilter filter);
  Future<Map<String, dynamic>?> insert(Map<String, dynamic> data);
  Future<int> update(
    TableFilter filter,
    Map<String, dynamic> data,
  );
  Future<int> delete(TableFilter filter);
}

class DataTableStore {
  DataTableStore._();

  static final DataTableStore instance = DataTableStore._();

  final Map<String, TableDataSource> _sources = {};

  void register(String tableName, TableDataSource source) {
    _sources[tableName] = source;
  }

  TableDataSource? sourceFor(String tableName) => _sources[tableName];

  Future<List<Map<String, dynamic>>> query(
      String tableName, TableFilter filter) async {
    final source = _sources[tableName];
    if (source == null) {
      return const [];
    }
    return source.query(filter);
  }

  Future<Map<String, dynamic>?> insert(
      String tableName, Map<String, dynamic> data) async {
    final source = _sources[tableName];
    if (source == null) {
      return null;
    }
    return source.insert(data);
  }

  Future<int> update(
      String tableName, TableFilter filter, Map<String, dynamic> data) async {
    final source = _sources[tableName];
    if (source == null) {
      return 0;
    }
    return source.update(filter, data);
  }

  Future<int> delete(String tableName, TableFilter filter) async {
    final source = _sources[tableName];
    if (source == null) {
      return 0;
    }
    return source.delete(filter);
  }
}

abstract class SupabaseTable<T extends SupabaseDataRow> {
  String get tableName;
  T createRow(Map<String, dynamic> data);

  TableFilter _filter() => TableFilter(tableName);

  Future<List<T>> queryRows({
    required TableFilter Function(TableFilter) queryFn,
    int? limit,
  }) async {
    final filter = queryFn(_filter());
    if (limit != null) {
      filter.limit(limit);
    }
    final rows = await DataTableStore.instance.query(tableName, filter);
    return rows.map(createRow).toList();
  }

  Future<List<T>> querySingleRow({
    required TableFilter Function(TableFilter) queryFn,
  }) async {
    final filter = queryFn(_filter()).limit(1);
    final rows = await DataTableStore.instance.query(tableName, filter);
    return rows.take(1).map(createRow).toList();
  }

  Future<T> insert(Map<String, dynamic> data) async {
    final inserted = await DataTableStore.instance.insert(tableName, data);
    return createRow(inserted ?? data);
  }

  Future<List<T>> update({
    required Map<String, dynamic> data,
    required TableFilter Function(TableFilter) matchingRows,
    bool returnRows = false,
  }) async {
    final filter = matchingRows(_filter());
    final updated = await DataTableStore.instance.update(tableName, filter, data);
    if (!returnRows) {
      return [];
    }
    return updated > 0 ? const [] : const [];
  }

  Future<List<T>> delete({
    required TableFilter Function(TableFilter) matchingRows,
    bool returnRows = false,
  }) async {
    final filter = matchingRows(_filter());
    final deleted = await DataTableStore.instance.delete(tableName, filter);
    if (!returnRows) {
      return [];
    }
    return const [];
  }
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
