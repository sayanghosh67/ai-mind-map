import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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

  Future<void> _shareMindMap(bool asPdf) async {
    if (isExporting) return;
    setState(() => isExporting = true);
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 300),
        pixelRatio: 2.0,
      );

      if (imageBytes == null) throw Exception('Could not capture screenshot.');

      if (asPdf) {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context ctx) => pw.Center(child: pw.Image(pw.MemoryImage(imageBytes))),
          ),
        );
        final pdfBytes = await pdf.save();
        final fileName = 'mindmap_${DateTime.now().millisecondsSinceEpoch}.pdf';
        await Share.shareXFiles(
          [XFile.fromData(pdfBytes, name: fileName, mimeType: 'application/pdf')],
          text: 'AI Mind Map',
        );
      } else {
        final fileName = 'mindmap_${DateTime.now().millisecondsSinceEpoch}.png';
        await Share.shareXFiles(
          [XFile.fromData(imageBytes, name: fileName, mimeType: 'image/png')],
          text: 'AI Mind Map',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mindMapNode = ref.watch(mindMapResultProvider);
    final theme = Theme.of(context);

    // Safety: if no result yet, go back
    if (mindMapNode == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Map', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isExporting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () => _shareMindMap(false),
              tooltip: 'Share as Image',
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _shareMindMap(true),
              tooltip: 'Share as PDF',
            ),
          ],
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: Container(
          color: theme.colorScheme.surface,
          child: MindMapWidget(rootNode: mindMapNode),
        ),
      ),
    );
  }
}
