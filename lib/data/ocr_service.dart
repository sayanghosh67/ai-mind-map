import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> extractTextFromImage(XFile imageFile) async {
    if (kIsWeb) {
      return await _extractTextViaVisionAPI(imageFile);
    }
    
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      // Fallback to Vision API if ML Kit fails and API Key is configured
      if (AppConstants.groqApiKey != 'YOUR_GROQ_API_KEY') {
        return await _extractTextViaVisionAPI(imageFile);
      }
      throw Exception('Failed to extract text: $e');
    }
  }

  // Web-friendly OCR using Groq Vision API (Llama 3.2 Vision) since ML Kit doesn't support Web
  Future<String> _extractTextViaVisionAPI(XFile imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(AppConstants.effectiveEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        },
        body: jsonEncode({
          'model': AppConstants.visionModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Extract all readable text from this handwritten note image. Return ONLY the extracted text, nothing else. No explanations.'
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image'
                  }
                }
              ]
            }
          ],
          'temperature': 0.1,
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'] ?? '';
      } else {
        throw Exception('Vision API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Vision OCR Error: $e');
      throw Exception('OCR failed on Web: $e');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
