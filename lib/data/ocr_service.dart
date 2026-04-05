import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> extractTextFromImage(XFile imageFile) async {
    // If Web, ML Kit doesn't support Web
    if (kIsWeb) {
      throw Exception('Local OCR is not supported on Web.');
    }
    
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.trim().isEmpty) {
        throw Exception('OCR found no text in the image. Please try a clearer photo.');
      }
      
      return recognizedText.text;
    } catch (e) {
      print('ML Kit Error: $e');
      throw Exception('OCR failed: $e');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
