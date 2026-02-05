# Bassdrive Radio App

A cross-platform application for listening to Bassdrive Internet radio. Built with Flutter for iOS, Android, macOS, and Windows.

[![Latest Release](https://img.shields.io/github/v/release/v3rm0n/bassdrive-app?label=latest%20release&style=for-the-badge)](https://github.com/v3rm0n/bassdrive-app/releases/latest)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/v3rm0n/bassdrive-app/release.yml?style=for-the-badge)](https://github.com/v3rm0n/bassdrive-app/actions)

## Downloads

[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/v3rm0n/bassdrive-app/releases/latest/download/app-release.apk)
[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/v3rm0n/bassdrive-app/releases/latest/download/Bassdrive-Radio-macOS.dmg)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/v3rm0n/bassdrive-app/releases/latest/download/Bassdrive-Radio-Windows.zip)

<p float="left">
  <img src="/screenshots/IMAGE1.PNG" width="24%" />
  <img src="/screenshots/IMAGE2.PNG" width="24%" /> 
  <img src="/screenshots/IMAGE3.PNG" width="24%" />
  <img src="/screenshots/IMAGE4.PNG" width="24%" />
</p>

## Features

- **Live Stream**: Listen to Bassdrive's 24/7 Drum & Bass radio stream
- **Archive Browser**: Browse shows by day of the week (Monday-Sunday)
- **Show Episodes**: Access hundreds of archived episodes
- **Listening History**: Automatically tracks which episodes you've listened to
- **Progress Tracking**: Saves your listening position and resumes where you left off
- **Favourites/Bookmarks**: Save your favourite episodes for quick access
- **Filter & Sort**: Search and sort favourites by date, name, or show
- **Listening Statistics**: Track total listening time for live stream and archives
- **Background Playback**: Continue listening while using other apps
- **Desktop Optimized**: Sidebar navigation and desktop-style player bar on macOS/Windows

## Getting Started

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for emulators)
- Android SDK / iOS SDK

### Installation

```bash
git clone https://github.com/v3rm0n/bassdrive-app.git
cd bassdrive-app
flutter pub get
```

### Running the app

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# macOS
flutter run -d macos

# Windows
flutter run -d windows
```

### Building for Production

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
# or
flutter build appbundle --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release
```

## Architecture

The app is built using:

- **Flutter**: Cross-platform UI framework
- **just_audio**: Audio playback with background support
- **audio_service**: Background audio handling
- **dio**: HTTP client for API requests
- **shared_preferences**: Local storage for listening progress, favourites, and statistics
- **BLoC pattern**: State management

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── services/                 # Business logic
├── screens/                  # UI screens
├── widgets/                  # Reusable widgets
└── utils/                    # Utilities
```

## Data Source

The app uses the Bassdrive JSON API:
- Live Stream: `https://bassdrive.radioca.st/stream`
- Archive API: `https://bd.maido.io/api.json`

## Platform Support

### Mobile (iOS & Android)
- Bottom navigation bar
- Mini player at bottom
- Touch-optimized interface

### Desktop (macOS & Windows)
- Sidebar navigation (280px width)
- Desktop player bar at bottom
- Window-sized layout (1280x720 default)
- Mouse-optimized interface

## Permissions

### iOS
- Audio background mode (for playback when app is in background)

### Android
- Internet access
- Wake lock (prevent sleep during playback)
- Foreground service (for background playback)

### macOS
- Network client entitlement (for API and streaming)
- App Transport Security configured for HTTP streams
- App sandbox enabled

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Bassdrive.com for the amazing drum & bass radio stream
- The Flutter team for the excellent framework
- All the DJs and shows featured in the archive

## Changelog

### v0.0.8
- Fixed Android launch issue by updating NDK version to 28.0.12433566

### v0.0.7
- Fixed Android release builds

### v0.0.6
- Update Windows and macOS icons and application name

### v0.0.5
- Full desktop support for macOS and Windows
- Adaptive UI with sidebar navigation on desktop
- Desktop-optimized player bar with full controls
- GitHub Actions workflow for automated releases on all platforms

### v0.0.4
- Track listening time statistics
- Separate tracking for live stream and archives
- New "Stats" tab in navigation

### v0.0.3
- Enhanced favourites management with sort and filter
- Search within favourites
- Filter by specific show

### v0.0.2
- Added favourites/bookmarks functionality
- Heart icon on every episode
- New "Favourites" tab in navigation

### Bug Fixes & Improvements
- Fixed broken widget test
- Fixed slider value clamping bug in full player
- Fixed error state handling in audio player service
- Fixed race condition in progress tracking
- Fixed missing mounted check in navigation
- Improved storage efficiency
- Removed unused dependencies
- Fixed null safety issues
- Fixed macOS network entitlements for API access
- Fixed macOS App Transport Security for HTTP streams

## Support

For issues or feature requests, please open an issue on GitHub.
