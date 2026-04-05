import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> extractTextFromImage(XFile imageFile) async {
    // If Web, use Gemini Vision since ML Kit doesn't support Web
    if (kIsWeb) {
      return await _extractTextViaGeminiVision(imageFile);
    }
    
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.trim().isEmpty) {
        // If ML Kit finds nothing, try Gemini Vision as a smart fallback
        return await _extractTextViaGeminiVision(imageFile);
      }
      
      return recognizedText.text;
    } catch (e) {
      print('ML Kit Error: $e. Falling back to Gemini Vision...');
      try {
        return await _extractTextViaGeminiVision(imageFile);
      } catch (geminiError) {
        throw Exception('OCR failed on both ML Kit and Gemini: $geminiError');
      }
    }
  }

  // Uses Gemini 1.5 Flash for high-accuracy Vision OCR
  Future<String> _extractTextViaGeminiVision(XFile imageFile) async {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey == 'YOUR_GEMINI_API_KEY' || apiKey.isEmpty) {
      throw Exception('Gemini API key not configured for Vision OCR.');
    }

    try {
      final model = GenerativeModel(
        model: AppConstants.textModel, // gemini-1.5-flash supports vision
        apiKey: apiKey,
      );

      final bytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart('Extract all readable text from this handwritten note image. Return ONLY the extracted text, nothing else. No conversational filler.'),
          DataPart('image/jpeg', bytes),
        ])
      ];

      final response = await model.generateContent(content);
      return response.text ?? '';
    } catch (e) {
      print('Gemini Vision OCR Error: $e');
      throw Exception('Gemini Vision OCR failed: $e');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
