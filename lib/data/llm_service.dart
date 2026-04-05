import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants.dart';
import '../domain/models/mind_map_node.dart';

class LLMService {
  Future<MindMapNode> generateMindMap(String extractedText) async {
    if (extractedText.trim().isEmpty) {
      throw Exception('No readable text found in the image. Please try capturing a clearer photo with visible text.');
    }

    final apiKey = AppConstants.geminiApiKey;
    if (apiKey == 'YOUR_GEMINI_API_KEY' || apiKey.isEmpty) {
       // Only return fallback if API key is not configured
       print('Gemini API key not configured. Using fallback map.');
       return _generateMockMindMap(extractedText);
    }

    try {
      final model = GenerativeModel(
        model: AppConstants.textModel,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = '${AppConstants.systemPrompt}\n\nRaw Text:\n$extractedText';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        final String rawContent = response.text!;
        
        // Find JSON part in case the model adds conversational text
        final startIndex = rawContent.indexOf('{');
        final endIndex = rawContent.lastIndexOf('}');
        
        if (startIndex != -1 && endIndex != -1) {
          final jsonString = rawContent.substring(startIndex, endIndex + 1);
          final Map<String, dynamic> jsonData = jsonDecode(jsonString);
          return MindMapNode.fromJson(jsonData);
        } else {
          throw Exception('Failed to extract JSON from Gemini response.');
        }
      } else {
        throw Exception('Gemini returned an empty response.');
      }
    } catch (e) {
      print('Error during Gemini generation: $e');
      throw Exception('Failed to generate AI Mind Map. Please ensure your Gemini API key is valid and try again. Details: $e');
    }
  }

  // Fallback map if the LLM request fails. Useful for demonstration until API key is set.
  MindMapNode _generateMockMindMap(String initialText) {
    return MindMapNode(
      id: 'root',
      label: 'Extracted Notes',
      children: [
        MindMapNode(
          id: '1',
          label: 'Concepts Found',
          children: [
            MindMapNode(id: '1a', label: 'Main Concept A'),
            MindMapNode(id: '1b', label: 'Main Concept B'),
          ]
        ),
        MindMapNode(
          id: '2',
          label: 'Context/Summary',
          children: [
            MindMapNode(id: '2a', label: initialText.length > 30 ? initialText.substring(0, 30) + '...' : initialText),
          ]
        ),
      ]
    );
  }
}
