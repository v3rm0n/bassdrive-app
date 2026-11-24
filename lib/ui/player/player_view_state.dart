import 'package:flutter/material.dart';

import '../../services/audio_player_service.dart';

@immutable
class PlayerViewState {
  const PlayerViewState({
    required this.isPlaying,
    required this.isLoading,
    required this.isLive,
    required this.hasContent,
    required this.title,
    required this.subtitle,
    required this.position,
    required this.duration,
    this.detail,
  });

  final bool isPlaying;
  final bool isLoading;
  final bool isLive;
  final bool hasContent;
  final String title;
  final String subtitle;

  /// Secondary line under the subtitle, such as the broadcast date.
  final String? detail;
  final Duration position;
  final Duration duration;

  bool get showTimeline => !isLive && hasContent;

  bool get canSeek => duration > Duration.zero;

  factory PlayerViewState.fromService(AudioPlayerService service) {
    final episode = service.currentEpisode;
    final hasContent = service.isLive || episode != null;

    final String title;
    final String subtitle;
    String? detail;
    if (service.isLive) {
      title = 'Bassdrive live';
      subtitle = 'Worldwide drum & bass, around the clock';
    } else if (episode != null) {
      title = episode.title;
      subtitle = episode.show;
      detail = episode.dateLabel;
    } else {
      title = 'Bassdrive';
      subtitle = 'Press play to tune in to the live stream';
    }

    return PlayerViewState(
      isPlaying: service.isPlaying,
      isLoading: service.isLoading,
      isLive: service.isLive,
      hasContent: hasContent,
      title: title,
      subtitle: subtitle,
      detail: detail,
      position: service.position,
      duration: service.duration,
    );
  }
}
