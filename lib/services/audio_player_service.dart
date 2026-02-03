import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/episode.dart';

enum PlayerState { idle, loading, playing, paused, buffering, error }

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  PlayerState _state = PlayerState.idle;
  Episode? _currentEpisode;
  String? _liveStreamUrl;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLive = false;
  String? _error;

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
      } else if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        _state = PlayerState.buffering;
      } else if (state.processingState == ProcessingState.ready) {
        _state = PlayerState.paused;
      } else if (state.processingState == ProcessingState.idle) {
        _state = PlayerState.idle;
      } else if (state.processingState == ProcessingState.completed) {
        _state = PlayerState.idle;
        _currentEpisode = null;
      }
      notifyListeners();
    });

    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        _error = e.toString();
        _state = PlayerState.error;
        notifyListeners();
      },
    );
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
      notifyListeners();
    }
  }

  Future<void> playEpisode(Episode episode, {Duration? startPosition}) async {
    try {
      _state = PlayerState.loading;
      _isLive = false;
      _currentEpisode = episode;
      _error = null;
      notifyListeners();

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(episode.encodedUrl),
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
    } catch (e) {
      _error = 'Failed to play episode: $e';
      _state = PlayerState.error;
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
    _player.dispose();
    super.dispose();
  }
}
