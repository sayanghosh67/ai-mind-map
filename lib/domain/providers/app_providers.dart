import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/llm_service.dart';
import '../models/mind_map_node.dart';

// Services
final llmServiceProvider = Provider((ref) => LLMService());

// Image state
final originalImageProvider = StateProvider<XFile?>((ref) => null);
final selectedImageProvider = StateProvider<XFile?>((ref) => null);

// Optional user-supplied Groq key (overrides constant)
final groqApiKeyProvider = StateProvider<String>((ref) => '');

// Mind map result set directly by ProcessingScreen after API call
final mindMapResultProvider = StateProvider<MindMapNode?>((ref) => null);
