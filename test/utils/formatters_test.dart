import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/utils/formatters.dart';

void main() {
  group('Formatters.toNullableDouble', () {
    test('preserves null and rejects invalid values', () {
      expect(Formatters.toNullableDouble(null), isNull);
      expect(Formatters.toNullableDouble('invalid'), isNull);
      expect(Formatters.toNullableDouble(''), isNull);
    });

    test('parses numbers and numeric strings', () {
      expect(Formatters.toNullableDouble(42), 42.0);
      expect(Formatters.toNullableDouble(3.14), 3.14);
      expect(Formatters.toNullableDouble('100.50'), 100.5);
    });
  });

  group('Formatters.toNullableInt', () {
    test('preserves null and rejects invalid values', () {
      expect(Formatters.toNullableInt(null), isNull);
      expect(Formatters.toNullableInt('invalid'), isNull);
      expect(Formatters.toNullableInt(''), isNull);
    });

    test('parses integers and truncates doubles', () {
      expect(Formatters.toNullableInt(42), 42);
      expect(Formatters.toNullableInt(3.9), 3);
      expect(Formatters.toNullableInt('120'), 120);
    });
  });

  test('parseAmount defaults invalid values to zero', () {
    expect(Formatters.parseAmount(null), 0);
    expect(Formatters.parseAmount('invalid'), 0);
    expect(Formatters.parseAmount('5.25'), 5.25);
  });

  test('currency uses PHP and two decimal places', () {
    expect(Formatters.currency(5), 'PHP 5.00');
  });

  test('parseMapList filters invalid elements', () {
    expect(
      Formatters.parseMapList([
        {'id': 1},
        'invalid',
        {'id': 2},
      ]),
      [
        {'id': 1},
        {'id': 2},
      ],
    );
  });
}
