import 'dart:convert';

import 'package:flutter/foundation.dart';

class AIBookingComposerService {
  AIBookingComposerService._();
  static final instance = AIBookingComposerService._();

  Future<Map<String, String?>> composeBooking({
    required String prompt,
    String? imageBase64,
  }) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content':
              'You are a booking assistant for a home services platform. '
              'Extract structured data from the user\'s request. '
              'Return ONLY valid JSON with fields: service_name, description, '
              'estimated_budget, preferred_date, preferred_time, location_notes. '
              'Use null for missing fields.',
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ];

      if (imageBase64 != null) {
        messages.add({
          'role': 'user',
          'content': 'Analyze this image and extract booking details. Image data: base64 encoded.',
        });
      }

      // Use AI service endpoint
      final response = await _callOpenRouter(messages);

      final text = response['choices']?[0]?['message']?['content'] as String?;
      if (text == null) return _emptyResult();

      final cleaned = text
          .replaceAll(RegExp(r'^```json\s*'), '')
          .replaceAll(RegExp(r'\s*```$'), '')
          .trim();

      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
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

  Future<Map<String, dynamic>> _callOpenRouter(
      List<Map<String, dynamic>> messages) async {
    // Placeholder — will integrate with actual OpenRouter API
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'choices': [
        {
          'message': {
            'content': jsonEncode({
              'service_name': 'Plumbing Repair',
              'description': 'Leaking pipe under kitchen sink needs repair',
              'estimated_budget': '1500-3000',
              'preferred_date': '2026-07-28',
              'preferred_time': '10:00',
              'location_notes': null,
            }),
          },
        },
      ],
    };
  }
}
