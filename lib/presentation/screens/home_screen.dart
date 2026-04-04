import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/providers/app_providers.dart';
import 'processing_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        ref.read(originalImageProvider.notifier).state = image;
        
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProcessingScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mind Map Generator'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Convert Your Notes\nInto Visual Knowledge',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Take a picture of your handwritten notes or upload an existing image to generate an interactive mind map.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _buildActionButton(
                context: context,
                icon: Icons.camera_alt_outlined,
                title: 'Capture Notes',
                subtitle: 'Take a photo of your handwritten notes',
                onTap: () => _pickImage(context, ref, ImageSource.camera),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                context: context,
                icon: Icons.image_outlined,
                title: 'Upload Image',
                subtitle: 'Choose an image from your gallery',
                onTap: () => _pickImage(context, ref, ImageSource.gallery),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.link, color: Colors.blue),
                    onPressed: () async {
                      final url = Uri.parse('https://www.linkedin.com/in/sayan-ghosh97/');
                      if (!await launchUrl(url)) {
                        debugPrint('Could not launch \$url');
                      }
                    },
                    tooltip: 'LinkedIn',
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.pink),
                    onPressed: () async {
                      final url = Uri.parse('https://www.instagram.com/sayan_ghosh97/');
                      if (!await launchUrl(url)) {
                        debugPrint('Could not launch \$url');
                      }
                    },
                    tooltip: 'Instagram',
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'App made by Sayan Ghosh\nAll copyrights reserved by Sayan Ghosh © 2026',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
