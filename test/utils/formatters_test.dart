import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/utils/formatters.dart';

void main() {
  group('Formatters.toNullableDouble', () {
    test('returns null for null input', () {
      expect(Formatters.toNullableDouble(null), isNull);
    });

    test('parses int values', () {
      expect(Formatters.toNullableDouble(42), 42.0);
      expect(Formatters.toNullableDouble(0), 0.0);
      expect(Formatters.toNullableDouble(-7), -7.0);
    });

    test('parses double values', () {
      expect(Formatters.toNullableDouble(3.14), 3.14);
      expect(Formatters.toNullableDouble(0.0), 0.0);
      expect(Formatters.toNullableDouble(-99.5), -99.5);
    });

    test('parses numeric strings', () {
      expect(Formatters.toNullableDouble('5.0'), 5.0);
      expect(Formatters.toNullableDouble('42'), 42.0);
      expect(Formatters.toNullableDouble('-3.14'), -3.14);
    });

    test('returns null for unparseable strings', () {
      expect(Formatters.toNullableDouble('abc'), isNull);
      expect(Formatters.toNullableDouble(''), isNull);
      expect(Formatters.toNullableDouble('not a number'), isNull);
    });

    test('handles API string-wrapped numbers like "5.0"', () {
      expect(Formatters.toNullableDouble('5.0'), 5.0);
      expect(Formatters.toNullableDouble('100.50'), 100.50);
    });
  });

  group('Formatters.parseAmount', () {
    test('returns 0 for null input', () {
      expect(Formatters.parseAmount(null), 0);
    });

    test('parses num values', () {
      expect(Formatters.parseAmount(42), 42.0);
      expect(Formatters.parseAmount(3.14), 3.14);
    });

    test('parses string values, defaults to 0 on failure', () {
      expect(Formatters.parseAmount('5.0'), 5.0);
      expect(Formatters.parseAmount('abc'), 0);
    });
  });

  group('Formatters.parseMapList', () {
    test('returns empty list for non-list input', () {
      expect(Formatters.parseMapList(null), isEmpty);
      expect(Formatters.parseMapList('string'), isEmpty);
      expect(Formatters.parseMapList(42), isEmpty);
    });

    test('extracts maps from a list, filtering non-maps', () {
      final result = Formatters.parseMapList([
        {'id': 1},
        'not a map',
        {'id': 2},
        42,
      ]);
      expect(result, hasLength(2));
      expect(result[0]['id'], 1);
      expect(result[1]['id'], 2);
    });
  });

  group('Formatters.toNullableInt', () {
    test('returns null for null input', () {
      expect(Formatters.toNullableInt(null), isNull);
    });

    test('parses int values', () {
      expect(Formatters.toNullableInt(42), 42);
      expect(Formatters.toNullableInt(0), 0);
      expect(Formatters.toNullableInt(-7), -7);
    });

    test('truncates double values to int', () {
      expect(Formatters.toNullableInt(3.9), 3);
      expect(Formatters.toNullableInt(120.0), 120);
      expect(Formatters.toNullableInt(-2.7), -2);
    });

    test('parses numeric strings', () {
      expect(Formatters.toNullableInt('120'), 120);
      expect(Formatters.toNullableInt('0'), 0);
      expect(Formatters.toNullableInt('-42'), -42);
    });

    test('returns null for unparseable strings', () {
      expect(Formatters.toNullableInt('abc'), isNull);
      expect(Formatters.toNullableInt(''), isNull);
      expect(Formatters.toNullableInt('not a number'), isNull);
    });

    test('handles API string-wrapped numbers like "120"', () {
      expect(Formatters.toNullableInt('120'), 120);
      expect(Formatters.toNullableInt('3600'), 3600);
    });
  });
}
