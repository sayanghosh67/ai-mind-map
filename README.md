# AI Handwritten Notes to Mind Map Generator

A production-ready Flutter application that captures handwritten notes, processes them via OCR using Google ML Kit, structures the concepts using LLM, and renders them as an interactive mind map using `graphview`.

## Prerequisites

- Flutter SDK (>=3.0.0 <4.0.0)
- Dart SDK
- macOS with Xcode (for iOS builds) or Android Studio (for Android builds)
- An active OpenAI API Key

## Setup & Running Locally

1. **Install Dependencies**
   Run the following command at the root of the project:
   ```bash
   flutter pub get
   ```

2. **Configure API Keys**
   Open `lib/core/constants.dart` and insert your OpenAI API Key:
   ```dart
   static const String openAiApiKey = 'YOUR_API_KEY_HERE';
   ```

3. **Run the App**
   To run the app on a connected device or an emulator:
   ```bash
   flutter run
   ```

## Build Instructions (Android APK)

To build a release APK for Android, run:
```bash
flutter build apk --release
```
The output file will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

## Architecture

- **Clean Architecture** combined with **Riverpod**
- **Domain:** Models (`MindMapNode`), Providers (`app_providers.dart`)
- **Data:** `OCRService` via Google ML Kit, `LLMService` via OpenAI API
- **Presentation:** Material 3 screens, Splash, Home, Processing, Result
- **Widgets:** MindMap Graph viewer powered by `graphview`

## Future Features

- PDF Export (stubbed in ResultScreen)
- Real-time Collaboration
- Cloud Sync
- User Authentication
