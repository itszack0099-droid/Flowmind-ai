# FlowMind AI

## Overview
FlowMind AI is a Flutter-based Android productivity app for students. It acts as a personal AI mentor with features like AI Brain Dump, Focus Architect, AI Mentor Chat, Exam War Room, XP gamification, and analytics.

## Tech Stack
- **Language:** Dart (SDK >= 3.5.0 <4.0.0)
- **Framework:** Flutter 3.27.0+ (Dart 3.6.0)
- **State Management:** Riverpod
- **Backend:** Supabase (auth, database)
- **Firebase:** firebase_core for notifications
- **Local AI:** Ollama HTTP API (pure Dart, no native deps) — replaces llamadart
- **UI:** Glassmorphism, Google Fonts, animate_do

## Project Structure
```
lib/
├── main.dart              # Entry point, Supabase init, deep links
├── screens/               # All app screens
├── services/              # Business logic (Supabase, LLM, notifications)
├── theme/                 # App theme & colors
├── widgets/               # Reusable UI components
└── utils/                 # Helper utilities
assets/
├── images/                # App images/logos
└── animations/            # Lottie animations
android/
├── gradlew                # Gradle wrapper (executable, committed to repo)
├── app/
│   ├── build.gradle.kts   # App build config (applicationId: com.flowmind.flowmind)
│   └── google-services.json  # Firebase config
└── settings.gradle.kts    # Includes google-services plugin
.github/workflows/
└── build-apk.yml          # GitHub Actions APK build pipeline
```

## Building
This is a mobile app — it is built as an Android APK via GitHub Actions:
- Every push to `main`/`master` triggers the APK build automatically
- Download the APK from the **Actions** tab → Artifacts → `FlowMind-APK`

## GitHub Actions Workflow (build-apk.yml)
Key features of the workflow:
- Flutter 3.27.0 (stable, Dart 3.6.0), Java 17
- `cache: false` to always use fresh Flutter/Dart SDK
- Disables Flutter analytics (`flutter config --no-analytics` + `dart --disable-analytics`)
- Full cache wipe: `flutter clean`, removes `pubspec.lock`, `~/.pub-cache`, `~/.dart`
- `chmod +x android/gradlew` before building
- Builds with `--no-tree-shake-icons` for reliability

## Android Package Info
- Application ID: `com.flowmind.flowmind`
- Firebase Project: `studio-7713288452-31b03`
- Gradle: 8.12, AGP: 8.7.3, Kotlin: 2.1.0

## Environment Variables
- `SUPABASE_URL` — hardcoded in main.dart
- `SUPABASE_ANON_KEY` — hardcoded in main.dart
- `GITHUB_TOKEN` — Replit secret for pushing to GitHub

## AI Architecture
- **No Groq**: All AI processing is handled via local Ollama server — no cloud AI
- **Local LLM**: Ollama running Qwen2.5:0.5b on user's machine (PC/Mac on same WiFi)
- **Pure Dart**: LocalLLMService uses http package only — no native compilation required
- **Configurable**: Users can set Ollama URL and model name from the app's AI setup screen
- **Default URL**: http://10.0.2.2:11434 (Android emulator → host machine)

## Key Fixes Applied
1. **pubspec.yaml SDK constraint**: Changed `>=3.10.7` to `>=3.5.0` (Dart 3.10.7 doesn't exist; Flutter 3.27.0 ships Dart 3.6.0)
2. **android/ directory**: Generated and committed (was completely missing from repo)
3. **.gitignore**: Removed `android/gradlew` entries — CI needs this file
4. **applicationId mismatch**: Fixed `com.example.flowmind` → `com.flowmind.flowmind` to match google-services.json
5. **google-services.json**: Added to `android/app/` directory (required by firebase_core)
6. **Gradle**: Added `com.google.gms.google-services` plugin (required by firebase_core)
7. **Groq removed**: Removed all GROQ_API_KEY references from docs; app uses local LLM only
8. **Build workflow**: Improved CI to copy google-services.json, configure google-services plugin, and set minSdk=24
9. **llamadart removed**: llamadart >=0.2.0 required SDK >=3.10.7 (non-existent), breaking pub get; replaced with pure-Dart Ollama HTTP client — no native deps, builds with any Dart 3.5+
10. **LocalLLMService rewritten**: Now uses Ollama HTTP API; model_downloader checks connectivity; model_download_screen shows Ollama setup UI
