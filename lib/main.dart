import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'models/api_response.dart';
import 'models/listening_progress.dart';
import 'services/api_service.dart';
import 'services/audio_player_service.dart';
import 'services/storage_service.dart';
import 'utils/theme.dart';
import 'widgets/full_player.dart';
import 'widgets/mini_player.dart';
import 'screens/archive_screen.dart';
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

  runApp(const BassdriveApp());
}

class BassdriveApp extends StatelessWidget {
  const BassdriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bassdrive Radio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final AudioPlayerService _playerService = AudioPlayerService();
  final StorageService _storageService = StorageService();

  int _currentIndex = 0;
  ApiResponse? _apiResponse;
  bool _isLoading = true;
  String? _error;
  bool _showFullPlayer = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _playerService.addListener(_onPlayerStateChanged);
    _startProgressTracking();
  }

  @override
  void dispose() {
    _playerService.removeListener(_onPlayerStateChanged);
    _playerService.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Loading Bassdrive...', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text('Failed to load', style: theme.textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
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
        onOpenPlayer: () {
          setState(() {
            _showFullPlayer = true;
          });
        },
      ),
      FavouritesScreen(
        archive: _apiResponse!.archive,
        playerService: _playerService,
        storageService: _storageService,
        onOpenPlayer: () {
          setState(() {
            _showFullPlayer = true;
          });
        },
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: screens[_currentIndex]),
          if (_playerService.currentEpisode != null || _playerService.isLive)
            MiniPlayer(
              playerService: _playerService,
              onTap: () {
                setState(() {
                  _showFullPlayer = true;
                });
              },
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _showFullPlayer = false;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.radio), label: 'Live'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Archive',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
        ],
      ),
      bottomSheet: _showFullPlayer
          ? FullPlayer(
              playerService: _playerService,
              onClose: () {
                setState(() {
                  _showFullPlayer = false;
                });
              },
            )
          : null,
    );
  }
}
