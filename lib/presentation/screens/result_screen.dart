import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../domain/providers/app_providers.dart';
import '../widgets/mind_map_widget.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  bool isExporting = false;

  Future<void> _shareMindMap() async {
    setState(() => isExporting = true);
    try {
      final imageContext = await screenshotController.capture(delay: const Duration(milliseconds: 10));
      if (imageContext != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('\${directory.path}/mindmap_\${DateTime.now().millisecondsSinceEpoch}.png').create();
        await imagePath.writeAsBytes(imageContext);

        await Share.shareXFiles(
          [XFile(imagePath.path)], 
          text: 'Check out my generated AI Mind Map!'
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mindMapAsync = ref.watch(mindMapProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Mind Map', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isExporting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareMindMap,
              tooltip: 'Share Mind Map',
            ),
        ],
      ),
      body: mindMapAsync.when(
        data: (mindMapNode) {
          return Screenshot(
            controller: screenshotController,
            child: MindMapWidget(rootNode: mindMapNode),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'AI is generating your mind map...',
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Failed to generate mind map',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Invalidate provider to retry
                    ref.invalidate(mindMapProvider);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
