import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../flutter_flow/lat_lng.dart';
import 'shph_query_builder.dart';

/// Maps table names to SHPH API endpoints.
String _tableEndpoint(String tableName) {
  const mapping = <String, String>{
    'addresses': '/api/profiles/addresses/',
    'profiles': '/api/users/me/',
    'bookings': '/api/services/bookings/',
    'categories': '/api/services/categories/',
    'notifications': '/api/notifications/',
    'payment_methods': '/api/users/payment-methods/',
    'reviews': '/api/services/reviews/mine/',
    'service_listings': '/api/services/listings/',
  };
  return mapping[tableName] ?? '/api/$tableName/';
}

/// Base class for data table abstractions.
///
/// Uses the SHPH REST API client for all data access. Row classes remain
/// as data holders for deserialized API responses.
abstract class ShphDataTable<T extends ShphDataRow> {
  String get tableName;
  T createRow(Map<String, dynamic> data);

  String get _endpoint => _tableEndpoint(tableName);

  ShphQueryBuilder _select() => ShphQueryBuilder(_endpoint);

  Future<List<T>> queryRows({
    required ShphQueryBuilder Function(ShphQueryBuilder) queryFn,
    int? limit,
  }) {
    final builder = _select();
    if (limit != null) {
      builder.limit(limit);
    }
    queryFn(builder);
    return builder.select().then((rows) => rows.map(createRow).toList());
  }

  Future<List<T>> querySingleRow({
    required ShphQueryBuilder Function(ShphQueryBuilder) queryFn,
  }) async {
    final builder = _select();
    queryFn(builder);
    builder.limit(1);
    final rows = await builder.select();
    return [if (rows.isNotEmpty) createRow(rows.first)];
  }

  Future<T> insert(Map<String, dynamic> data) async {
    final result = await ShphQueryBuilder(_endpoint).insert(data);
    return createRow(result ?? data);
  }

  Future<List<T>> update({
    required Map<String, dynamic> data,
    required ShphQueryBuilder Function(ShphQueryBuilder) matchingRows,
    bool returnRows = false,
  }) async {
    final builder = _select();
    matchingRows(builder);
    final rows = await builder.update(data);
    if (!returnRows) {
      return [];
    }
    return rows.map(createRow).toList();
  }

  Future<List<T>> delete({
    required ShphQueryBuilder Function(ShphQueryBuilder) matchingRows,
    bool returnRows = false,
  }) async {
    final builder = _select();
    matchingRows(builder);
    await builder.delete();
    if (!returnRows) {
      return [];
    }
    final rows = await builder.select();
    return rows.map(createRow).toList();
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

abstract class ShphDataRow {
  ShphDataRow(this.data);

  ShphDataTable get table;
  Map<String, dynamic> data;

  String get tableName => table.tableName;

  T? getField<T>(String fieldName, [T? defaultValue]) =>
      _shphDeserialize<T>(data[fieldName]) ?? defaultValue;
  void setField<T>(String fieldName, T? value) =>
      data[fieldName] = shphSerialize<T>(value);
  List<T> getListField<T>(String fieldName) =>
      _shphDeserializeList<T>(data[fieldName]) ?? [];
  void setListField<T>(String fieldName, List<T>? value) =>
      data[fieldName] = shphSerializeList<T>(value);

  @override
  String toString() => '''
Table: $tableName
Row Data: {${data.isNotEmpty ? '\n' : ''}${data.entries.map((e) => '  (${e.value.runtimeType}) "${e.key}": ${e.value},\n').join('')}}''';

  @override
  int get hashCode => Object.hash(
        tableName,
        Object.hashAllUnordered(
          data.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );

  @override
  bool operator ==(Object other) =>
      other is ShphDataRow && mapEquals(other.data, data);
}

dynamic shphSerialize<T>(T? value) {
  if (value == null) {
    return null;
  }

  switch (T) {
    case DateTime:
      return (value as DateTime).toIso8601String();
    case PostgresTime:
      return (value as PostgresTime).toIso8601String();
    case LatLng:
      final latLng = value as LatLng;
      return {'lat': latLng.latitude, 'lng': latLng.longitude};
    default:
      return value;
  }
}

List? shphSerializeList<T>(List<T>? value) =>
    value?.map((v) => shphSerialize<T>(v)).toList();

T? _shphDeserialize<T>(dynamic value) {
  if (value == null) {
    return null;
  }

  switch (T) {
    case int:
      return (value as num).round() as T?;
    case double:
      return (value as num).toDouble() as T?;
    case DateTime:
      if (value is DateTime) {
        return value as T?;
      }
      return (value is String ? DateTime.tryParse(value) : null)?.toLocal()
          as T?;
    case PostgresTime:
      return PostgresTime.tryParse(value as String) as T?;
    case LatLng:
      final latLng = value is Map ? value : json.decode(value) as Map;
      final lat = latLng['lat'] ?? latLng['latitude'];
      final lng = latLng['lng'] ?? latLng['longitude'];
      return lat is num && lng is num
          ? LatLng(lat.toDouble(), lng.toDouble()) as T?
          : null;
    default:
      return value as T;
  }
}

List<T>? _shphDeserializeList<T>(dynamic value) => value is List
    ? value
        .map((v) => _shphDeserialize<T>(v))
        .where((v) => v != null)
        .map((v) => v as T)
        .toList()
    : null;
