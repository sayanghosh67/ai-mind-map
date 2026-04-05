import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../domain/providers/app_providers.dart';
import 'processing_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isHoveringCamera = false;
  bool _isHoveringGallery = false;

  Future<void> _pickImage(WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        ref.read(originalImageProvider.notifier).state = image;
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProcessingScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'AI Mind Map',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to history stub (TODO)
            },
            tooltip: 'History',
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Convert Your Notes\nInto Knowledge',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onBackground,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),
              Text(
                'Capture handwritten notes or upload an image to generate a structured, interactive mind map using AI.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const Spacer(),
              _buildActionButton(
                icon: Icons.camera_alt_outlined,
                title: 'Capture Notes',
                subtitle: 'Take a photo of your handwriting',
                gradientColors: [theme.colorScheme.primary, theme.colorScheme.primary.withAlpha(200)],
                isHovering: _isHoveringCamera,
                onHover: (val) => setState(() => _isHoveringCamera = val),
                onTap: () => _pickImage(ref, ImageSource.camera),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideX(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.image_outlined,
                title: 'Upload Image',
                subtitle: 'Choose from your gallery',
                gradientColors: [const Color(0xFF1E88E5), const Color(0xFF64B5F6)],
                isHovering: _isHoveringGallery,
                onHover: (val) => setState(() => _isHoveringGallery = val),
                onTap: () => _pickImage(ref, ImageSource.gallery),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideX(begin: -0.1, end: 0),
              const Spacer(),
              _buildFooter().animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required bool isHovering,
    required ValueChanged<bool> onHover,
    required VoidCallback onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setBtnState) {
        bool isPressed = false;
        return GestureDetector(
          onTapDown: (_) => setBtnState(() => isPressed = true),
          onTapUp: (_) => setBtnState(() => isPressed = false),
          onTapCancel: () => setBtnState(() => isPressed = false),
          onTap: onTap,
          child: MouseRegion(
            onEnter: (_) => onHover(true),
            onExit: (_) => onHover(false),
            child: AnimatedScale(
              scale: isPressed ? 0.95 : (isHovering ? 1.02 : 1.0),
              duration: const Duration(milliseconds: 150),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: isHovering ? gradientColors.map((c) => c.withOpacity(0.85)).toList() : gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(isHovering ? 0.4 : 0.2),
                      blurRadius: isHovering ? 20 : 10,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.linkedinIn, color: Color(0xFF0077B5)),
              onPressed: () => launchUrl(Uri.parse('https://www.linkedin.com/in/sayan-ghosh97/')),
              tooltip: 'LinkedIn',
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFE4405F)),
              onPressed: () => launchUrl(Uri.parse('https://www.instagram.com/sayan_ghosh97/')),
              tooltip: 'Instagram',
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'App designed & developed by Sayan Ghosh\n© 2026',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
