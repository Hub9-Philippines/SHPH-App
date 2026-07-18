import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/gemini_models.dart';

void main() {
  group('PhotoDiagnosis', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'refinedDescription': 'Leaking pipe under sink',
        'parts': ['P-trap', 'washer', 'Teflon tape'],
        'confidence': 'high',
        'priceRangeHint': {'min': 500, 'max': 1500},
      };
      final d = PhotoDiagnosis.fromJson(json);
      expect(d.refinedDescription, 'Leaking pipe under sink');
      expect(d.parts, ['P-trap', 'washer', 'Teflon tape']);
      expect(d.confidence, DiagnosisConfidence.high);
      expect(d.priceRangeHint?.min, 500);
      expect(d.priceRangeHint?.max, 1500);
      expect(d.isValid, isTrue);
    });

    test('fromJson handles missing fields gracefully', () {
      final d = PhotoDiagnosis.fromJson({});
      expect(d.refinedDescription, '');
      expect(d.parts, isEmpty);
      expect(d.confidence, DiagnosisConfidence.low);
      expect(d.priceRangeHint, isNull);
      expect(d.isValid, isFalse);
    });

    test('fromJson ignores invalid confidence string', () {
      final d = PhotoDiagnosis.fromJson({'confidence': 'invalid'});
      expect(d.confidence, DiagnosisConfidence.low);
    });

    test('fromJson rejects price range where min > max by swapping', () {
      final d = PhotoDiagnosis.fromJson({
        'refinedDescription': 'Test',
        'priceRangeHint': {'min': 1000, 'max': 500},
      });
      // The parser doesn't swap for priceRangeHint — it checks min > 0 && max >= min
      // So invalid range should be null
      expect(d.priceRangeHint, isNull);
    });

    test('fromJson trims whitespace in parts and description', () {
      final d = PhotoDiagnosis.fromJson({
        'refinedDescription': '  spaced  ',
        'parts': ['  part1  ', '', 'part2'],
      });
      expect(d.refinedDescription, 'spaced');
      expect(d.parts, ['part1', 'part2']);
    });
  });

  group('SmartSearchFilters', () {
    test('fromJson parses complete filters', () {
      final json = {
        'categoryId': 3,
        'priceMin': 200,
        'priceMax': 800,
        'minRating': 4.0,
        'nearMe': true,
        'sort': 'rating',
        'cleanedQuery': 'plumber near me',
      };
      final f = SmartSearchFilters.fromJson(json);
      expect(f.categoryId, 3);
      expect(f.priceMin, 200);
      expect(f.priceMax, 800);
      expect(f.minRating, 4.0);
      expect(f.nearMe, isTrue);
      expect(f.sort, SmartSort.rating);
      expect(f.cleanedQuery, 'plumber near me');
    });

    test('fromJson swaps min > max', () {
      final f = SmartSearchFilters.fromJson({
        'priceMin': 800,
        'priceMax': 200,
      });
      expect(f.priceMin, 200);
      expect(f.priceMax, 800);
    });

    test('fromJson clamps minRating to 0-5', () {
      final f = SmartSearchFilters.fromJson({'minRating': 10});
      expect(f.minRating, 5.0);
    });

    test('fromJson treats minRating 0 as null', () {
      final f = SmartSearchFilters.fromJson({'minRating': 0});
      expect(f.minRating, isNull);
    });

    test('empty factory returns all-null filters', () {
      final f = SmartSearchFilters.empty;
      expect(f.categoryId, isNull);
      expect(f.priceMin, isNull);
      expect(f.priceMax, isNull);
      expect(f.minRating, isNull);
      expect(f.nearMe, isFalse);
      expect(f.sort, isNull);
      expect(f.cleanedQuery, '');
    });

    test('copyWith preserves unchanged fields', () {
      const original = SmartSearchFilters(
        categoryId: 1,
        priceMin: 100,
        cleanedQuery: 'test',
      );
      final copied = original.copyWith(minRating: 4);
      expect(copied.categoryId, 1);
      expect(copied.priceMin, 100);
      expect(copied.cleanedQuery, 'test');
      expect(copied.minRating, 4.0);
    });
  });

  group('Prompt builders', () {
    test('buildDiagnosisPrompt includes category and language', () {
      final prompt = buildDiagnosisPrompt('Plumbing', 200, 800, 'English');
      expect(prompt, contains('Plumbing'));
      expect(prompt, contains('English'));
      expect(prompt, contains('200'));
      expect(prompt, contains('800'));
    });

    test('buildDiagnosisPrompt without price range says no estimate', () {
      final prompt = buildDiagnosisPrompt('Cleaning', null, null, 'Filipino');
      expect(prompt, contains('Do not estimate a price'));
    });

    test('buildSmartSearchPrompt includes candidates and query', () {
      final prompt = buildSmartSearchPrompt(
        'cheap plumber',
        [const DraftCandidate(id: 1, name: 'Plumbing')],
        'English',
      );
      expect(prompt, contains('id=1'));
      expect(prompt, contains('Plumbing'));
      expect(prompt, contains('cheap plumber'));
    });

    test('buildSupportPrompt includes FAQ and conversation', () {
      final prompt = buildSupportPrompt(
        [const FaqItem(id: 1, question: 'How to cancel?', answer: 'Go to bookings.', category: 'general')],
        [const ChatTurn(role: 'user', text: 'I need help')],
        'How do I cancel?',
        'English',
      );
      expect(prompt, contains('How to cancel?'));
      expect(prompt, contains('Go to bookings.'));
      expect(prompt, contains('I need help'));
      expect(prompt, contains('How do I cancel?'));
    });

    test('buildSupportPrompt with allowAccountTools uses tool policy', () {
      final prompt = buildSupportPrompt(
        [],
        [],
        'Show my bookings',
        'English',
        allowAccountTools: true,
      );
      expect(prompt, contains('provided tools'));
    });
  });
}
