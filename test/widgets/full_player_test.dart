import 'package:bassdrive_radio/models/episode.dart';
import 'package:bassdrive_radio/services/audio_player_service.dart';
import 'package:bassdrive_radio/services/storage_service.dart';
import 'package:bassdrive_radio/utils/theme.dart';
import 'package:bassdrive_radio/widgets/full_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
  });

  testWidgets('FullPlayer starts live stream from idle state', (tester) async {
    final playerService = _FakeAudioPlayerService();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: FullPlayer(
          playerService: playerService,
          storageService: StorageService(),
          liveStreamUrl: 'https://example.com/live',
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(playerService.playLiveCalls, 1);
    expect(playerService.lastLiveUrl, 'https://example.com/live');
  });

  testWidgets('FullPlayer shows archive progress labels', (tester) async {
    final playerService = _FakeAudioPlayerService(
      currentEpisode: Episode(
        name: '[2026.02.10] Late Night Session',
        show: 'Bassdrive Archive',
        url: 'https://example.com/original',
        encodedUrl: 'https://example.com/encoded',
      ),
      position: const Duration(minutes: 12),
      duration: const Duration(minutes: 58),
      state: PlayerState.paused,
      isLive: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: FullPlayer(
          playerService: playerService,
          storageService: StorageService(),
          liveStreamUrl: 'https://example.com/live',
        ),
      ),
    );

    expect(find.text('12:00'), findsOneWidget);
    expect(find.text('58:00'), findsOneWidget);
  });

  testWidgets('FullPlayer renders archive timeline and skip controls', (
    tester,
  ) async {
    final playerService = _FakeAudioPlayerService(
      currentEpisode: Episode(
        name: '[2026.02.10] Late Night Session',
        show: 'Bassdrive Archive',
        url: 'https://example.com/original',
        encodedUrl: 'https://example.com/encoded',
      ),
      position: const Duration(minutes: 12),
      duration: const Duration(minutes: 58),
      state: PlayerState.paused,
      isLive: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: FullPlayer(
          playerService: playerService,
          storageService: StorageService(),
          liveStreamUrl: 'https://example.com/live',
        ),
      ),
    );

    expect(find.byType(Slider), findsOneWidget);
    expect(find.byIcon(Icons.replay_10), findsOneWidget);
    expect(find.byIcon(Icons.forward_30), findsOneWidget);
  });

  testWidgets('FullPlayer primary control reflects loading and play states', (
    tester,
  ) async {
    final playerService = _FakeAudioPlayerService(
      state: PlayerState.loading,
      isLive: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: FullPlayer(
          playerService: playerService,
          storageService: StorageService(),
          liveStreamUrl: 'https://example.com/live',
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
    expect(find.byIcon(Icons.pause), findsNothing);

    playerService.setState(PlayerState.paused);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    playerService.setState(PlayerState.playing);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });

  testWidgets('FullPlayer toggles playback for loaded archive content', (
    tester,
  ) async {
    final playerService = _FakeAudioPlayerService(
      currentEpisode: Episode(
        name: '[2026.02.10] Late Night Session',
        show: 'Bassdrive Archive',
        url: 'https://example.com/original',
        encodedUrl: 'https://example.com/encoded',
      ),
      state: PlayerState.paused,
      isLive: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: FullPlayer(
          playerService: playerService,
          storageService: StorageService(),
          liveStreamUrl: 'https://example.com/live',
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(playerService.togglePlayPauseCalls, 1);
    expect(playerService.playLiveCalls, 0);
  });
}

class _FakeAudioPlayerService extends ChangeNotifier
    implements AudioPlayerService {
  _FakeAudioPlayerService({
    PlayerState state = PlayerState.idle,
    bool isLive = false,
    Episode? currentEpisode,
    Duration position = Duration.zero,
    Duration duration = Duration.zero,
  })  : _state = state,
        _isLive = isLive,
        _currentEpisode = currentEpisode,
        _position = position,
        _duration = duration;

  PlayerState _state;
  bool _isLive;
  Episode? _currentEpisode;
  Duration _position;
  Duration _duration;
  String? _error;

  int playLiveCalls = 0;
  int togglePlayPauseCalls = 0;
  String? lastLiveUrl;

  @override
  PlayerState get state => _state;

  @override
  Episode? get currentEpisode => _currentEpisode;

  @override
  bool get isLive => _isLive;

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  @override
  String? get error => _error;

  @override
  bool get hasError => _error != null;

  @override
  bool get isPlaying => _state == PlayerState.playing;

  @override
  bool get isLoading => _state == PlayerState.loading;

  @override
  Future<void> playLiveStream(String url) async {
    playLiveCalls += 1;
    lastLiveUrl = url;
    _isLive = true;
    _currentEpisode = null;
    _state = PlayerState.playing;
    notifyListeners();
  }

  @override
  Future<void> playEpisode(Episode episode, {Duration? startPosition}) async {
    _currentEpisode = episode;
    _isLive = false;
    _position = startPosition ?? Duration.zero;
    _state = PlayerState.playing;
    notifyListeners();
  }

  @override
  Future<void> play() async {
    _state = PlayerState.playing;
    notifyListeners();
  }

  @override
  Future<void> pause() async {
    _state = PlayerState.paused;
    notifyListeners();
  }

  @override
  Future<void> togglePlayPause() async {
    togglePlayPauseCalls += 1;
    _state = isPlaying ? PlayerState.paused : PlayerState.playing;
    notifyListeners();
  }

  void setState(PlayerState state) {
    _state = state;
    notifyListeners();
  }

  @override
  Future<void> seek(Duration position) async {
    _position = position;
    notifyListeners();
  }

  @override
  Future<void> stop() async {
    _state = PlayerState.idle;
    notifyListeners();
  }

  @override
  Future<void> skipForward(Duration duration) async {
    _position += duration;
    notifyListeners();
  }

  @override
  Future<void> skipBackward(Duration duration) async {
    _position -= duration;
    if (_position.isNegative) {
      _position = Duration.zero;
    }
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
