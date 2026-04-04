import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/app_providers.dart';
import 'result_screen.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  String _currentStep = 'Initializing...';
  double _progress = 0.1;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    final image = ref.read(originalImageProvider);
    if (image == null) {
      _handleError('No image provided');
      return;
    }

    try {
      // Step 1: OCR Processing
      setState(() {
        _currentStep = 'Extracting text from image...';
        _progress = 0.3;
      });
      
      final ocrService = ref.read(ocrServiceProvider);
      final text = await ocrService.extractTextFromImage(image);
      
      if (text.isEmpty) {
        _handleError('No text found in the image. Please try again with a clearer image.');
        return;
      }
      
      ref.read(extractedTextProvider.notifier).state = text;

      setState(() {
        _currentStep = 'AI is structuring the mind map...';
        _progress = 0.7;
      });
      
      // Navigate to Result Screen which will consume the FutureProvider
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ResultScreen()),
        );
      }
    } catch (e) {
      _handleError('Processing Failed: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to Home
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  value: null, // Indeterminate
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 40),
              LinearProgressIndicator(
                value: _progress,
                borderRadius: BorderRadius.circular(8),
                minHeight: 8,
              ),
              const SizedBox(height: 24),
              Text(
                _currentStep,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This may take a few moments depending on the complexity of your notes.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
