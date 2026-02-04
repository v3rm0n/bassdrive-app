# Bassdrive Radio App

A cross-platform application for listening to Bassdrive Internet radio. Built with Flutter for iOS, Android, macOS, and Windows.

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
- **Modern UI**: Clean, dark-themed interface optimized for music apps
- **No Authentication**: Open and free to use

## Screenshots

The app features:
- Live stream player with visualizer
- Archive browser with day tabs
- Show detail pages with episode lists
- Mini player for quick controls
- Full-screen player with seek controls
- Favourites tab for bookmarked episodes

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

**macOS:**
```bash
flutter run -d macos
```

**Windows:**
```bash
flutter run -d windows
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

**macOS:**
```bash
flutter build macos --release
```

**Windows:**
```bash
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
│   ├── favourites_screen.dart
│   ├── listening_stats_screen.dart
│   ├── live_stream_screen.dart
│   └── show_detail_screen.dart
├── widgets/                  # Reusable widgets
│   ├── adaptive_navigation.dart
│   ├── audio_controls.dart
│   ├── desktop_player_bar.dart
│   ├── episode_list_item.dart
│   ├── full_player.dart
│   ├── mini_player.dart
│   └── show_list_item.dart
└── utils/                    # Utilities
    ├── platform_utils.dart
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

### Favourites
- Bookmark episodes with one tap (heart icon)
- Dedicated Favourites tab for quick access
- **Filter & Sort Options**:
  - Sort by date (newest/oldest)
  - Sort by name (A-Z/Z-A)
  - Sort by show name (A-Z/Z-A)
  - Search by episode or show name
  - Filter by specific show
- Pull-to-refresh to update list
- Easy access from any episode list

### Listening Statistics
- Track total listening time across all sessions
- Separate tracking for:
  - Live stream listening time
  - Archives listening time (aggregated)
- Visual breakdown with percentages
- Persistent storage of statistics
- Option to reset statistics

## Platform Support

### Mobile (iOS & Android)
- Bottom navigation bar
- Mini player at bottom
- Touch-optimized interface

### Desktop (macOS & Windows)
- Sidebar navigation (280px width)
- Desktop player bar at bottom with:
  - Track info with artwork
  - Playback controls with progress bar
  - Volume and extra controls
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

### Recent Updates

#### Desktop Support (v0.0.5)
- **New**: Full desktop support for macOS and Windows
  - Adaptive UI with sidebar navigation on desktop
  - Desktop-optimized player bar with full controls
  - Platform-specific layouts (mobile vs desktop)
  - GitHub Actions workflow for automated releases on all platforms

#### Listening Statistics (v0.0.4)
- **New**: Track listening time statistics
  - Separate tracking for live stream and archives
  - Visual breakdown with percentages
  - Persistent storage of total listening time
  - New "Stats" tab in navigation
  - Option to reset statistics

#### Filter & Sort for Favourites (v0.0.3)
- **New**: Enhanced favourites management
  - Sort by date (newest/oldest)
  - Sort by name (A-Z/Z-A)
  - Sort by show name (A-Z/Z-A)
  - Search within favourites
  - Filter by specific show
  - Active filter indicators with quick clear

#### Favourites/Bookmarks Feature (v0.0.2)
- **New**: Added favourites/bookmarks functionality
  - Heart icon on every episode to add/remove from favourites
  - New "Favourites" tab in bottom navigation
  - Favourited episodes sorted by date (newest first)
  - Pull-to-refresh on favourites screen
  - Persistent storage using SharedPreferences

#### Bug Fixes & Improvements
- Fixed broken widget test
- Fixed slider value clamping bug in full player
- Fixed error state handling in audio player service
- Fixed race condition in progress tracking
- Fixed missing mounted check in navigation
- Improved storage efficiency (individual keys per episode)
- Removed unused dependencies
- Fixed null safety issues
- Fixed macOS network entitlements for API access
- Fixed macOS App Transport Security for HTTP streams

#### UI/UX Improvements
- Navigation now closes player view when switching tabs
- Live stream screen shows "ARCHIVE PLAYING" status
- Added "Switch to Live Stream" button when archive is playing
- Added secret developer menu (long press radio icon)
- Show detail screen stays open when playing episodes
- Tapping currently playing episode opens full player
- Episode list improvements:
  - Fixed playing indicator updates
  - Fixed progress bar showing 0% when starting/paused
  - Completed episodes show green checkmark
  - Only current episode shows play/pause button
- Progress management fixes:
  - Progress saves on pause/stop events
  - Fixed completed episodes showing 99%
  - Added `clearAllAppState()` for debugging

## Support

For issues or feature requests, please open an issue on GitHub.

---

Built with ❤️ for the drum & bass community.
