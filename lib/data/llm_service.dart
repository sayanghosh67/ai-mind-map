import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/constants.dart';
import '../domain/models/mind_map_node.dart';

class LLMService {
  static const String _groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';

  /// Single-call approach: Llama 4 Scout reads image AND produces JSON mindmap directly
  Future<MindMapNode> generateMindMapFromImage(XFile imageFile, {String? groqKey}) async {
    final activeGroqKey = AppConstants.groqApiKey.isNotEmpty
        ? AppConstants.groqApiKey
        : (groqKey ?? '');

    if (activeGroqKey.isEmpty) {
      return _errorMindMap('Missing Groq API Key.');
    }

    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      // Single call: vision model reads image AND outputs JSON mind map directly
      final response = await http.post(
        Uri.parse(_groqEndpoint),
        headers: {
          'Authorization': 'Bearer $activeGroqKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': AppConstants.visionSystemPrompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            }
          ],
          'temperature': 0.1,
          'max_tokens': 2048,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String content = data['choices'][0]['message']['content'] ?? '';
        return _parseJsonToMindMap(content);
      } else {
        // If vision model fails, try text-only fallback (Groq logic model)
        print('Vision model failed (${response.statusCode}): ${response.body}');
        return _fallbackTextMindMap(activeGroqKey, 'Could not read image. Please describe your notes.');
      }
    } catch (e) {
      print('LLMService Error: $e');
      return _errorMindMap('Error: $e');
    }
  }

  /// Fallback: text-only Groq call (no vision needed)
  Future<MindMapNode> _fallbackTextMindMap(String apiKey, String text) async {
    try {
      final response = await http.post(
        Uri.parse(_groqEndpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'system', 'content': AppConstants.systemPrompt},
            {'role': 'user', 'content': 'Create a JSON mind map for: $text'},
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.1,
          'max_tokens': 2048,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String content = data['choices'][0]['message']['content'];
        return _parseJsonToMindMap(content);
      } else {
        return _errorMindMap('Groq Error: ${response.statusCode}');
      }
    } catch (e) {
      return _errorMindMap('Fallback failed: $e');
    }
  }

  /// Robust JSON parser — extracts JSON even if wrapped in markdown code blocks
  MindMapNode _parseJsonToMindMap(String content) {
    try {
      // Strip markdown code fences if present
      String cleaned = content.trim();
      if (cleaned.contains('```json')) {
        cleaned = cleaned.split('```json').last.split('```').first.trim();
      } else if (cleaned.contains('```')) {
        cleaned = cleaned.split('```').where((s) => s.trim().isNotEmpty).first.trim();
      }

      // Find the first { and last } to extract pure JSON
      final int start = cleaned.indexOf('{');
      final int end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        cleaned = cleaned.substring(start, end + 1);
      }

      final Map<String, dynamic> json = jsonDecode(cleaned);
      return MindMapNode.fromJson(json);
    } catch (e) {
      print('JSON parse error: $e\nContent: $content');
      return _errorMindMap('Could not parse AI response. Please try again.');
    }
  }

  /// Error mind map for display
  MindMapNode _errorMindMap(String message) {
    return MindMapNode(
      id: 'root',
      label: 'Generation Failed',
      children: [
        MindMapNode(
          id: 'err1',
          label: message,
          children: [],
        ),
        MindMapNode(
          id: 'tip',
          label: 'Tips',
          children: [
            MindMapNode(id: 'tip1', label: 'Use a clear, well-lit photo'),
            MindMapNode(id: 'tip2', label: 'Check your Groq API key in Settings'),
            MindMapNode(id: 'tip3', label: 'Try again with a smaller section'),
          ],
        ),
      ],
    );
  }

  // Deprecated shim
  Future<MindMapNode> generateMindMap(String text) async {
    return _errorMindMap('Use image upload to generate mind maps.');
  }
}
