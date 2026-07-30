import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/services/ai_service.dart';

class AIBookingComposerService {
  AIBookingComposerService._();
  static final instance = AIBookingComposerService._();

  Future<Map<String, String?>> composeBooking({
    required String prompt,
    String? imageBase64,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt();

      var userMessage = prompt;
      if (imageBase64 != null) {
        userMessage +=
            '\n\n[Image included: analyze this image and extract booking details. '
            'Image data is base64 encoded.]';
      }

      final response = await AIService.instance.chat(
        userMessage,
        systemPrompt: systemPrompt,
      );

      final cleaned = response
          .replaceAll(RegExp(r'^```json\s*'), '')
          .replaceAll(RegExp(r'\s*```$'), '')
          .trim();

      final jsonStart = cleaned.indexOf('{');
      final jsonEnd = cleaned.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) {
        return _emptyResult();
      }

      final parsed =
          jsonDecode(cleaned.substring(jsonStart, jsonEnd + 1))
              as Map<String, dynamic>;

      return {
        'service_name': parsed['service_name'] as String?,
        'description': parsed['description'] as String?,
        'estimated_budget': parsed['estimated_budget'] as String?,
        'preferred_date': parsed['preferred_date'] as String?,
        'preferred_time': parsed['preferred_time'] as String?,
        'location_notes': parsed['location_notes'] as String?,
      };
    } catch (e) {
      debugPrint('AI composer error: $e');
      return _emptyResult();
    }
  }

  Map<String, String?> _emptyResult() => {
        'service_name': null,
        'description': null,
        'estimated_budget': null,
        'preferred_date': null,
        'preferred_time': null,
        'location_notes': null,
      };

  String _buildSystemPrompt() {
    return '''
You are a booking assistant for a home services platform in the Philippines called SerbisyoHub PH.
Extract structured data from the user's request. 
Return ONLY valid JSON with these fields:
- service_name: the type of service needed (e.g., "Plumbing Repair", "Aircon Cleaning")
- description: brief description of what needs to be done
- estimated_budget: budget range if provided (e.g., "1500-3000")
- preferred_date: preferred date (YYYY-MM-DD format)
- preferred_time: preferred time (HH:MM format)
- location_notes: any location details

Use null for missing fields. No other text outside the JSON.
''';
  }
}
