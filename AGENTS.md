# Bassdrive Radio App - Agent Guide

## Project Overview

**Type:** Flutter cross-platform audio streaming application  
**Purpose:** Stream Bassdrive Internet radio (24/7 Drum & Bass) with archive access  
**Version:** 0.1.1+3  
**Repository:** https://github.com/v3rm0n/bassdrive-app  
**License:** MIT

---

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build for release
flutter build apk --release      # Android
flutter build ios --release      # iOS
flutter build macos --release    # macOS
flutter build windows --release  # Windows
flutter build linux --release    # Linux
```

---

## Architecture

### Pattern: Service-Oriented with ChangeNotifier State Management

```
UI Layer (Screens + Widgets)
    ↓
Service Layer (Business Logic)
    ↓
Model Layer (Data Classes)
```

### Core Services

| Service | File | Purpose |
|---------|------|---------|
| `AudioPlayerService` | `lib/services/audio_player_service.dart` | Audio playback control, state management |
| `StorageService` | `lib/services/storage_service.dart` | SharedPreferences wrapper (singleton) |
| `DownloadService` | `lib/services/download_service.dart` | Offline episode management (singleton) |
| `ApiService` | `lib/services/api_service.dart` | HTTP client for Bassdrive API |

### Data Models

| Model | File | Key Fields |
|-------|------|------------|
| `ApiResponse` | `lib/models/api_response.dart` | `days: List<ArchiveDay>` |
| `ArchiveDay` | `lib/models/archive_day.dart` | `day: String, shows: List<Show>` |
| `Show` | `lib/models/show.dart` | `name: String, episodes: List<Episode>` |
| `Episode` | `lib/models/episode.dart` | `title, url, date, size, encodedUrl (ID)` |
| `ListeningProgress` | `lib/models/listening_progress.dart` | `episodeId, position, duration, updatedAt` |

---

## Key Dependencies

```yaml
dependencies:
  just_audio: ^0.10.5              # Core audio playback
  just_audio_windows: ^0.2.2       # Windows audio support
  audio_service: ^0.18.18          # Background audio handling
  just_audio_background: ^0.0.1-beta.17  # Background playback
  dio: ^5.9.1                      # HTTP client
  shared_preferences: ^2.3.0       # Local settings storage
  path_provider: ^2.1.5            # File system access
  google_fonts: ^6.0.0             # Inter font
  cupertino_icons: ^1.0.8          # iOS-style icons
```

---

## Project Structure

```
lib/
├── main.dart                    # App entry, HomeScreen
├── models/                      # Data models
│   ├── api_response.dart
│   ├── archive_day.dart
│   ├── show.dart
│   ├── episode.dart
│   └── listening_progress.dart
├── services/                    # Business logic
│   ├── api_service.dart
│   ├── audio_player_service.dart
│   ├── storage_service.dart
│   └── download_service.dart
├── screens/                     # UI screens
│   ├── live_stream_screen.dart
│   ├── archive_screen.dart
│   ├── show_detail_screen.dart
│   ├── favourites_screen.dart
│   ├── downloads_screen.dart
│   └── listening_stats_screen.dart
├── widgets/                     # Reusable components
│   ├── adaptive_navigation.dart
│   ├── mini_player.dart
│   ├── desktop_player_bar.dart
│   ├── full_player.dart
│   ├── audio_controls.dart
│   ├── episode_list_item.dart
│   └── show_list_item.dart
└── utils/                       # Utilities
    ├── theme.dart               # Dark theme config
    └── platform_utils.dart      # Platform detection
```

---

## Features

### 1. Live Stream Playback
- 24/7 Bassdrive radio streaming
- Background audio with notification controls
- Real-time status indicator (LIVE/READY)
- URL: `https://bassdrive.radioca.st/stream`

### 2. Archive Browser
- Browse shows organized by day (Monday-Sunday)
- Search shows by name
- Tab-based navigation
- API: `https://bd.maido.io/api.json`

### 3. Show Detail View
- List all episodes for selected show
- Episode search within show
- Episode count display

### 4. Favourites/Bookmarks
- Heart icon on every episode
- Dedicated Favourites tab
- Advanced filtering:
  - Search by name/show
  - Filter by specific show
  - Sort by date (newest/oldest), name (A-Z/Z-A), show (A-Z/Z-A)

### 5. Listening Progress Tracking
- Auto-saves playback position every 5 seconds
- Resumes where left off
- Progress bar visualization
- Mark episodes as completed (near end detection)

### 6. Offline Downloads
- Auto-download episodes when played
- 2GB storage limit
- Manual download management
- Storage usage display
- Swipe-to-delete support

### 7. Listening Statistics
- Track total listening time
- Separate tracking for Live Stream vs Archives
- Visual breakdown with percentages
- Reset statistics option

### 8. Adaptive UI
- **Mobile:** Bottom navigation bar + mini player
- **Desktop:** Sidebar navigation (280px) + desktop player bar
- Platform-aware layouts via `PlatformUtils`

---

## Important Implementation Details

### Episode Identification
Episodes use `encodedUrl` as their unique identifier:
```dart
String get id => encodedUrl;
```

### Singleton Services
```dart
// Access anywhere
StorageService.instance
DownloadService.instance
```

### Progress Saving
- Auto-saves every 5 seconds while playing
- Saves immediately on pause/seek
- Completed when position > duration - 10 seconds

### Auto-Download Behavior
- Episodes auto-download when playback starts
- Downloads stored via `path_provider` getApplicationDocumentsDirectory
- 2GB limit enforced - oldest files deleted first

### Developer Menu
Hidden long-press menu on live stream screen for clearing app state (favourites, progress, downloads).

### Theme
- Dark theme only
- Cyan accent colors
- Inter font via Google Fonts
- Material 3 design

---

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| iOS | ✅ Supported | Requires macOS + Xcode |
| Android | ✅ Supported | APK output |
| macOS | ✅ Supported | DMG output |
| Windows | ✅ Supported | ZIP output, requires just_audio_windows |
| Linux | ✅ Supported | tar.gz output |

---

## CI/CD

GitHub Actions workflow (`.github/workflows/release.yml`):
- Triggered on version tags (`v*.*.*`)
- Builds for all 5 platforms
- Creates GitHub release with artifacts

---

## Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

Test file: `test/widget_test.dart` (basic widget tests)

---

## Common Tasks

### Adding a New Screen
1. Create file in `lib/screens/`
2. Add route to navigation in `adaptive_navigation.dart`
3. Add to `_pages` list in `main.dart`

### Modifying Audio Behavior
- Edit `lib/services/audio_player_service.dart`
- Uses `just_audio` AudioPlayer
- Background audio via `audio_service`

### Adding New API Endpoints
- Edit `lib/services/api_service.dart`
- Uses `dio` HTTP client
- Base URL: `https://bd.maido.io/`

### Persisting New Data
- Use `StorageService.instance`
- Wraps `SharedPreferences`
- Already handles: favourites, progress, downloads, stats

---

## Troubleshooting

### Audio not playing on Windows
Ensure `just_audio_windows` is in dependencies and properly initialized.

### Downloads not working
Check `path_provider` permissions and available storage.

### Background audio stops
Verify `audio_service` configuration in `AndroidManifest.xml` and `Info.plist`.

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [just_audio Package](https://pub.dev/packages/just_audio)
- [audio_service Package](https://pub.dev/packages/audio_service)
- [Bassdrive Website](https://bassdrive.com)
