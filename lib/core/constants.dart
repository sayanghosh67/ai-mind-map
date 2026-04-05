class AppConstants {
  // Groq API Key (free tier)
  // API key is entered by the user via the Settings dialog in the app
  static const String groqApiKey = '';

  // Vision model (single-call: reads image + outputs JSON mind map)
  static const String groqVisionModel = 'meta-llama/llama-4-scout-17b-16e-instruct';
  // Fallback text-only model
  static const String groqTextModel = 'llama-3.3-70b-versatile';

  /// System prompt for vision model — reads image AND returns JSON mind map in one call
  static const String visionSystemPrompt = '''
You are an expert at reading handwritten notes and creating structured Mind Maps.
Look at this handwritten note image, extract ALL the text you can see, then organize it into a JSON mind map.

Output ONLY valid JSON in this exact format (no markdown, no explanation):
{
  "id": "root",
  "label": "Main Topic from Notes",
  "children": [
    {
      "id": "1",
      "label": "Key Point 1",
      "children": [
        {"id": "1a", "label": "Detail", "children": []}
      ]
    },
    {
      "id": "2",
      "label": "Key Point 2",
      "children": []
    }
  ]
}

Rules:
- Output ONLY the JSON object. No preamble, no explanation.
- All IDs must be unique strings.
- Keep labels concise (under 60 characters).
- Create at least 3-5 top-level children from the notes.
- If handwriting is unclear, make your best guess.
''';

  /// Text-only fallback prompt
  static const String systemPrompt = '''
You are an expert at creating structured Mind Maps from text notes.
Convert the provided text into a valid JSON hierarchical mind map.
Output ONLY the JSON object. No markdown, no explanation.

Format:
{
  "id": "root",
  "label": "Main Topic",
  "children": [
    {"id": "1", "label": "Sub Topic", "children": [...]}
  ]
}

Rules: Output ONLY JSON. All IDs unique. Labels concise (under 60 chars).
''';
}
