/// Shared formatting and parsing utilities used across pages and models.
class Formatters {
  Formatters._();

  /// Parses an API number or numeric string, defaulting to zero.
  static double parseAmount(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  /// Parses an API number or numeric string while preserving missing values.
  static double? toNullableDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  /// Parses an API integer or numeric string while preserving missing values.
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

  /// Formats an amount using the application's PHP currency convention.
  static String currency(double amount) => 'PHP ${amount.toStringAsFixed(2)}';

  /// Extracts typed maps from an API list and ignores invalid elements.
  static List<Map<String, dynamic>> parseMapList(Object? value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
