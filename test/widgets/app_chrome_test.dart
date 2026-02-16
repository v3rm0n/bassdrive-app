import 'dart:async';

import 'package:bassdrive_radio/main.dart';
import 'package:bassdrive_radio/models/api_response.dart';
import 'package:bassdrive_radio/models/episode.dart';
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

  testWidgets('HomeScreen loading state uses console status copy', (
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

    expect(find.text('Booting broadcast console...'), findsOneWidget);
    expect(
        find.text('Loading live stream and archive signal.'), findsOneWidget);
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

    expect(find.text('Signal lost'), findsOneWidget);
    expect(find.text('Re-sync'), findsOneWidget);

    await tester.tap(find.text('Re-sync'));
    await tester.pump();
    expect(failingApi.fetchCallCount, 2);
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

  @override
  Future<ApiResponse> fetchArchive() => _completer.future;
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
  Episode? get currentEpisode => null;

  @override
  bool get isLive => false;

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
  Future<void> playEpisode(Episode episode, {Duration? startPosition}) async {}

  @override
  Future<void> playLiveStream(String url) async {}

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
