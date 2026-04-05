import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/providers/app_providers.dart';
import '../../data/llm_service.dart';
import '../../domain/models/mind_map_node.dart';
import 'result_screen.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  String _currentStep = 'Reading your notes...';
  double _progress = 0.2;

  @override
  void initState() {
    super.initState();
    // Run after first frame so context/ref are ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _processImage());
  }

  Future<void> _processImage() async {
    final image = ref.read(originalImageProvider);
    if (image == null) {
      _handleError('No image found. Please go back and try again.');
      return;
    }

    try {
      _setStep('Sending image to Groq AI...', 0.3);
      await Future.delayed(const Duration(milliseconds: 300));

      _setStep('AI is reading your handwriting...', 0.5);

      // Do the actual API call here — no racing with auto providers
      final llmService = LLMService();
      final MindMapNode result = await llmService.generateMindMapFromImage(image);

      if (!mounted) return;
      _setStep('Building your mind map...', 0.9);
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Store result in shared provider so ResultScreen can use it
      ref.read(mindMapResultProvider.notifier).state = result;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ResultScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } catch (e) {
      _handleError('Processing failed: $e');
    }
  }

  void _setStep(String step, double progress) {
    if (!mounted) return;
    setState(() {
      _currentStep = step;
      _progress = progress;
    });
  }

  void _handleError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(ctx).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: null,
                    color: theme.colorScheme.primary,
                    strokeWidth: 6,
                  ),
                ),
              ).animate().shimmer(duration: 1500.ms, color: Colors.white54),
              const SizedBox(height: 48),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 12,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _currentStep,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey(_currentStep)).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),
              Text(
                'Groq AI is processing your handwritten notes.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
