import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/providers/app_providers.dart';
import 'result_screen.dart';

class VoiceInputScreen extends ConsumerStatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  ConsumerState<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends ConsumerState<VoiceInputScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      if (mounted) {
        setState(() {
          _lastWords = result.recognizedWords;
        });
      }
    });
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _generateMindMap() async {
    if (_lastWords.isEmpty) return;

    setState(() => _isProcessing = true);
    
    // Simulate setting the extracted text directly for the AI provider to use
    ref.read(extractedTextProvider.notifier).state = _lastWords;
    
    // ResultScreen will use the mindMapProvider which depends on extractedTextProvider
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Voice to Mind Map'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Speak your thoughts',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _lastWords.isEmpty
                          ? 'Tap the microphone to start listening...'
                          : _lastWords,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _lastWords.isEmpty 
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5) 
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _speechToText.isNotListening ? _startListening : _stopListening,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isListening ? Colors.redAccent : Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? Colors.redAccent : Theme.of(context).colorScheme.primary).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: _isListening ? 10 : 5,
                            )
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ).animate(target: _isListening ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
                    if (_lastWords.isNotEmpty && !_isListening)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _generateMindMap,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Generate Map', style: TextStyle(fontWeight: FontWeight.bold)),
                      ).animate().fadeIn().slideX(),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
