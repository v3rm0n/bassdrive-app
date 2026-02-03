# Bassdrive Radio App

A cross-platform mobile application for listening to Bassdrive Internet radio. Built with Flutter for iOS and Android.

<p float="left">
  <img src="/screenshots/IMG_6740.PNG" width="24%" />
  <img src="/screenshots/IMG_6741.PNG" width="24%" /> 
  <img src="/screenshots/IMG_6742.PNG" width="24%" />
  <img src="/screenshots/IMG_6743.PNG" width="24%" />
</p>

## Features

- **Live Stream**: Listen to Bassdrive's 24/7 Drum & Bass radio stream
- **Archive Browser**: Browse shows by day of the week (Monday-Sunday)
- **Show Episodes**: Access hundreds of archived episodes
- **Listening History**: Automatically tracks which episodes you've listened to
- **Progress Tracking**: Saves your listening position and resumes where you left off
- **Background Playback**: Continue listening while using other apps
- **Modern UI**: Clean, dark-themed interface optimized for music apps
- **No Authentication**: Open and free to use

## Screenshots

The app features:
- Live stream player with visualizer
- Archive browser with day tabs
- Show detail pages with episode lists
- Mini player for quick controls
- Full-screen player with seek controls

## Getting Started

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for emulators)
- Android SDK / iOS SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/bassdrive-radio.git
cd bassdrive-radio
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:

**iOS:**
```bash
flutter run -d ios
```

**Android:**
```bash
flutter run -d android
```

### Building for Production

**iOS:**
```bash
flutter build ios --release
```

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## Architecture

The app is built using:

- **Flutter**: Cross-platform UI framework
- **just_audio**: Audio playback with background support
- **audio_service**: Background audio handling
- **dio**: HTTP client for API requests
- **shared_preferences**: Local storage for listening progress
- **BLoC pattern**: State management

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── api_response.dart
│   ├── archive_day.dart
│   ├── episode.dart
│   ├── listening_progress.dart
│   └── show.dart
├── services/                 # Business logic
│   ├── api_service.dart
│   ├── audio_player_service.dart
│   └── storage_service.dart
├── screens/                  # UI screens
│   ├── archive_screen.dart
│   ├── live_stream_screen.dart
│   └── show_detail_screen.dart
├── widgets/                  # Reusable widgets
│   ├── audio_controls.dart
│   ├── episode_list_item.dart
│   ├── full_player.dart
│   ├── mini_player.dart
│   └── show_list_item.dart
└── utils/                    # Utilities
    └── theme.dart
```

## Data Source

The app uses the Bassdrive JSON API:
- Live Stream: `https://bassdrive.radioca.st/stream`
- Archive API: `https://bd.maido.io/api.json`

## Features in Detail

### Live Stream
- One-tap play/pause
- Background audio support
- Visual "LIVE" indicator when playing
- Error handling with retry option

### Archive Browser
- Browse by day of week (Mon-Sun)
- Search shows by name
- Visual show cards with episode counts

### Episode Player
- Resume from last position
- Progress tracking (saves every 5 seconds)
- Mark episodes as completed
- Seek/skip controls (10s back, 30s forward)
- Full-screen player with scrubber

### Listening History
- Automatically saves progress
- Shows completion percentage
- Visual indicators for completed episodes
- Recently played tracking

## Permissions

### iOS
- Audio background mode (for playback when app is in background)

### Android
- Internet access
- Wake lock (prevent sleep during playback)
- Foreground service (for background playback)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Bassdrive.com for the amazing drum & bass radio stream
- The Flutter team for the excellent framework
- All the DJs and shows featured in the archive

## Support

For issues or feature requests, please open an issue on GitHub.

---

Built with ❤️ for the drum & bass community.
