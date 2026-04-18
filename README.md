# 🏛️ Temple Dash

A Temple Run-inspired endless runner game built with Flutter — featuring a fully painted canvas engine, parallax backgrounds, particle effects, and more.

## 📱 Screenshots

> A mystical endless runner where you dodge obstacles, collect coins, and survive as long as possible through ancient temple ruins.

## 🎮 Features

- **3-Lane Endless Runner** — smooth animated lane switching
- **Swipe Controls** — swipe left/right/up/down or tap zones
- **4 Obstacle Types** — Rock, Fire (animated flames), Stone Wall, Log
- **Power-Ups** — Shield 🛡, Magnet 🧲, Speed Boost ⚡, Double Coins 💰
- **Coins** — glowing collectibles with magnet attraction
- **Particle Effects** — on collision, coin collect, power-up pickup
- **Parallax Scrolling** — multi-layer animated background with temple silhouette, trees, stars
- **Animated Character** — run, jump, slide, dead states
- **Persistent Stats** — high score, total coins, games played (SharedPreferences)
- **Achievements** — 5 unlockable achievements
- **Countdown** — animated 3-2-1-GO! before game starts
- **Speed Ramp** — difficulty increases over time
- **Pause / Resume** system

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.22+
- Dart SDK 3.0+
- Android Studio or VS Code with Flutter extension

### Installation

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/temple_dash.git
cd temple_dash

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# APK location
# build/app/outputs/flutter-apk/app-release.apk
```

## 🤖 GitHub Actions — Automatic APK Build

This project includes a GitHub Actions workflow that automatically builds the APK on every push to `main`.

### Setup Steps

1. Push this project to a GitHub repository
2. Go to **Actions** tab in your repository
3. The **"Build Temple Dash APK"** workflow will run automatically
4. After it completes (~5 minutes), click the workflow run
5. Download the APK from the **Artifacts** section at the bottom

### Manual Trigger

You can also trigger a build manually:
1. Go to **Actions** → **Build Temple Dash APK**
2. Click **"Run workflow"**
3. Click the green **"Run workflow"** button

## 🕹️ Controls

| Gesture | Action |
|---------|--------|
| Swipe Left | Move to left lane |
| Swipe Right | Move to right lane |
| Swipe Up | Jump |
| Swipe Down | Slide |
| Tap left zone | Move left |
| Tap right zone | Move right |
| Tap center/top | Jump |

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point
├── game/
│   ├── game_engine.dart       # Core game loop, physics, collision
│   └── game_painter.dart      # Canvas renderer
├── models/
│   └── game_models.dart       # Data models
├── screens/
│   ├── home_screen.dart       # Home/menu screen
│   ├── game_screen.dart       # Main game screen
│   └── stats_screen.dart      # Stats & achievements
├── utils/
│   ├── constants.dart         # Colors, game config
│   └── score_manager.dart     # Persistent storage
└── widgets/
    ├── hud_widget.dart        # In-game HUD
    ├── game_over_overlay.dart # Game over screen
    ├── pause_overlay.dart     # Pause menu
    └── countdown_widget.dart  # 3-2-1-GO countdown
```

## 🛠️ Dependencies

| Package | Purpose |
|---------|---------|
| `flame` | Game engine utilities |
| `shared_preferences` | Persistent high score storage |
| `google_fonts` | Cinzel Decorative font for temple aesthetic |
| `flutter_animate` | UI animations |
| `audioplayers` | Sound effects (ready to use) |

## 📄 License

MIT License — feel free to use, modify and distribute.
