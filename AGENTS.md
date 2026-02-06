# Bassdrive Radio App - Agent Guide

## Project Overview

**Type:** Flutter cross-platform audio streaming application  
**Purpose:** Stream Bassdrive Internet radio (24/7 Drum & Bass) and archived shows  
**Version:** 0.1.4+6  
**Repository:** https://github.com/v3rm0n/bassdrive-app  
**License:** MIT

---

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run
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

### Pattern: Service-Oriented + ChangeNotifier

```
UI Layer (screens/widgets)
    ↓
Service Layer (business logic + playback + persistence)
    ↓
Model Layer (API and local state data classes)
```

### Core Services

| Service | File | Purpose |
|---------|------|---------|
| `AudioPlayerService` | `lib/services/audio_player_service.dart` | Playback, player state, listening-time tracking |
| `StorageService` | `lib/services/storage_service.dart` | SharedPreferences wrapper for progress/favourites/stats |
| `DownloadService` | `lib/services/download_service.dart` | Episode download lifecycle and local file tracking |
| `ApiService` | `lib/services/api_service.dart` | Bassdrive archive fetch via Dio |

### Data Models

| Model | File | Key Fields |
|-------|------|------------|
| `ApiResponse` | `lib/models/api_response.dart` | `live`, `archive: Map<String, ArchiveDay>`, `updated` |
| `ArchiveDay` | `lib/models/archive_day.dart` | `day`, `shows: List<Show>` |
| `Show` | `lib/models/show.dart` | `name`, `episodes: List<Episode>` |
| `Episode` | `lib/models/episode.dart` | `name`, `show`, `url`, `encodedUrl`, `id` |
| `ListeningProgress` | `lib/models/listening_progress.dart` | `episodeId`, `episodeName`, `showName`, `position`, `duration`, `lastPlayed`, `isCompleted` |

---

## Key Dependencies

```yaml
dependencies:
  just_audio: ^0.10.5
  just_audio_windows: ^0.2.2
  audio_service: ^0.18.18
  just_audio_background: ^0.0.1-beta.17
  dio: ^5.9.1
  shared_preferences: ^2.3.0
  path_provider: ^2.1.5
  google_fonts: ^6.0.0
  cupertino_icons: ^1.0.8
```

---

## Project Structure

```
lib/
├── main.dart
├── models/
├── services/
├── screens/
├── widgets/
└── utils/
```

Key screens in active navigation are configured in `lib/main.dart`:
- Live
- Archive
- Player (center tab)
- Favourites
- Downloads

`listening_stats_screen.dart` is accessed from the Player screen via the chart icon.

---

## Features

### 1. Live Stream Playback
- Bassdrive 24/7 stream playback
- Background playback with media notification controls
- Live status indicator
- Stream URL comes from API response `live`

### 2. Archive Browser
- Shows grouped by day (Monday-Sunday)
- Day tabs for browsing
- Show search support
- Data source: `https://bd.maido.io/api.json`

### 3. Show Details
- Episode list per show
- Episode search in show
- Episode metadata formatting from filename/date pattern

### 4. Favourites
- Favourite toggle per episode
- Dedicated favourites screen
- Search, show filtering, and multi-mode sorting

### 5. Listening Progress
- Periodic progress save (every 5 seconds while archive content is playing)
- Resume from previous progress
- Completion detection when near end of episode

### 6. Offline Downloads
- Auto-download when an episode starts playing
- Manual delete and delete-all management
- Download progress and storage usage UI
- 2 GB soft limit (new downloads are rejected when limit is hit)

### 7. Listening Statistics
- Tracks live-stream and archive listening time separately
- Shows totals and percentages
- Reset option in stats screen

### 8. Adaptive Layout
- **Mobile:** bottom navigation with dedicated Player tab
- **Desktop:** 280px sidebar navigation with content pane

---

## Important Implementation Details

### Episode Identity

```dart
String get id => encodedUrl;
```

### Singleton-Like Services

Both `StorageService` and `DownloadService` use factory constructors over private static instances.

```dart
final storage = StorageService();
final downloads = DownloadService();
```

### Progress and Completion Logic
- Progress is saved periodically while playing archive episodes
- Additional saves happen when playback transitions to paused/idle states
- Episode completion threshold is `duration - 30 seconds`

### Auto-Download Behavior
- Starts automatically in `AudioPlayerService.playEpisode()`
- Ongoing auto-downloads are canceled when a new episode begins
- Download files are written under app documents directory `/downloads`

### Developer Menu
- Hidden by long-pressing the live radio tile
- `Clear All App State` clears SharedPreferences state

### Theme
- Dark theme only
- Cyan-accent palette
- Inter font via Google Fonts
- Material 3 enabled

---

## Platform Support

| Platform | App Status | Notes |
|----------|------------|-------|
| iOS | Supported | Requires macOS + Xcode to build locally |
| Android | Supported | APK builds |
| macOS | Supported | DMG artifact in CI |
| Windows | Supported | ZIP artifact in CI |
| Linux | Supported | tar.gz artifact in CI |

---

## CI/CD

GitHub Actions workflow: `.github/workflows/release.yml`

- Triggered by version tags matching `vX.Y.Z`
- Runs `flutter analyze` and `flutter test`
- Builds release artifacts for Android, macOS, Windows, Linux
- Creates a GitHub release with generated notes and attached artifacts

Note: iOS is not built in CI currently.

---

## Testing

```bash
flutter test
flutter test --coverage
flutter analyze
```

---

## Common Tasks

### Adding a New Main Navigation Screen
1. Create the screen under `lib/screens/`
2. Add it to the `screens` list in `lib/main.dart`
3. Add a `NavigationItem` in `destinations` in `lib/main.dart`

### Modifying Playback Behavior
- Primary file: `lib/services/audio_player_service.dart`
- Uses `just_audio` + `just_audio_background`

### Updating API Logic
- Primary file: `lib/services/api_service.dart`
- Current endpoint constant: `https://bd.maido.io/api.json`

### Persisting New Local Data
- Use `StorageService()`
- Data is persisted in SharedPreferences

---

## Troubleshooting

### Audio Not Playing on Windows
Ensure `just_audio_windows` is present and Windows audio backend initializes correctly.

### Downloads Not Appearing
Check network/file permissions and that app documents directory is writable.

### Background Audio Stops
Verify `audio_service` and background-audio configuration in platform manifests/plists.

### Analyzer Fails on Dropdown Fields
If you hit `undefined_named_parameter initialValue` in favourites filter dropdowns, replace `initialValue:` with `value:` for Flutter SDK compatibility.

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [just_audio Package](https://pub.dev/packages/just_audio)
- [audio_service Package](https://pub.dev/packages/audio_service)
- [Bassdrive Website](https://bassdrive.com)
