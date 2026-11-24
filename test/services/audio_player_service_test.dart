import 'dart:async';

import 'package:bassdrive_radio/models/episode.dart';
import 'package:bassdrive_radio/models/listening_progress.dart';
import 'package:bassdrive_radio/services/audio_player_service.dart';
import 'package:bassdrive_radio/services/download_service.dart';
import 'package:bassdrive_radio/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _AudioBackend backend;
  late _Downloads downloads;
  late AudioPlayerService service;
  final episode = Episode(
      name: 'Mix',
      show: 'Show',
      url: 'https://example.com/mix.mp3',
      encodedUrl: 'https://example.com/mix.mp3');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().initialize();
    backend = _AudioBackend();
    downloads = _Downloads();
    service = AudioPlayerService(player: backend, downloads: downloads);
  });
  tearDown(() => service.dispose());

  test(
      'archive playback queues its download without waiting for the audio to finish',
      () async {
    final lookup =
        service.playEpisode(episode, startPosition: const Duration(minutes: 4));
    downloads.local.complete(null);
    await lookup.timeout(const Duration(seconds: 3));

    expect(backend.loaded, Uri.parse(episode.encodedUrl));
    expect(backend.position, const Duration(minutes: 4));
    expect(backend.playback.isCompleted, isFalse);
    expect(downloads.autoDownloads, [episode.id]);
    expect(service.isPlaying, isTrue);

    backend.events
        .add(audio.PlayerState(true, audio.ProcessingState.buffering));
    expect(service.state, PlayerState.buffering);
    expect(service.isPlaying, isFalse);
    backend.events
        .add(audio.PlayerState(true, audio.ProcessingState.completed));
    expect(service.state, PlayerState.idle);
    expect(service.currentEpisode, isNull);
  });

  test(
      'offline playback restores the saved position without a network download',
      () async {
    const resume = Duration(minutes: 12);
    await StorageService().saveProgress(ListeningProgress(
      episodeId: episode.id,
      episodeName: episode.name,
      showName: episode.show,
      position: resume,
      lastPlayed: DateTime.now(),
    ));
    downloads.local.complete('/offline/mix.mp3');
    await service.playEpisode(episode);
    expect(backend.loaded, Uri.file('/offline/mix.mp3'));
    expect(backend.position, resume);
    expect(downloads.autoDownloads, isEmpty);
  });

  test('a pending local lookup cannot replace a newer live selection',
      () async {
    final first = service.playEpisode(episode);
    await service.playLiveStream('https://example.com/live');
    downloads.local.complete('/offline/mix.mp3');
    await first;
    expect(backend.loaded, Uri.parse('https://example.com/live'));
    expect(service.isLive, isTrue);
    expect(downloads.autoDownloads, isEmpty);
  });
}

class _AudioBackend extends Fake implements audio.AudioPlayer {
  final events = StreamController<audio.PlayerState>.broadcast(sync: true);
  final playback = Completer<void>();
  Uri? loaded;

  @override
  Stream<audio.PlayerState> get playerStateStream => events.stream;
  @override
  Stream<Duration> get positionStream => const Stream.empty();
  @override
  Stream<Duration?> get durationStream => const Stream.empty();
  @override
  Stream<audio.PlayerException> get errorStream => const Stream.empty();
  @override
  Duration position = Duration.zero;
  @override
  Duration get duration => const Duration(hours: 1);
  @override
  audio.ProcessingState get processingState => audio.ProcessingState.ready;
  @override
  bool playing = false;

  @override
  Future<Duration?> setAudioSource(audio.AudioSource source,
      {bool preload = true,
      int? initialIndex,
      Duration? initialPosition}) async {
    loaded = (source as audio.UriAudioSource).uri;
    position = initialPosition ?? Duration.zero;
    return duration;
  }

  @override
  Future<void> play() {
    playing = true;
    return playback.future;
  }

  @override
  Future<void> dispose() async {
    playback.complete();
    await events.close();
  }
}

class _Downloads extends Fake implements DownloadService {
  final local = Completer<String?>();
  final autoDownloads = <String>[];

  @override
  Future<String?> getLocalPath(String episodeId) => local.future;

  @override
  void cancelAutoDownloads() {}

  @override
  Future<void> downloadEpisode(Episode episode,
      {DownloadType type = DownloadType.manual}) async {
    expect(type, DownloadType.auto);
    autoDownloads.add(episode.id);
  }
}
