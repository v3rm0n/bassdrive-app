import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'models/api_response.dart';
import 'models/listening_progress.dart';
import 'services/api_service.dart';
import 'services/audio_player_service.dart';
import 'services/download_service.dart';
import 'services/storage_service.dart';
import 'ui/theme/app_theme_tokens.dart';
import 'utils/theme.dart';
import 'widgets/adaptive_navigation.dart';
import 'widgets/full_player.dart';
import 'screens/archive_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/live_stream_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fonts ship with the app so it looks the same without a connection.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    for (final family in ['BigShoulders', 'InstrumentSans']) {
      final license =
          await rootBundle.loadString('assets/google_fonts/$family-OFL.txt');
      yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
    }
  });

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
  String? _nowPlaying;
  Timer? _nowPlayingTimer;
  bool _fetchingNowPlaying = false;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _playerService = widget.playerService ?? AudioPlayerService();
    _storageService = widget.storageService ?? StorageService();
    _ownsPlayerService = widget.playerService == null;

    _loadData();
    _playerService.addListener(_onPlayerStateChanged);
    _progressTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _saveProgress());
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _nowPlayingTimer?.cancel();
    _playerService.removeListener(_onPlayerStateChanged);
    if (_ownsPlayerService) {
      _playerService.dispose();
    }
    super.dispose();
  }

  void _onPlayerStateChanged() {
    if (mounted) {
      final player = _playerService;
      if (player.state == PlayerState.paused ||
          (player.isPlaying && player.currentEpisode?.id != _lastEpisodeId)) {
        _saveProgress();
      }
      setState(() {});
    }
  }

  Timer? _progressTimer;
  String? _lastEpisodeId;
  Duration? _lastSavedPosition;

  void _saveProgress() {
    final player = _playerService;
    final episode = player.currentEpisode;
    if (episode == null ||
        player.isLive ||
        !(player.isPlaying || player.state == PlayerState.paused)) {
      return;
    }

    final position = player.position;
    final duration = player.duration;
    if (_lastEpisodeId == episode.id && _lastSavedPosition == position) return;
    _lastEpisodeId = episode.id;
    _lastSavedPosition = position;
    unawaited(_persistProgress(ListeningProgress(
      episodeId: episode.id,
      episodeName: episode.displayName,
      showName: episode.show,
      position: position,
      duration: duration > Duration.zero ? duration : null,
      lastPlayed: DateTime.now(),
    )));
  }

  Future<void> _persistProgress(ListeningProgress progress) async {
    try {
      await _storageService.saveProgress(progress);
      final duration = progress.duration;
      if (duration != null &&
          progress.position >= duration - const Duration(seconds: 30)) {
        await _storageService.markEpisodeCompleted(progress.episodeId);
      }
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _apiService.fetchArchive();
      if (!mounted) return;

      setState(() {
        _apiResponse = response;
        _isLoading = false;
      });
      if (_nowPlayingTimer == null) {
        unawaited(_refreshNowPlaying());
        _nowPlayingTimer = Timer.periodic(
          const Duration(minutes: 2),
          (_) => unawaited(_refreshNowPlaying()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshNowPlaying() async {
    if (_fetchingNowPlaying) return;
    _fetchingNowPlaying = true;
    try {
      final title = await _apiService.fetchNowPlaying();
      if (mounted && title != _nowPlaying) {
        setState(() => _nowPlaying = title);
      }
    } finally {
      _fetchingNowPlaying = false;
    }
  }

  void _navigateToPlayer() {
    setState(() {
      _currentIndex = 2; // Player is at index 2
    });
  }

  Widget _archiveStatus(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return _StatusScaffold(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Tuning in', style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Loading the live stream and show archive.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

    return _StatusScaffold(
      children: [
        const Icon(Icons.wifi_off_rounded, size: 32, color: AppColors.error),
        const SizedBox(height: AppSpacing.lg),
        Text("Can't reach Bassdrive", style: theme.textTheme.displaySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Check your connection and try again. Downloaded episodes still play offline.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _apiResponse;
    final Widget content;
    if (_currentIndex == 2) {
      content = FullPlayer(
        playerService: _playerService,
        storageService: _storageService,
        liveStreamUrl: data?.live,
        nowPlaying: _nowPlaying,
      );
    } else if (_currentIndex == 4) {
      content = DownloadsScreen(
        playerService: _playerService,
        storageService: _storageService,
        onPlayEpisode: _navigateToPlayer,
      );
    } else if (data == null) {
      content = _archiveStatus(context);
    } else {
      content = switch (_currentIndex) {
        0 => LiveStreamScreen(
            playerService: _playerService,
            liveStreamUrl: data.live,
            nowPlaying: _nowPlaying,
            storageService: _storageService,
          ),
        1 => ArchiveScreen(
            archive: data.archive,
            playerService: _playerService,
            storageService: _storageService,
            onPlayEpisode: _navigateToPlayer,
          ),
        3 => FavouritesScreen(
            archive: data.archive,
            playerService: _playerService,
            storageService: _storageService,
            onPlayEpisode: _navigateToPlayer,
          ),
        _ => throw StateError('Unknown destination $_currentIndex'),
      };
    }

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
      content: content,
    );
  }
}

class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
