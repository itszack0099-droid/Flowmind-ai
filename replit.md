# FlowMind AI

## Overview
FlowMind AI is a Flutter-based Android productivity app for students. It acts as a personal AI mentor with features like AI Brain Dump, Focus Architect, AI Mentor Chat, Exam War Room, XP gamification, and analytics.

## Tech Stack
- **Language:** Dart (SDK >= 3.10.7)
- **Framework:** Flutter 3.27.0+
- **State Management:** Riverpod
- **Backend:** Supabase (auth, database)
- **Local AI:** llamadart ^0.6.10
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
.github/workflows/
└── build-apk.yml          # GitHub Actions APK build pipeline
```

## Building
This is a mobile app — it is built as an Android APK via GitHub Actions:
- Every push to `main`/`master` triggers the APK build automatically
- Download the APK from the **Actions** tab → Artifacts → `FlowMind-APK`

## GitHub Actions Workflow (build-apk.yml)
Key features of the workflow:
- Flutter 3.27.0 (stable), Java 17
- `cache: false` to always use fresh Flutter/Dart SDK
- Disables Flutter analytics (`flutter config --no-analytics`)
- Full cache wipe: `flutter clean`, removes `pubspec.lock` and `~/.pub-cache`
- Runs `flutter pub get` fresh
- Builds with `--no-tree-shake-icons` to avoid icon issues

## Environment Variables
Required secrets (set in Supabase project or .env):
- `SUPABASE_URL` — already hardcoded in main.dart
- `SUPABASE_ANON_KEY` — already hardcoded in main.dart
- `GROQ_API_KEY` — for AI chat features

## Notes
- Dart SDK >= 3.10.7 is required (llamadart dependency)
- The Replit environment runs Flutter 3.32.0 (Nix) with Dart 3.8.0, which is incompatible with the SDK constraint — builds must be done via GitHub Actions
