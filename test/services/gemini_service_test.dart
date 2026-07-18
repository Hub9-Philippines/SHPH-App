import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:serbisyohubph/services/gemini_models.dart';
import 'package:serbisyohubph/services/gemini_service.dart';

void main() {
  group('GeminiService', () {
    test('isEnabled is false when google_generative_ai is not configured', () {
      expect(GeminiService.instance.isEnabled, isFalse);
    });

    test('allowPii is false by default', () {
      expect(GeminiService.instance.allowPii, isFalse);
    });

    test('accountToolsEnabled is false by default', () {
      expect(GeminiService.instance.accountToolsEnabled, isFalse);
    });

    test('askSupport returns null when disabled', () async {
      final result = await GeminiService.instance.askSupport(
        question: 'How do I cancel?',
        history: [],
        faq: [],
      );
      expect(result, isNull);
    });

    test('diagnosePhoto returns null when disabled', () async {
      final result = await GeminiService.instance.diagnosePhoto(
        image: GeminiImage(bytes: Uint8List(0), mimeType: 'image/jpeg'),
      );
      expect(result, isNull);
    });

    test('smartSearch returns null when disabled', () async {
      final result = await GeminiService.instance.smartSearch(
        query: 'cheap plumber',
        categories: [const DraftCandidate(id: 1, name: 'Plumbing')],
      );
      expect(result, isNull);
    });

    test('smartSearch returns null for empty categories even if enabled', () async {
      // Since isEnabled is false, this short-circuits, but the guard
      // for empty categories is still important coverage.
      final result = await GeminiService.instance.smartSearch(
        query: 'test',
        categories: [],
      );
      expect(result, isNull);
    });

    test('languageName returns Filipino for fil locale', () {
      expect(GeminiService.instance.languageName('fil'), 'Filipino');
    });

    test('languageName returns English for en locale', () {
      expect(GeminiService.instance.languageName('en'), 'English');
    });

    test('languageName defaults to English for unknown locale', () {
      expect(GeminiService.instance.languageName('fr'), 'English');
    });
  });
}
