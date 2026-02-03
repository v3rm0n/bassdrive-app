import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';

class MiniPlayer extends StatelessWidget {
  final AudioPlayerService playerService;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.playerService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = playerService.isLive
        ? 'Bassdrive Live'
        : (playerService.currentEpisode?.displayName ?? 'Unknown');
    final subtitle = playerService.isLive
        ? '24/7 Drum & Bass Radio'
        : (playerService.currentEpisode?.show ?? '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                playerService.isLive ? Icons.radio : Icons.music_note,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (playerService.isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: Icon(
                  playerService.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: playerService.togglePlayPause,
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
