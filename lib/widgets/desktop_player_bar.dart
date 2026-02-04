import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';

class DesktopPlayerBar extends StatelessWidget {
  final AudioPlayerService playerService;
  final VoidCallback onOpenFullPlayer;

  const DesktopPlayerBar({
    super.key,
    required this.playerService,
    required this.onOpenFullPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 80 + bottomPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: 12 + bottomPadding,
        ),
        child: Row(
          children: [
            // Track Info
            Expanded(
              flex: 3,
              child: _buildTrackInfo(theme),
            ),
            // Playback Controls
            Expanded(
              flex: 4,
              child: _buildPlaybackControls(theme),
            ),
            // Volume & Extra Controls
            Expanded(
              flex: 3,
              child: _buildExtraControls(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackInfo(ThemeData theme) {
    String title;
    String subtitle;

    if (playerService.isLive) {
      title = 'Bassdrive Live';
      subtitle = '24/7 Drum & Bass Radio';
    } else if (playerService.currentEpisode != null) {
      final episode = playerService.currentEpisode!;
      title = episode.displayName;
      subtitle = episode.show;
    } else {
      title = 'Not Playing';
      subtitle = 'Select a stream to start';
    }

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            playerService.isLive ? Icons.radio : Icons.music_note,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(ThemeData theme) {
    final isPlaying = playerService.isPlaying;
    final isLoading = playerService.isLoading;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Progress bar for archives
        if (!playerService.isLive && playerService.duration > Duration.zero)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  _formatDuration(playerService.position),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Builder(
                    builder: (context) => SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: playerService.position.inMilliseconds.toDouble(),
                        max: playerService.duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          playerService.seek(
                            Duration(milliseconds: value.toInt()),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(playerService.duration),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!playerService.isLive) ...[
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: null, // Could implement skip to previous
                iconSize: 28,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: theme.colorScheme.onPrimary,
                      ),
                      iconSize: 28,
                      onPressed: () => playerService.togglePlayPause(),
                    ),
            ),
            const SizedBox(width: 8),
            if (!playerService.isLive) ...[
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: null, // Could implement skip to next
                iconSize: 28,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildExtraControls(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Volume control (placeholder - would need volume plugin)
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            // Volume control could be implemented
          },
          iconSize: 24,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        // Full player button
        IconButton(
          icon: const Icon(Icons.open_in_full),
          onPressed: onOpenFullPlayer,
          iconSize: 24,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        // Stop button
        IconButton(
          icon: const Icon(Icons.stop),
          onPressed: () => playerService.stop(),
          iconSize: 24,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
