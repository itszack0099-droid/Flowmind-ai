# FlowMind AI ⚡
### Your Personal AI Mentor for Students

![Flutter](https://img.shields.io/badge/Flutter-3.19-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📱 About
FlowMind AI is a Gen Z productivity app powered by AI. It helps students organize their chaotic thoughts, plan their day, and level up their productivity — like having a personal AI mentor in your pocket.

## ✨ Features
- 🌪️ AI Brain Dump — speak or type anything, AI organizes it
- 🗓️ Focus Architect — personalized daily schedule
- 💬 AI Mentor Chat — ask anything, get mentor-level answers
- ⚔️ Exam War Room — battle plan for every exam
- 🎮 XP System — gamified productivity
- 📊 Analytics — track your progress

## 🎨 Design
- Glassmorphism UI
- Dark & Light mode
- Smooth animations
- Bottom navigation

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.19+
- Dart 3.0+
- Android Studio / VS Code

### Installation
```bash
# Clone the repo
git clone https://github.com/itszack0099-droid/Flowmind-ai.git
cd Flowmind-ai

# Install dependencies
flutter pub get

# Create .env file
cp .env.example .env
# Add your API keys in .env

# Run the app
flutter run
```

### Build APK manually
```bash
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🤖 Automatic APK Build (GitHub Actions)
Every time you push to `main` branch:
1. GitHub automatically builds the APK
2. Go to **Actions** tab in GitHub
3. Click the latest workflow run
4. Download APK from **Artifacts** section

---

## 🔑 Environment Variables
Create a `.env` file in root:
```
GROQ_API_KEY=your_groq_api_key
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

---

## 📁 Project Structure
```
lib/
├── main.dart              # App entry point
├── theme/
│   └── app_theme.dart     # Colors, fonts, themes
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   └── login_screen.dart
└── widgets/
    ├── glass_card.dart    # Reusable glass components
    └── orb_background.dart # Gradient orb background
```

---

## 👨‍💻 Developer
Built by **Nike** (Syed Furqan) — Founder, Halalbillionaires

---

## 📄 License
MIT License
