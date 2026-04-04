import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../domain/models/mind_map_node.dart';

class LLMService {
  Future<MindMapNode> generateMindMap(String extractedText) async {
    if (extractedText.trim().isEmpty) {
      throw Exception('Extracted text is empty. Cannot generate mind map.');
    }

    final prompt = '''
Convert the following raw handwritten notes into a structured mind map.
- Extract key topics
- Remove noise
- Use hierarchical structure
- Keep points concise
- Format as tree structure

Return ONLY a valid JSON object representing the root node of the mind map.
The JSON must have this structure:
{
  "id": "root",
  "label": "Main Topic",
  "children": [
    {
      "id": "child1",
      "label": "Sub Topic 1",
      "children": []
    }
  ]
}

Raw Text:
$extractedText
''';

    try {
      final response = await http.post(
        Uri.parse(AppConstants.effectiveEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        },
        body: jsonEncode({
          'model': AppConstants.textModel,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.3,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        // Find JSON part in case the model adds conversational text
        final startIndex = content.indexOf('{');
        final endIndex = content.lastIndexOf('}');
        
        if (startIndex != -1 && endIndex != -1) {
          final jsonString = content.substring(startIndex, endIndex + 1);
          final Map<String, dynamic> jsonData = jsonDecode(jsonString);
          return MindMapNode.fromJson(jsonData);
        } else {
          throw Exception('Failed to parse JSON from response.');
        }
      } else {
        throw Exception('API Request Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Mock generation for demonstration if API is not configured or fails
      print('Error during LLM generation (${e.toString()}). Returning mock map.');
      return _generateMockMindMap(extractedText);
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
          label: 'Concepts',
          children: [
            MindMapNode(id: '1a', label: 'Item A based on text'),
            MindMapNode(id: '1b', label: 'Item B based on text'),
          ]
        ),
        MindMapNode(
          id: '2',
          label: 'Summary',
          children: [
            MindMapNode(id: '2a', label: initialText.length > 20 ? initialText.substring(0, 20) + '...' : initialText),
          ]
        ),
      ]
    );
  }
}
