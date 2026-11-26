import 'package:flutter/material.dart';

import '../services/audio_player_service.dart';
import '../ui/player/speaker_cone.dart';
import '../ui/theme/app_theme_tokens.dart';

/// Compact broadcast transport dock shown above bottom navigation (mobile)
/// or at the bottom of the content console (desktop) while browsing lists.
class MiniPlayer extends StatelessWidget {
  final AudioPlayerService playerService;
  final String? nowPlaying;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.playerService,
    this.nowPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: playerService,
      builder: (context, _) {
        final episode = playerService.currentEpisode;
        final isLive = playerService.isLive;
        if (!isLive && episode == null) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final isPlaying = playerService.isPlaying;
        final isLoading = playerService.isLoading;
        final accent = isLive ? AppColors.onAir : AppColors.signal;

        final double progress = (!isLive &&
                playerService.duration.inMilliseconds > 0)
            ? (playerService.position.inMilliseconds /
                    playerService.duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : 0.0;

        final String kickerText = isLive
            ? (isPlaying ? 'LIVE ON AIR' : 'LIVE PAUSED')
            : 'ARCHIVE DECK';
        final String headline = isLive
            ? 'Bassdrive 24/7 Stream / ${nowPlaying ?? "Worldwide Drum & Bass"}'
            : '${episode!.title} / ${episode.dateLabel ?? episode.show}';

        return Material(
          color: AppColors.surface,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.outlineStrong),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isLive && progress > 0)
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      color: AppColors.signal,
                      backgroundColor: AppColors.outline,
                    )
                  else if (isLive && isPlaying)
                    Container(
                      height: 2,
                      color: AppColors.onAir.withValues(alpha: 0.85),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        SpeakerCone(
                          size: 38,
                          isPlaying: isPlaying,
                          accent: accent,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isPlaying
                                          ? accent
                                          : AppColors.textMuted,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    kickerText,
                                    style: AppTypography.kicker(
                                      size: 10,
                                      color: isPlaying
                                          ? accent
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                headline,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: playerService.togglePlayPause,
                            tooltip: isPlaying ? 'Pause' : 'Play',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceRaised,
                              side: const BorderSide(color: AppColors.outline),
                            ),
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.signal,
                              size: 22,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
