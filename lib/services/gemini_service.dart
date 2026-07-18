import '/api/models/support_ticket.dart';
import '/api/resources/support_api.dart';
import '/services/logging_service.dart';

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  bool get isEnabled {
    // Gemini requires google_generative_ai package + API key.
    // Until that's configured, the service falls back to FAQ-based support.
    return false;
  }

  Future<String?> askSupport({
    required String question,
    List<Map<String, String>> history = const [],
  }) async {
    if (!isEnabled) return null;

    // When google_generative_ai is added:
    // 1. Build prompt from FAQ + history + question
    // 2. Call GenerativeModel.generateContent()
    // 3. Return text response
    return null;
  }

  Future<List<ShphFaq>> loadFaq() async {
    try {
      return await ShphSupportApi.instance.listFaq();
    } catch (e) {
      LoggingService.error('loadFaq failed: $e', tag: 'GeminiService');
      return [];
    }
  }

  Future<String?> diagnosePhoto({
    required String base64Image,
    required String mimeType,
    String? category,
  }) async {
    if (!isEnabled) return null;

    // When google_generative_ai is added:
    // 1. Build prompt with image + category context
    // 2. Call GenerativeModel.generateContent([TextPart, DataPart])
    // 3. Return diagnosis text
    return null;
  }

  Future<String?> smartSearch({
    required String query,
    String? userLocation,
  }) async {
    if (!isEnabled) return null;

    // When google_generative_ai is added:
    // 1. Build prompt with query + location context
    // 2. Call GenerativeModel.generateContent()
    // 3. Return enhanced search suggestions
    return null;
  }
}
