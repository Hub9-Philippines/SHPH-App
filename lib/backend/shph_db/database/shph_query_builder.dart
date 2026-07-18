// ignore_for_file: avoid_returning_this

import '/api/shph_api_client.dart';
import '/services/logging_service.dart';

/// Query builder that translates filter calls to Django REST API query parameters.
///
/// Accumulates filter conditions, then executes a GET/POST/PATCH/DELETE
/// request against the SHPH API endpoint for the table.
class ShphQueryBuilder {
  ShphQueryBuilder(this._endpoint);

  final String _endpoint;
  final Map<String, dynamic> _queryParams = {};
  int? _limit;
  String? _orderColumn;
  bool _ascending = true;

  ShphQueryBuilder eq(String column, dynamic value) {
    if (value != null) {
      _queryParams[column] = value.toString();
    }
    return this;
  }

  ShphQueryBuilder neq(String column, dynamic value) {
    if (value != null) {
      _queryParams['${column}__ne'] = value.toString();
    }
    return this;
  }

  ShphQueryBuilder lt(String column, dynamic value) {
    if (value != null) {
      _queryParams['${column}__lt'] = value.toString();
    }
    return this;
  }

  ShphQueryBuilder lte(String column, dynamic value) {
    if (value != null) {
      _queryParams['${column}__lte'] = value.toString();
    }
    return this;
  }

  ShphQueryBuilder gt(String column, dynamic value) {
    if (value != null) {
      _queryParams['${column}__gt'] = value.toString();
    }
    return this;
  }

  ShphQueryBuilder gte(String column, dynamic value) {
    if (value != null) {
      _queryParams['${column}__gte'] = value.toString();
    }
    return this;
  }

  ShphQueryBuilder inFilter(String column, List<dynamic> values) {
    if (values.isNotEmpty) {
      _queryParams['${column}__in'] = values.join(',');
    }
    return this;
  }

  ShphQueryBuilder contains(String column, dynamic value) {
    if (value != null) {
      _queryParams['${column}__contains'] = value.toString();
    }
    return this;
  }

  ShphQueryBuilder overlaps(String column, dynamic value) {
    if (value != null) {
      _queryParams['${column}__overlap'] = value.toString();
    }
    return this;
  }

  ShphQueryBuilder or(String filterString) {
    // OR filter: "col1.eq.val,col2.eq.val2"
    // Django REST doesn't have a direct equivalent; pass as custom param
    _queryParams['_or'] = filterString;
    return this;
  }

  ShphQueryBuilder order(String column, {bool ascending = true}) {
    _orderColumn = column;
    _ascending = ascending;
    return this;
  }

  ShphQueryBuilder limit(int count) {
    _limit = count;
    return this;
  }

  Map<String, dynamic> _buildQueryParams() {
    final params = Map<String, dynamic>.from(_queryParams);
    if (_limit != null) {
      params['page_size'] = _limit.toString();
    }
    if (_orderColumn != null) {
      params['ordering'] = _ascending ? _orderColumn! : '-$_orderColumn';
    }
    return params;
  }

  Future<List<Map<String, dynamic>>> select() async {
    try {
      final response = await ShphApiClient.instance.get<dynamic>(
        _endpoint,
        queryParameters: _buildQueryParams(),
      );
      final data = response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      if (data is Map<String, dynamic> && data.containsKey('results')) {
        return (data['results'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      LoggingService.error('Query select failed: $e', tag: 'ShphQueryBuilder');
      return [];
    }
  }

  Future<Map<String, dynamic>?> maybeSingle() async {
    final rows = await select();
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<Map<String, dynamic>> single() async {
    final rows = await select();
    return rows.first;
  }

  Future<Map<String, dynamic>?> insert(Map<String, dynamic> data) async {
    try {
      final response = await ShphApiClient.instance.post<dynamic>(
        _endpoint,
        data: data,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      LoggingService.error('Insert failed: $e', tag: 'ShphQueryBuilder');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> update(Map<String, dynamic> data) async {
    try {
      // For update, we need to filter first then PATCH
      // Django REST typically uses PATCH /endpoint/{id}/ for single updates
      // For filter-based updates, we use POST to a custom action or PATCH with query params
      final response = await ShphApiClient.instance.patch<dynamic>(
        _endpoint,
        data: data,
        queryParameters: _buildQueryParams(),
      );
      final responseData = response.data;
      if (responseData is List) {
        return responseData.cast<Map<String, dynamic>>();
      }
      if (responseData is Map<String, dynamic>) {
        return [responseData];
      }
      return [];
    } catch (e) {
      LoggingService.error('Update failed: $e', tag: 'ShphQueryBuilder');
      return [];
    }
  }

  Future<void> delete() async {
    try {
      await ShphApiClient.instance.delete<dynamic>(
        _endpoint,
        queryParameters: _buildQueryParams(),
      );
    } catch (e) {
      LoggingService.error('Delete failed: $e', tag: 'ShphQueryBuilder');
    }
  }
}

/// Transform builder that wraps the query builder for terminal operations.
class ShphTransformBuilder {
  ShphTransformBuilder(this._builder);
  final ShphQueryBuilder _builder;

  ShphTransformBuilder limit(int count) {
    _builder.limit(count);
    return this;
  }

  Future<List<Map<String, dynamic>>> select() => _builder.select();

  Future<Map<String, dynamic>?> maybeSingle() => _builder.maybeSingle();

  Future<Map<String, dynamic>> single() => _builder.single();
}

/// Extension providing null-safe filter methods.
extension NullSafeShphQueryFilters on ShphQueryBuilder {
  ShphQueryBuilder eqOrNull(String column, dynamic value) =>
      value != null ? eq(column, value) : this;

  ShphQueryBuilder neqOrNull(String column, dynamic value) =>
      value != null ? neq(column, value) : this;

  ShphQueryBuilder ltOrNull(String column, dynamic value) =>
      value != null ? lt(column, value) : this;

  ShphQueryBuilder lteOrNull(String column, dynamic value) =>
      value != null ? lte(column, value) : this;

  ShphQueryBuilder gtOrNull(String column, dynamic value) =>
      value != null ? gt(column, value) : this;

  ShphQueryBuilder gteOrNull(String column, dynamic value) =>
      value != null ? gte(column, value) : this;

  ShphQueryBuilder containsOrNull(String column, dynamic value) =>
      value != null ? contains(column, value) : this;

  ShphQueryBuilder overlapsOrNull(String column, dynamic value) =>
      value != null ? overlaps(column, value) : this;

  ShphQueryBuilder inFilterOrNull(String column, List<dynamic>? values) =>
      values != null ? inFilter(column, values) : this;
}
