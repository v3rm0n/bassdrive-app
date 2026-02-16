import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'models/api_response.dart';
import 'models/listening_progress.dart';
import 'services/api_service.dart';
import 'services/audio_player_service.dart';
import 'services/download_service.dart';
import 'services/storage_service.dart';
import 'ui/theme/app_theme_tokens.dart';
import 'ui/theme/component_theme_extensions.dart';
import 'utils/theme.dart';
import 'widgets/adaptive_navigation.dart';
import 'widgets/full_player.dart';
import 'screens/archive_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/live_stream_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.bassdrive.radio.channel.audio',
    androidNotificationChannelName: 'Bassdrive Radio',
    androidNotificationOngoing: true,
  );

  await StorageService().initialize();
  await DownloadService().initialize();

  runApp(const BassdriveApp());
}

class BassdriveApp extends StatelessWidget {
  const BassdriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bassdrive Radio',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.apiService,
    this.playerService,
    this.storageService,
  });

  final ApiService? apiService;
  final AudioPlayerService? playerService;
  final StorageService? storageService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ApiService _apiService;
  late final AudioPlayerService _playerService;
  late final StorageService _storageService;
  late final bool _ownsPlayerService;

  int _currentIndex = 0;
  ApiResponse? _apiResponse;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _playerService = widget.playerService ?? AudioPlayerService();
    _storageService = widget.storageService ?? StorageService();
    _ownsPlayerService = widget.playerService == null;

    _loadData();
    _playerService.addListener(_onPlayerStateChanged);
    _startProgressTracking();
  }

  @override
  void dispose() {
    _playerService.removeListener(_onPlayerStateChanged);
    if (_ownsPlayerService) {
      _playerService.dispose();
    }
    super.dispose();
  }

  void _onPlayerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startProgressTracking() {
    // Track last saved position to avoid unnecessary saves
    Duration? lastSavedPosition;
    String? lastEpisodeId;

    // Listen to player state changes to save on pause/stop
    _playerService.addListener(() async {
      if (!mounted) return;

      final episode = _playerService.currentEpisode;
      if (episode == null || _playerService.isLive) return;

      // Save when paused or stopped
      if (!_playerService.isPlaying &&
          _playerService.state != PlayerState.loading &&
          _playerService.state != PlayerState.buffering) {
        // Only save if position has changed significantly (avoid duplicate saves)
        final currentPosition = _playerService.position;
        if (lastEpisodeId != episode.id ||
            lastSavedPosition == null ||
            (currentPosition.inMilliseconds - lastSavedPosition!.inMilliseconds)
                    .abs() >
                1000) {
          try {
            await _storageService.saveProgress(
              ListeningProgress(
                episodeId: episode.id,
                episodeName: episode.displayName,
                showName: episode.show,
                position: currentPosition,
                duration: _playerService.duration > Duration.zero
                    ? _playerService.duration
                    : null,
                lastPlayed: DateTime.now(),
              ),
            );
            lastSavedPosition = currentPosition;
            lastEpisodeId = episode.id;
          } catch (e) {
            debugPrint('Error saving progress on pause: $e');
          }
        }
      }
    });

    // Periodic save while playing
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;

      if (_playerService.currentEpisode != null &&
          _playerService.isPlaying &&
          !_playerService.isLive) {
        final episode = _playerService.currentEpisode!;
        final currentPosition = _playerService.position;

        try {
          // Only save if position has changed
          if (lastEpisodeId != episode.id ||
              lastSavedPosition == null ||
              (currentPosition.inMilliseconds -
                          lastSavedPosition!.inMilliseconds)
                      .abs() >
                  1000) {
            await _storageService.saveProgress(
              ListeningProgress(
                episodeId: episode.id,
                episodeName: episode.displayName,
                showName: episode.show,
                position: currentPosition,
                duration: _playerService.duration > Duration.zero
                    ? _playerService.duration
                    : null,
                lastPlayed: DateTime.now(),
              ),
            );
            lastSavedPosition = currentPosition;
            lastEpisodeId = episode.id;
          }

          // Mark as completed if near end
          if (_playerService.duration > Duration.zero &&
              _playerService.position >=
                  _playerService.duration - const Duration(seconds: 30)) {
            await _storageService.markEpisodeCompleted(episode.id);
          }
        } catch (e) {
          debugPrint('Error saving progress: $e');
        }
      }

      return mounted;
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiService.fetchArchive();

      setState(() {
        _apiResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToPlayer() {
    setState(() {
      _currentIndex = 2; // Player is at index 2
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return _ChromeStatusScaffold(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Booting broadcast console...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Loading live stream and archive signal.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _ChromeStatusScaffold(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.portable_wifi_off, size: 56, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Signal lost',
              style: theme.textTheme.displaySmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Re-sync'),
            ),
          ],
        ),
      );
    }

    final screens = [
      LiveStreamScreen(
        playerService: _playerService,
        liveStreamUrl: _apiResponse!.live,
        storageService: _storageService,
      ),
      ArchiveScreen(
        archive: _apiResponse!.archive,
        playerService: _playerService,
        storageService: _storageService,
        onPlayEpisode: _navigateToPlayer,
      ),
      // Player is now the main/central screen
      FullPlayer(
        playerService: _playerService,
        storageService: _storageService,
        liveStreamUrl: _apiResponse!.live,
      ),
      FavouritesScreen(
        archive: _apiResponse!.archive,
        playerService: _playerService,
        storageService: _storageService,
        onPlayEpisode: _navigateToPlayer,
      ),
      DownloadsScreen(
        playerService: _playerService,
        storageService: _storageService,
        onPlayEpisode: _navigateToPlayer,
      ),
    ];

    final destinations = const [
      NavigationItem(
        icon: Icons.radio_outlined,
        selectedIcon: Icons.radio,
        label: 'Live',
        index: 0,
      ),
      NavigationItem(
        icon: Icons.library_music_outlined,
        selectedIcon: Icons.library_music,
        label: 'Archive',
        index: 1,
      ),
      NavigationItem(
        icon: Icons.play_circle_outline,
        selectedIcon: Icons.play_circle_filled,
        label: 'Player',
        index: 2,
        isProminent: true,
      ),
      NavigationItem(
        icon: Icons.favorite_outline,
        selectedIcon: Icons.favorite,
        label: 'Favourites',
        index: 3,
      ),
      NavigationItem(
        icon: Icons.download_outlined,
        selectedIcon: Icons.download,
        label: 'Downloads',
        index: 4,
      ),
    ];

    return AdaptiveNavigation(
      currentIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      destinations: destinations,
      content: screens[_currentIndex],
    );
  }
}

class _ChromeStatusScaffold extends StatelessWidget {
  const _ChromeStatusScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme =
        theme.extension<BroadcastCardTheme>() ?? BroadcastCardTheme.console();

    return Scaffold(
      body: Stack(
        children: [
          const _StatusBackdrop(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cardTheme.background.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(cardTheme.radius),
                    border: Border.all(color: cardTheme.border),
                    boxShadow: [
                      BoxShadow(
                        color: cardTheme.glow.withValues(alpha: 0.18),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: cardTheme.padding,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBackdrop extends StatelessWidget {
  const _StatusBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surface, AppColors.background],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -80,
            top: -120,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: AppColors.cyanGlow.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            right: -70,
            bottom: -110,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: AppColors.outlineStrong.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
