/// Shared formatting and parsing utilities used across pages and models.
class Formatters {
  Formatters._();

  /// Parses a dynamic value (num, String, or null) to double.
  /// Handles API responses that may return numbers as strings (e.g. "5.0").
  static double parseAmount(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  /// Nullable variant of [parseAmount] — returns null instead of 0 when
  /// the value is null or unparseable. Used by API model `fromJson` methods
  /// where a missing field should remain null rather than default to 0.
  static double? toNullableDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  /// Parses a dynamic value (num, String, or null) to a nullable int.
  /// Handles API responses that may return numbers as strings (e.g. "120").
  static int? toNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  /// Formats a double as PHP currency string with 2 decimal places.
  static String currency(double amount) => 'PHP ${amount.toStringAsFixed(2)}';

  /// Parses a dynamic value into a list of typed maps.
  /// Returns empty list if value is not a List.
  static List<Map<String, dynamic>> parseMapList(dynamic value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
