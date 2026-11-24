import 'dart:async';

import 'package:bassdrive_radio/main.dart';
import 'package:bassdrive_radio/models/api_response.dart';
import 'package:bassdrive_radio/models/episode.dart';
import 'package:bassdrive_radio/models/archive_day.dart';
import 'package:bassdrive_radio/models/show.dart';
import 'package:bassdrive_radio/widgets/full_player.dart';
import 'package:bassdrive_radio/services/api_service.dart';
import 'package:bassdrive_radio/services/audio_player_service.dart';
import 'package:bassdrive_radio/services/storage_service.dart';
import 'package:bassdrive_radio/utils/theme.dart';
import 'package:bassdrive_radio/widgets/adaptive_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
  });

  testWidgets('HomeScreen loading state uses status copy', (
    tester,
  ) async {
    final pendingApi = _PendingApiService();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: HomeScreen(
          apiService: pendingApi,
          playerService: _FakeAudioPlayerService(),
          storageService: StorageService(),
        ),
      ),
    );

    expect(find.text('Tuning in'), findsOneWidget);
    expect(
        find.text('Loading the live stream and show archive.'), findsOneWidget);
    await tester.tap(find.text('Downloads'));
    await tester.pumpAndSettle();
    expect(find.text('No Downloads'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    pendingApi._completer.completeError(Exception('late response'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeScreen error state renders styled retry action', (
    tester,
  ) async {
    final failingApi = _FailingApiService();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: HomeScreen(
          apiService: failingApi,
          playerService: _FakeAudioPlayerService(),
          storageService: StorageService(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text("Can't reach Bassdrive"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(failingApi.fetchCallCount, 2);
    await tester.tap(find.text('Downloads'));
    await tester.pumpAndSettle();
    expect(find.text('No Downloads'), findsOneWidget);
    await tester.tap(find.text('Player'));
    await tester.pumpAndSettle();
    expect(find.text('Choose an episode from Downloads'), findsOneWidget);
  });

  testWidgets('live metadata refreshes on both live surfaces', (tester) async {
    final api = _PendingApiService()
      ..nowPlaying = 'First show - hosted by DJ A';
    api._completer.complete(
      ApiResponse(live: 'https://example.com/live', archive: {}),
    );
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: HomeScreen(
        apiService: api,
        playerService: _FakeAudioPlayerService(),
        storageService: StorageService(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text(api.nowPlaying!), findsOneWidget);

    await tester.tap(find.text('Listen live'));
    await tester.tap(find.text('Player'));
    await tester.pumpAndSettle();
    expect(find.text('Bassdrive live'), findsOneWidget);
    expect(find.text(api.nowPlaying!), findsOneWidget);

    api.nowPlaying = 'Next show - hosted by DJ B';
    await tester.pump(const Duration(minutes: 2));
    expect(find.text(api.nowPlaying!), findsOneWidget);

    api.nowPlaying = null;
    await tester.pump(const Duration(minutes: 2));
    expect(
        find.text('Worldwide drum & bass, around the clock'), findsOneWidget);
  });

  testWidgets(
      'selecting an episode in the archive opens its player and reopens it without restarting',
      (tester) async {
    final api = _PendingApiService();
    final player = _FakeAudioPlayerService();
    final mix = Episode(
        name: 'Midnight mix',
        show: 'Night shift',
        url: 'https://example.com/mix',
        encodedUrl: 'https://example.com/mix');
    api._completer
        .complete(ApiResponse(live: 'https://example.com/live', archive: {
      'Monday': ArchiveDay(day: 'Monday', shows: [
        Show(name: mix.show, episodes: [mix])
      ])
    }));
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: HomeScreen(
            apiService: api,
            playerService: player,
            storageService: StorageService())));
    await tester.pumpAndSettle();

    for (var selection = 0; selection < 2; selection++) {
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(mix.show));
      await tester.pumpAndSettle();
      await tester.tap(find.text(mix.name));
      await tester.pumpAndSettle();
      expect(find.byType(FullPlayer), findsOneWidget);
      expect(find.text(mix.name), findsOneWidget);
      expect(player.episodeStarts, 1);
    }
  });

  testWidgets('Desktop adaptive navigation highlights player destination', (
    tester,
  ) async {
    int? selectedIndex;

    const destinations = [
      NavigationItem(
        icon: Icons.radio_outlined,
        selectedIcon: Icons.radio,
        label: 'Live',
        index: 0,
      ),
      NavigationItem(
        icon: Icons.play_circle_outline,
        selectedIcon: Icons.play_circle_filled,
        label: 'Player',
        index: 1,
        isProminent: true,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: AdaptiveNavigation(
          currentIndex: 1,
          onDestinationSelected: (index) => selectedIndex = index,
          destinations: destinations,
          content: const SizedBox.shrink(),
        ),
      ),
    );

    final Icon activePlayerIcon =
        tester.widget(find.byIcon(Icons.play_circle_filled));
    expect(activePlayerIcon.color, isNotNull);

    await tester.tap(find.text('Live'));
    await tester.pump();
    expect(selectedIndex, 0);
  });
}

class _PendingApiService extends ApiService {
  final Completer<ApiResponse> _completer = Completer<ApiResponse>();
  String? nowPlaying;

  @override
  Future<ApiResponse> fetchArchive() => _completer.future;

  @override
  Future<String?> fetchNowPlaying() async => nowPlaying;
}

class _FailingApiService extends ApiService {
  int fetchCallCount = 0;

  @override
  Future<ApiResponse> fetchArchive() {
    fetchCallCount += 1;
    throw Exception('backend unreachable');
  }
}

class _FakeAudioPlayerService extends ChangeNotifier
    implements AudioPlayerService {
  @override
  PlayerState get state => PlayerState.idle;

  @override
  Episode? currentEpisode;

  int episodeStarts = 0;

  @override
  bool isLive = false;

  @override
  Duration get position => Duration.zero;

  @override
  Duration get duration => Duration.zero;

  @override
  String? get error => null;

  @override
  bool get hasError => false;

  @override
  bool get isPlaying => false;

  @override
  bool get isLoading => false;

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> playEpisode(Episode episode, {Duration? startPosition}) async {
    isLive = false;
    currentEpisode = episode;
    episodeStarts++;
    notifyListeners();
  }

  @override
  Future<void> playLiveStream(String url) async {
    isLive = true;
    currentEpisode = null;
    notifyListeners();
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> skipBackward(Duration duration) async {}

  @override
  Future<void> skipForward(Duration duration) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> togglePlayPause() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
