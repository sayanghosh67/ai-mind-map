import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/ocr_service.dart';
import '../../data/llm_service.dart';
import '../models/mind_map_node.dart';

// Services
final ocrServiceProvider = Provider((ref) => OCRService());
final llmServiceProvider = Provider((ref) => LLMService());

// Global State
final extractedTextProvider = StateProvider<String?>((ref) => null);
final selectedImageProvider = StateProvider<XFile?>((ref) => null);
final originalImageProvider = StateProvider<XFile?>((ref) => null);
final isProcessingProvider = StateProvider<bool>((ref) => false);
final processingMessageProvider = StateProvider<String>((ref) => '');

// Async Mind Map Generation State
final mindMapProvider = FutureProvider.autoDispose<MindMapNode>((ref) async {
  final text = ref.watch(extractedTextProvider);
  if (text == null || text.isEmpty) {
    throw Exception('No text available for processing');
  }
  
  final llmService = ref.watch(llmServiceProvider);
  return await llmService.generateMindMap(text);
});
