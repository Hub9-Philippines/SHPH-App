import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/models/service_listing.dart';
import '/services/logging_service.dart';
import '/services/service_listing_service.dart';

class OpenRouterConfig {
  OpenRouterConfig._();

  static const String apiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  static bool get isConfigured =>
      apiKey.isNotEmpty && apiKey != 'your-openrouter-api-key-here';
}

class AIService {
  AIService._();
  static final AIService instance = AIService._();

  bool get isAvailable => OpenRouterConfig.isConfigured;

  Future<String> chat(String message, {String? systemPrompt}) async {
    if (!isAvailable) {
      throw Exception('AI service not configured');
    }

    final body = {
      'model': 'deepseek/deepseek-v4-flash-free',
      'messages': [
        if (systemPrompt != null)
          {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': message},
      ],
      'temperature': 0.7,
      'max_tokens': 2048,
    };

    final response = await http
        .post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer ${OpenRouterConfig.apiKey}',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://shph.app',
            'X-Title': 'SHPH',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List;
      if (choices.isNotEmpty) {
        final content = choices[0]['message']['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
    }

    throw Exception(
      response.statusCode == 200
          ? 'Empty response from AI'
          : 'AI service returned status ${response.statusCode}',
    );
  }

  Future<List<ServiceListing>> getRecommendations({
    String? query,
    int limit = 6,
  }) async {
    try {
      final services = await ServiceListingService.instance
          .fetchServiceListings(search: query, pageSize: 20);
      if (services.isEmpty) {
        return [];
      }

      if (!isAvailable || query == null || query.trim().isEmpty) {
        return services.take(limit).toList();
      }

      final serviceList = services
          .map((s) => '- ${s.title} (₱${s.basePrice?.toStringAsFixed(0) ?? 'N/A'}, category: ${s.categoryName ?? 'General'})')
          .join('\n');

      final prompt = '''
You are a service recommendation engine for SHPH (Serbisyo Hub PH), a home services platform in the Philippines.

User request: "$query"

Available services:
$serviceList

Return ONLY a JSON array of the most relevant service titles (max $limit) based on the user's request. Format: ["Service Title 1", "Service Title 2", ...]
If none match, return an empty array []. Do not include any other text.
''';

      final result = await chat(query, systemPrompt: prompt);
      final cleaned = result.trim();
      final jsonStart = cleaned.indexOf('[');
      final jsonEnd = cleaned.lastIndexOf(']');
      if (jsonStart == -1 || jsonEnd == -1) {
        return services.take(limit).toList();
      }

      final jsonStr = cleaned.substring(jsonStart, jsonEnd + 1);
      final List<dynamic> titles = jsonDecode(jsonStr);
      final titleSet = titles.map((e) => e.toString().trim()).toSet();

      final matched = <ServiceListing>[];
      final seen = <String>{};
      for (final service in services) {
        if (titleSet.contains(service.title.trim()) &&
            seen.add(service.title)) {
          matched.add(service);
          if (matched.length >= limit) break;
        }
      }

      return matched.isNotEmpty ? matched : services.take(limit).toList();
    } catch (e) {
      LoggingService.error('AI recommendation failed: $e', tag: 'AIService');
      try {
        return (await ServiceListingService.instance
                .fetchServiceListings(pageSize: limit))
            .take(limit)
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<String> bookingSystemPrompt() async {
    final uid = currentUserUid;
    String userInfo = '';
    if (uid.isNotEmpty) {
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('display_name, first_name, city, province')
            .eq('id', uid)
            .single();
        userInfo = '''
USER INFORMATION:
- Name: ${profile['display_name'] ?? profile['first_name'] ?? 'User'}
- Location: ${profile['city'] ?? 'Unknown'}, ${profile['province'] ?? ''}
''';
      } catch (_) {}
    }

    return '''
You are a helpful booking assistant for SHPH (Serbisyo Hub PH), a home services platform in the Philippines.
Help users find services, answer questions about booking, and provide recommendations.

$userInfo
SERVICES AVAILABLE: Cleaning, Plumbing, Electrical, Carpentry, Painting, Appliance Repair, HVAC, Gardening, Moving, Pest Control

BOOKING INFO:
- Users browse categories, select services, choose date/time, and book
- Live matching finds nearby providers in real-time
- Booking statuses: confirmed, en_route, on_site, in_progress, completed, cancelled
- Payment: credit/debit cards, GCash, Maya
- Provider tracking: Real-time map with ETA

Keep responses friendly and concise. Use the user's name when known.
''';
  }
}
