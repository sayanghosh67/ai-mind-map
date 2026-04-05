import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      if (!mounted) return;
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

      if (!mounted) return;
      setState(() {
        _currentStep = 'AI is structuring the mind map...';
        _progress = 0.7;
      });
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ResultScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Processing Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              Navigator.of(context).pop(); 
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ]
                ),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: null, 
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 6,
                  ),
                ),
              ).animate().shimmer(duration: 1500.ms, color: Colors.white54),
              const SizedBox(height: 48),
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 12,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _currentStep,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey(_currentStep)).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),
              Text(
                'This may take a few moments depending on the complexity of your notes.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
