import 'dart:typed_data';

class GeminiImage {
  const GeminiImage({required this.bytes, required this.mimeType});
  final Uint8List bytes;
  final String mimeType;
}

enum DiagnosisConfidence { low, medium, high }

class PhotoDiagnosis {
  const PhotoDiagnosis({
    required this.refinedDescription,
    required this.parts,
    required this.confidence,
    this.priceRangeHint,
  });

  factory PhotoDiagnosis.fromJson(Map<String, dynamic> json) {
    final confidenceStr = json['confidence'] as String? ?? 'low';
    final confidence = DiagnosisConfidence.values.firstWhere(
      (c) => c.name == confidenceStr,
      orElse: () => DiagnosisConfidence.low,
    );

    PriceRangeHint? range;
    final rangeJson = json['priceRangeHint'] as Map<String, dynamic>?;
    if (rangeJson != null) {
      final min = (rangeJson['min'] as num?)?.toDouble();
      final max = (rangeJson['max'] as num?)?.toDouble();
      if (min != null && max != null && min > 0 && max >= min) {
        range = PriceRangeHint(min: min, max: max);
      }
    }

    final partsRaw = json['parts'] as List<dynamic>? ?? [];
    final parts = partsRaw
        .map((p) => p is String ? p.trim() : '')
        .where((p) => p.isNotEmpty)
        .toList();

    return PhotoDiagnosis(
      refinedDescription: (json['refinedDescription'] as String? ?? '').trim(),
      parts: parts,
      confidence: confidence,
      priceRangeHint: range,
    );
  }

  final String refinedDescription;
  final List<String> parts;
  final DiagnosisConfidence confidence;
  final PriceRangeHint? priceRangeHint;

  bool get isValid => refinedDescription.isNotEmpty;
}

class PriceRangeHint {
  const PriceRangeHint({required this.min, required this.max});
  final double min;
  final double max;
}

enum SmartSort { relevance, basePrice, basePriceDesc, rating, distance }

class SmartSearchFilters {
  const SmartSearchFilters({
    this.categoryId,
    this.priceMin,
    this.priceMax,
    this.minRating,
    this.nearMe = false,
    this.sort,
    this.cleanedQuery = '',
  });

  factory SmartSearchFilters.fromJson(Map<String, dynamic> json) {
    SmartSort? sort;
    final sortStr = json['sort'] as String?;
    if (sortStr != null) {
      switch (sortStr) {
        case 'relevance':
          sort = SmartSort.relevance;
        case 'base_price':
          sort = SmartSort.basePrice;
        case '-base_price':
          sort = SmartSort.basePriceDesc;
        case 'rating':
          sort = SmartSort.rating;
        case 'distance':
          sort = SmartSort.distance;
      }
    }

    var priceMin = (json['priceMin'] as num?)?.toDouble();
    var priceMax = (json['priceMax'] as num?)?.toDouble();
    if (priceMin != null && priceMax != null && priceMin > priceMax) {
      final tmp = priceMin;
      priceMin = priceMax;
      priceMax = tmp;
    }

    double? minRating;
    final ratingRaw = json['minRating'];
    if (ratingRaw != null) {
      final n = (ratingRaw as num).toDouble().clamp(0.0, 5.0);
      minRating = n > 0 ? n : null;
    }

    return SmartSearchFilters(
      categoryId: json['categoryId'] != null
          ? (json['categoryId'] as num).toInt()
          : null,
      priceMin: priceMin,
      priceMax: priceMax,
      minRating: minRating,
      nearMe: json['nearMe'] == true,
      sort: sort,
      cleanedQuery: (json['cleanedQuery'] as String? ?? '').trim(),
    );
  }

  final int? categoryId;
  final double? priceMin;
  final double? priceMax;
  final double? minRating;
  final bool nearMe;
  final SmartSort? sort;
  final String cleanedQuery;

  static SmartSearchFilters get empty => const SmartSearchFilters();

  SmartSearchFilters copyWith({
    int? categoryId,
    double? priceMin,
    double? priceMax,
    double? minRating,
    bool? nearMe,
    SmartSort? sort,
    String? cleanedQuery,
  }) =>
      SmartSearchFilters(
        categoryId: categoryId ?? this.categoryId,
        priceMin: priceMin ?? this.priceMin,
        priceMax: priceMax ?? this.priceMax,
        minRating: minRating ?? this.minRating,
        nearMe: nearMe ?? this.nearMe,
        sort: sort ?? this.sort,
        cleanedQuery: cleanedQuery ?? this.cleanedQuery,
      );
}

class ChatTurn {
  const ChatTurn({required this.role, required this.text});
  final String role; // "user" or "assistant"
  final String text;
}

class FaqItem {
  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });
  final int id;
  final String question;
  final String answer;
  final String category;
}

class DraftCandidate {
  const DraftCandidate({required this.id, required this.name});
  final int id;
  final String name;
}

String buildDiagnosisPrompt(
  String categoryName,
  double? suggestedMin,
  double? suggestedMax,
  String languageName,
) {
  final hasRange = suggestedMin != null && suggestedMax != null;
  return [
    'A customer attached a photo for a "$categoryName" home-service job.',
    'Reply in $languageName.',
    'From the photo, write a clear refinedDescription of the problem and list likely parts.',
    if (hasRange)
      'Typical price for this service is around \u20b1$suggestedMin\u2013\u20b1$suggestedMax; give a rough priceRangeHint near that range only if the photo is clear.'
    else
      'Do not estimate a price; set priceRangeHint to null.',
    'Set confidence to low, medium, or high based on how clearly the photo shows the problem.',
  ].join('\n');
}

String buildSmartSearchPrompt(
  String query,
  List<DraftCandidate> candidates,
  String languageName,
) {
  final list =
      candidates.map((c) => '- id=${c.id} name="${c.name}"').join('\n');
  return [
    'Convert the customer\'s search into structured filters for a home-service marketplace.',
    'Reply in $languageName.',
    'Pick categoryId ONLY from this list (or null if none clearly fits):',
    list,
    'priceMin/priceMax: pesos as numbers (or null). minRating: 0\u20135 (or null).',
    'nearMe: true if they imply proximity. sort: one of relevance, base_price (cheapest),',
    '-base_price (most expensive), rating, distance (or null).',
    'cleanedQuery: the remaining keywords with price/location/sort phrases removed.',
    '',
    'Customer searched: "$query"',
  ].join('\n');
}

String buildSupportPrompt(
  List<FaqItem> faq,
  List<ChatTurn> history,
  String question,
  String languageName, {
  bool allowAccountTools = false,
}) {
  final faqText =
      faq.map((f) => 'Q: ${f.question}\nA: ${f.answer}').join('\n\n');
  final convo = history
      .map((t) => '${t.role == 'user' ? 'Customer' : 'Assistant'}: ${t.text}')
      .join('\n');
  final policy = allowAccountTools
      ? 'Use the FAQ for general help. You may use the provided tools to look up the customer\'s OWN bookings and wallet \u2014 only for this customer, never anyone else. If unsure, suggest they contact support.'
      : 'Answer ONLY using the FAQ below. If the question is not covered, say you\'re not sure and suggest they contact support \u2014 do not invent policy or prices.';
  return [
    'You are SHPH\'s in-app support assistant.',
    policy,
    'Be concise and friendly.',
    'Reply in $languageName.',
    '',
    '=== FAQ ===',
    faqText,
    '=== END FAQ ===',
    if (convo.isNotEmpty) '\nConversation so far:\n$convo' else '',
    '\nCustomer: $question',
  ].where((s) => s.isNotEmpty).join('\n');
}
