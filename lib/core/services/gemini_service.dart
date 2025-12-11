import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:math';

/// Service for AI-powered content generation using Gemini.
class GeminiService {
  GenerativeModel? _model;

  /// Initialize the Gemini model.
  void initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null) {
      _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    }
  }

  /// Generate a motivational brain fact.
  /// Returns a map with 'fact' and 'source' keys.
  Future<Map<String, String>> getGenerativeBrainFact() async {
    if (_model == null) {
      return _fallbackFact('Reclaim (Offline - Missing API Key)');
    }

    try {
      // Define different "flavors" of motivation
      final themes = [
        'a stoic philosophical quote about discipline and self-control',
        'a "tough love" statement about not wasting one\'s potential',
        'a visionary insight about the benefits of mental clarity and focus',
        'a short psychological trick to beat urges',
      ];

      // Pick one randomly
      final randomTheme = themes[Random().nextInt(themes.length)];

      // Send the dynamic prompt
      final prompt =
          'Provide exactly one short, powerful sentence (under 25 words) that acts as $randomTheme. '
          'Do not use intro text. Do not be cheesy. Make it sound intense and grounding. Use regular diction.';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text != null) {
        return {
          'fact': response.text!.replaceAll('"', '').trim(),
          'source': 'Gemini AI',
        };
      } else {
        throw Exception('Empty response');
      }
    } catch (e) {
      return _fallbackFact('Reclaim (Offline)');
    }
  }

  Map<String, String> _fallbackFact(String source) {
    return {
      'fact':
          'Discipline is choosing what you want most over what you want now.',
      'source': source,
    };
  }
}
