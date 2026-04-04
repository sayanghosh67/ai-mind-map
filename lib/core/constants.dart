import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  // Get your FREE API key from https://console.groq.com/keys
  // Sign up at groq.com - no credit card needed!
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: 'YOUR_GROQ_API_KEY');

  // Groq endpoints (OpenAI-compatible)
  static const String groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';

  // Models
  static const String textModel = 'llama-3.3-70b-versatile';
  static const String visionModel = 'meta-llama/llama-4-scout-17b-16e-instruct';

  static String get effectiveEndpoint {
    if (kIsWeb) {
      return 'https://corsproxy.io/?$groqEndpoint';
    }
    return groqEndpoint;
  }
}
