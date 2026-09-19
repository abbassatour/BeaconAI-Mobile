// lib/core/services/ai_vision_client.dart

import 'dart:convert';
import 'dart:developer';
import 'package:beacon_ai/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

/// Service managing multimodal requests to Gemini 1.5 Flash via OpenRouter.
class AiVisionClient {
  AiVisionClient._();
  static final AiVisionClient instance = AiVisionClient._();

  static const String _endpoint = 'https://openrouter.ai/api/v1/chat/completions';

  /// System prompt strictly engineering the model to act as a concise spatial guide for the blind.
  static const String _systemPrompt = '''
You are BeaconAI, a spatial vision assistant for visually impaired users.
RULES:
1. Reply in EXACTLY one or two very short sentences.
2. NEVER use markdown (no asterisks, hash signs, etc).
3. If they ask about money/currency, just say the value.
4. If they ask about expiration dates, just say the date.
5. If they ask "where is my X", just say "It is slightly to the left/right/front of the camera view".
6. Be direct, clear, and extremely concise. No greetings, no filler words.
''';

  /// Sends the user's spoken [query] along with the captured [base64Image] to Gemini.
  Future<String> analyzeImage({
    required String query,
    required String base64Image,
  }) async {
    final apiKey = ApiConstants.openRouterApiKey;
    if (apiKey.isEmpty || apiKey.contains('YOUR_OPENROUTER')) {
      return 'Vision capability requires an OpenRouter API key. Please configure the environment file.';
    }

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://github.com/abbassatour/BeaconAI-Mobile',
          'X-Title': 'BeaconAI Mobile',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'google/gemini-1.5-flash',
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt,
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': query.isEmpty ? 'What is exactly in front of me?' : query,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['choices'][0]['message']['content'] as String;
        return answer.trim();
      } else {
        log('AiVisionClient Error: [${response.statusCode}] ${response.body}');
        return 'I encountered a network issue while analyzing the image. Please try again.';
      }
    } catch (e, st) {
      log('AiVisionClient Exception: $e', stackTrace: st);
      return 'I am currently offline and cannot process images.';
    }
  }
}