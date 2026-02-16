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
  });

  final bool isPlaying;
  final bool isLoading;
  final bool isLive;
  final bool hasContent;
  final String title;
  final String subtitle;
  final Duration position;
  final Duration duration;

  bool get showTimeline => !isLive && hasContent;

  bool get canSeek => duration > Duration.zero;

  factory PlayerViewState.fromService(AudioPlayerService service) {
    final hasContent = service.isLive || service.currentEpisode != null;

    final title = hasContent
        ? (service.isLive
            ? 'Bassdrive Live'
            : (service.currentEpisode?.displayName ?? 'Bassdrive'))
        : 'Bassdrive';

    final subtitle = hasContent
        ? (service.isLive
            ? '24/7 Drum & Bass Radio'
            : (service.currentEpisode?.show ?? 'Ready to Play'))
        : 'Ready to Play';

    return PlayerViewState(
      isPlaying: service.isPlaying,
      isLoading: service.isLoading,
      isLive: service.isLive,
      hasContent: hasContent,
      title: title,
      subtitle: subtitle,
      position: service.position,
      duration: service.duration,
    );
  }
}
