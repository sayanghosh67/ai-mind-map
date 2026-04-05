import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // Get your FREE API key from https://aistudio.google.com/app/apikey
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_GEMINI_API_KEY');

  // Gemini Models
  static const String textModel = 'gemini-2.5-flash';
  
  // Base prompt for the AI
  static const String systemPrompt = '''
    You are an expert at creating structured Mind Maps from notes.
    Convert the provided text into a valid JSON hierarchical structure.
    Strictly follow this JSON format:
    {
      "id": "root",
      "label": "Main Topic",
      "children": [
        {
          "id": "unique_id_1",
          "label": "Sub Topic",
          "children": []
        }
      ]
    }
    Rules:
    1. Output ONLY the JSON object.
    2. Ensure IDs are unique.
    3. Keep labels concise.
  ''';
}
