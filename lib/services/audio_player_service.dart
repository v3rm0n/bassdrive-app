import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/episode.dart';
import '../services/storage_service.dart';
import '../services/download_service.dart';

enum PlayerState { idle, loading, playing, paused, buffering, error }

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final StorageService _storageService = StorageService();
  final DownloadService _downloadService = DownloadService();

  PlayerState _state = PlayerState.idle;
  Episode? _currentEpisode;
  String? _liveStreamUrl;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLive = false;
  String? _error;

  // Listening time tracking
  DateTime? _playbackStartTime;
  Timer? _listeningTimeTimer;
  static const _listeningTimeInterval = Duration(seconds: 10);

  AudioPlayerService() {
    _initializePlayer();
  }

  void _initializePlayer() {
    _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

    _player.playerStateStream.listen((state) {
      if (state.playing) {
        _state = PlayerState.playing;
        _startListeningTimeTracking();
      } else if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        _state = PlayerState.buffering;
        _stopListeningTimeTracking();
      } else if (state.processingState == ProcessingState.ready) {
        _state = PlayerState.paused;
        _stopListeningTimeTracking();
      } else if (state.processingState == ProcessingState.idle) {
        _state = PlayerState.idle;
        _stopListeningTimeTracking();
      } else if (state.processingState == ProcessingState.completed) {
        _state = PlayerState.idle;
        _currentEpisode = null;
        _stopListeningTimeTracking();
      }

      notifyListeners();
    });

    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        _error = e.toString();
        _state = PlayerState.error;
        _stopListeningTimeTracking();
        notifyListeners();
      },
    );
  }

  void _startListeningTimeTracking() {
    _playbackStartTime ??= DateTime.now();

    // Cancel any existing timer
    _listeningTimeTimer?.cancel();

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

  Future<void> playLiveStream(String url) async {
    try {
      _state = PlayerState.loading;
      _isLive = true;
      _currentEpisode = null;
      _error = null;
      _stopListeningTimeTracking();
      notifyListeners();

      _liveStreamUrl = url;

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: const MediaItem(
            id: 'live_stream',
            title: 'Bassdrive Live',
            artist: '24/7 Drum & Bass Radio',
            artUri: null,
          ),
        ),
      );

      await _player.play();
    } catch (e) {
      _error = 'Failed to play live stream: $e';
      _state = PlayerState.error;
      _stopListeningTimeTracking();
      notifyListeners();
    }
  }

  Future<void> playEpisode(Episode episode, {Duration? startPosition}) async {
    try {
      _state = PlayerState.loading;
      _isLive = false;
      _currentEpisode = episode;
      _error = null;
      _stopListeningTimeTracking();
      notifyListeners();

      // Check if episode is downloaded locally
      Uri audioUri = Uri.parse(episode.encodedUrl);
      final localPath = await _downloadService.getLocalPath(episode.id);
      if (localPath != null) {
        final file = File(localPath);
        if (await file.exists()) {
          // Use Uri.file() to properly handle Windows file paths
          audioUri = Uri.file(localPath);
        }
      }

      await _player.setAudioSource(
        AudioSource.uri(
          audioUri,
          tag: MediaItem(
            id: episode.id,
            title: episode.displayName,
            artist: episode.show,
            artUri: null,
          ),
        ),
      );

      if (startPosition != null && startPosition > Duration.zero) {
        await _player.seek(startPosition);
      }

      await _player.play();

      // Automatically download episode for offline listening
      _downloadService.downloadEpisode(episode);
    } catch (e) {
      _error = 'Failed to play episode: $e';
      _state = PlayerState.error;
      _stopListeningTimeTracking();
      notifyListeners();
    }
  }

  Future<void> play() async {
    // Guard against playing when no audio source is set
    if (_player.audioSource == null) {
      if (_liveStreamUrl != null) {
        await playLiveStream(_liveStreamUrl!);
      }
      return;
    }
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> stop() async {
    await _player.stop();
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
    _player.dispose();
    super.dispose();
  }
}
