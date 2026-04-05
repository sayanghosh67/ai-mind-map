# AI Mind Map Generator: App Improvement & Redesign Plan

This plan outlines the systematic redesign and enhancement of the "AI Mind Map Generator" to transform it into a professional, production-ready application.

## 1. UI Redesign Suggestions
- **Color Palette:** Transition to a modern, deep theme using a "Deep Navy and Purple" base with "Neon Cyan" highlights (`#6200EA`, `#00E5FF`, `#151624`). 
- **Typography:** Adopt `Poppins` or `Inter` for clean, modern text rendering. Reduced body text size and increased header prominence.
- **Card UI & Shadows:** Use large border radii (`20px`) and soft, diffused shadows to simulate depth and glassmorphism.
- **Micro-Interactions:** Apply scale animations (`onTapDown`, `onTapUp`) on cards and buttons. Add a shimmer effect to the splash screen and loading states.
- **Splash Screen:** Use a rich animated gradient, a prominent icon, and a fluid fade/scale intro sequence.

## 2. Feature Implementation Plan
- **Phase 1: UI/UX Overhaul (In Progress)**
  - Redesign Splash and Home screens with the new typography, color palette, and animated cards.
- **Phase 2: Core Processing & AI Upgrades**
  - Integrate AI Prompts that enforce an optimized, hierarchical JSON structure (avoiding redundancy and enabling auto-summary/topic clustering).
- **Phase 3: Interactive Mind Map Engine**
  - Enhance the Mind Map widget to support pinch-to-zoom and drag/pan (using `InteractiveViewer`).
  - Add tap-to-expand/collapse capabilities.
- **Phase 4: Export & Share**
  - Implement export via `screenshot` or `pdf` packages and share via `share_plus`.
- **Phase 5: Advanced "WOW" Feature**
  - Add **Voice -> Mind Map**: Use `speech_to_text` to transcribe a spoken lecture or summary live, then process it via the AI engine into a map.

## 3. Recommended Flutter Packages
- **Core UI & Animations:** `flutter_animate` (for seamless micro-interactions), `google_fonts`
- **Mind Map & Interaction:** `graphview` (existing, but heavily customized) or build a custom Canvas implementation, `interactive_viewer` (built-in Flutter widget).
- **Export & Sharing:** `screenshot` (to capture map widget), `pdf` (for document generation), `share_plus` (for cross-platform sharing), `path_provider`.
- **AI & Processing:** `google_mlkit_text_recognition` (existing, can be tuned), `speech_to_text` (for Voice input), `image_cropper` (for preprocessing).

## 4. Code Structure Improvements
- Separate complex map parsing logic from the UI.
- Use strict typing for the parsed JSON (create Dart data classes like `MindMapNode` with a `children` list) instead of raw `Map<String, dynamic>`.
- Isolate heavy OCR/API processing from the main thread using `compute()` to prevent UI freezing.

## 5. Best Practices for Production-Level App
- **Error Handling:** Implement comprehensive `try-catch` blocks with user-friendly snackbars and retry buttons.
- **State Feedback:** Always display progress indicators (e.g., "Extracting text...", "Structuring Data...") rather than a static spinner.
- **Accessibility:** Ensure high contrast in Dark Theme, use `Semantics` widgets for screen readers on the mind map nodes.
