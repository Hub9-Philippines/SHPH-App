import '/services/gemini_models.dart';
import '/services/logging_service.dart';

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  bool get isEnabled {
    // Gemini requires google_generative_ai package + API key.
    // Until that's configured, the service falls back to FAQ-based support.
    return false;
  }

  bool get allowPii => false;
  bool get accountToolsEnabled => false;
  bool get actionToolsEnabled => false;

  String languageName(String locale) {
    switch (locale) {
      case 'fil':
        return 'Filipino';
      default:
        return 'English';
    }
  }

  Future<String?> askSupport({
    required String question,
    List<ChatTurn> history = const [],
    List<FaqItem> faq = const [],
    String locale = 'en',
  }) async {
    if (!isEnabled || !allowPii) return null;
    if (question.trim().length < 2) return null;

    try {
      // ignore: unused_local_variable
      final prompt = buildSupportPrompt(
        faq,
        history,
        question.trim(),
        languageName(locale),
        allowAccountTools: accountToolsEnabled,
      );

      // When google_generative_ai is added:
      // 1. Build GenerativeModel with prompt
      // 2. Call model.generateContent([Content.text(prompt)])
      // 3. Return response.text
      return null;
    } catch (e) {
      LoggingService.error('askSupport failed: $e', tag: 'GeminiService');
      return null;
    }
  }

  Future<PhotoDiagnosis?> diagnosePhoto({
    required GeminiImage image,
    String? categoryName,
    double? suggestedMin,
    double? suggestedMax,
    String locale = 'en',
  }) async {
    if (!isEnabled || !allowPii) return null;

    try {
      // ignore: unused_local_variable
      final prompt = buildDiagnosisPrompt(
        categoryName ?? 'general',
        suggestedMin,
        suggestedMax,
        languageName(locale),
      );

      // When google_generative_ai is added:
      // 1. Build GenerativeModel with responseSchema
      // 2. Call model.generateContent([
      //      Content.multi([TextPart(prompt), DataPart(image.mimeType, image.bytes)])
      //    ])
      // 3. Parse JSON response -> PhotoDiagnosis.fromJson
      return null;
    } catch (e) {
      LoggingService.error('diagnosePhoto failed: $e', tag: 'GeminiService');
      return null;
    }
  }

  Future<SmartSearchFilters?> smartSearch({
    required String query,
    List<DraftCandidate> categories = const [],
    String locale = 'en',
  }) async {
    if (!isEnabled || !allowPii) return null;
    if (query.trim().length < 3 || categories.isEmpty) return null;

    try {
      // ignore: unused_local_variable
      final prompt = buildSmartSearchPrompt(
        query.trim(),
        categories,
        languageName(locale),
      );

      // When google_generative_ai is added:
      // 1. Build GenerativeModel with responseSchema
      // 2. Call model.generateContent([Content.text(prompt)])
      // 3. Parse JSON response -> SmartSearchFilters.fromJson
      return null;
    } catch (e) {
      LoggingService.error('smartSearch failed: $e', tag: 'GeminiService');
      return null;
    }
  }
}
