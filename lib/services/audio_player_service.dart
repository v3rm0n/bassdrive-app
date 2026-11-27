import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/episode.dart';
import '../services/storage_service.dart';
import '../services/download_service.dart';
import '../services/local_file_store.dart';

enum PlayerState { idle, loading, playing, paused, buffering, error }

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player;
  final StorageService _storageService = StorageService();
  final DownloadService _downloadService;
  int _request = 0;
  bool _changingSource = false;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  PlayerState _state = PlayerState.idle;
  Episode? _currentEpisode;
  String? _liveStreamUrl;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLive = false;
  String? _error;

  // Artwork cache for iOS lock screen
  Uri? _artworkUri;
  bool _artworkPrepared = false;

  // Listening time tracking
  DateTime? _playbackStartTime;
  Timer? _listeningTimeTimer;
  static const _listeningTimeInterval = Duration(seconds: 10);

  AudioPlayerService({AudioPlayer? player, DownloadService? downloads})
      : _player = player ?? AudioPlayer(),
        _downloadService = downloads ?? DownloadService() {
    _initializePlayer();
  }

  // Prepare artwork for iOS lock screen by copying asset to temp file
  Future<void> _prepareArtwork() async {
    if (_artworkPrepared) return;
    if (!LocalFileStore.isSupported) {
      _artworkPrepared = true;
      return;
    }

    try {
      final byteData = await rootBundle.load('assets/icon/icon.png');
      final bytes = byteData.buffer.asUint8List();
      _artworkUri = await LocalFileStore.writeTempAssetFile(
        'bassdrive_artwork.png',
        bytes,
      );
      _artworkPrepared = true;
    } catch (e) {
      debugPrint('Failed to prepare artwork: $e');
    }
  }

  /// Upgrades known Bassdrive archive HTTP URLs to HTTPS so playback works
  /// on Web (no mixed content) and iOS App Transport Security.
  static String normalizeStreamUrl(String url) {
    const httpArchivePrefix = 'http://archives.bassdrivearchive.com/';
    if (url.startsWith(httpArchivePrefix)) {
      return 'https://archives.bassdrivearchive.com/${url.substring(httpArchivePrefix.length)}';
    }
    return url;
  }

  void _initializePlayer() {
    _subscriptions.add(_player.positionStream.listen((position) {
      if (_changingSource) return;
      _position = position;
      notifyListeners();
    }));
    _subscriptions.add(_player.durationStream.listen((duration) {
      if (_changingSource) return;
      _duration = duration ?? Duration.zero;
      notifyListeners();
    }));
    _subscriptions.add(_player.playerStateStream.listen((state) {
      if (!_changingSource && !hasError) {
        _updatePlayerState(state.processingState, state.playing);
      }
    }));
    _subscriptions.add(_player.errorStream.listen((error) {
      if (!_changingSource) _reportError(error);
    }));
  }

  void _updatePlayerState(ProcessingState processing, bool playing) {
    _state = switch (processing) {
      ProcessingState.loading => PlayerState.loading,
      ProcessingState.buffering =>
        playing ? PlayerState.buffering : PlayerState.paused,
      ProcessingState.ready =>
        playing ? PlayerState.playing : PlayerState.paused,
      ProcessingState.completed || ProcessingState.idle => PlayerState.idle,
    };
    if (processing == ProcessingState.completed) {
      final episode = _currentEpisode;
      _stopListeningTimeTracking();
      if (episode != null) {
        unawaited(_storageService.markEpisodeCompleted(episode.id));
      }
      _currentEpisode = null;
      _isLive = false;
    }
    if (isPlaying) {
      _startListeningTimeTracking();
    } else {
      _stopListeningTimeTracking();
    }
    notifyListeners();
  }

  void _reportError(Object error) {
    _error = error.toString();
    _state = PlayerState.error;
    _stopListeningTimeTracking();
    notifyListeners();
  }

  void _startListeningTimeTracking() {
    if (_playbackStartTime != null) return;
    _playbackStartTime = DateTime.now();

    // Start a periodic timer to save listening time every 10 seconds
    _listeningTimeTimer = Timer.periodic(_listeningTimeInterval, (_) {
      _saveListeningTimeChunk();
    });
  }

  void _stopListeningTimeTracking() {
    // Save any accumulated time
    _saveListeningTimeChunk();

    // Cancel the timer
    _listeningTimeTimer?.cancel();
    _listeningTimeTimer = null;
    _playbackStartTime = null;
  }

  void _saveListeningTimeChunk() {
    if (_playbackStartTime == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(_playbackStartTime!);

    if (elapsed.inSeconds > 0) {
      if (_isLive) {
        _storageService.addLiveStreamListeningTime(elapsed);
      } else {
        _storageService.addArchivesListeningTime(elapsed);
      }
    }

    // Reset the start time
    _playbackStartTime = now;
  }

  PlayerState get state => _state;
  Episode? get currentEpisode => _currentEpisode;
  bool get isLive => _isLive;
  Duration get position => _position;
  Duration get duration => _duration;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isPlaying => _state == PlayerState.playing;
  bool get isLoading =>
      _state == PlayerState.loading || _state == PlayerState.buffering;

  Future<void> playLiveStream(String url) {
    _liveStreamUrl = url;
    return _loadSource(url);
  }

  Future<void> playEpisode(Episode episode, {Duration? startPosition}) =>
      _loadSource(episode.encodedUrl,
          episode: episode, startPosition: startPosition);

  Future<void> _loadSource(String url,
      {Episode? episode, Duration? startPosition}) async {
    final request = ++_request;
    _stopListeningTimeTracking();
    _downloadService.cancelAutoDownloads();
    _changingSource = true;
    _state = PlayerState.loading;
    _currentEpisode = episode;
    _isLive = episode == null;
    _error = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();

    try {
      String? localPath;
      if (episode != null) {
        localPath = await _downloadService.getLocalPath(episode.id);
        startPosition ??=
            (await _storageService.getProgress(episode.id))?.position;
      }
      if (request != _request) return;
      await _prepareArtwork();
      if (request != _request) return;
      final source = AudioSource.uri(
          localPath == null
              ? Uri.parse(normalizeStreamUrl(url))
              : Uri.file(localPath),
          tag: MediaItem(
            id: episode?.id ?? 'live_stream',
            title: episode?.displayName ?? 'Bassdrive Live',
            artist: episode?.show ?? '24/7 Drum & Bass Radio',
            artUri: _artworkUri,
          ));
      await _player.setAudioSource(source, initialPosition: startPosition);
      if (request != _request) return;
      _position = _player.position;
      _duration = _player.duration ?? Duration.zero;
      _changingSource = false;
      unawaited(_play(request));
      _updatePlayerState(_player.processingState, _player.playing);
      if (episode != null && localPath == null && DownloadService.isSupported) {
        unawaited(
            _downloadService.downloadEpisode(episode, type: DownloadType.auto));
      }
    } catch (e) {
      if (request != _request) return;
      _changingSource = false;
      _reportError(e);
    }
  }

  Future<void> _play(int request) async {
    try {
      await _player.play();
    } catch (e) {
      if (request != _request) return;
      // A browser can expire the original tap while the episode loads.
      // Keep the loaded source so the player's Play button can start it.
      if (kIsWeb && !hasError && e.toString().contains('NotAllowedError')) {
        try {
          await _player.pause();
        } catch (pauseError) {
          if (request == _request) _reportError(pauseError);
          return;
        }
        if (request == _request && !hasError) {
          _updatePlayerState(ProcessingState.ready, false);
        }
        return;
      }
      _reportError(e);
    }
  }

  Future<void> play() async {
    final episode = _currentEpisode;
    if (hasError && episode != null) {
      await playEpisode(episode);
    } else if (_player.audioSource == null || hasError) {
      if (_liveStreamUrl != null) await playLiveStream(_liveStreamUrl!);
    } else {
      await _play(_request);
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing && !hasError) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> stop() async {
    final request = ++_request;
    _changingSource = true;
    _stopListeningTimeTracking();
    await _player.stop();
    if (request != _request) return;
    _changingSource = false;
    _error = null;
    _currentEpisode = null;
    _isLive = false;
    _state = PlayerState.idle;
    _stopListeningTimeTracking();
    notifyListeners();
  }

  Future<void> skipForward(Duration duration) async {
    final newPosition = _position + duration;
    await seek(newPosition < _duration ? newPosition : _duration);
  }

  Future<void> skipBackward(Duration duration) async {
    final newPosition = _position - duration;
    await seek(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  @override
  void dispose() {
    _stopListeningTimeTracking();
    ++_request;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _player.dispose();
    super.dispose();
  }
}
