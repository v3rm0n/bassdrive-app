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
      height: 88 + bottomPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.3),
                theme.colorScheme.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
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
                  child: SliderTheme(
                    data: theme.sliderTheme.copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor:
                          theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      thumbColor: theme.colorScheme.primary,
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
              _buildControlButton(
                icon: Icons.replay_10,
                onPressed: () =>
                    playerService.skipBackward(const Duration(seconds: 10)),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                size: 24,
              ),
              const SizedBox(width: 16),
            ],
            // Play/Pause button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: theme.colorScheme.onPrimary,
                      ),
                      iconSize: 24,
                      onPressed: () => playerService.togglePlayPause(),
                    ),
            ),
            const SizedBox(width: 16),
            if (!playerService.isLive) ...[
              _buildControlButton(
                icon: Icons.forward_30,
                onPressed: () =>
                    playerService.skipForward(const Duration(seconds: 30)),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                size: 24,
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
        _buildControlButton(
          icon: Icons.volume_up,
          onPressed: () {
            // Volume control could be implemented
          },
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 22,
        ),
        const SizedBox(width: 8),
        // Full player button
        _buildControlButton(
          icon: Icons.open_in_full,
          onPressed: onOpenFullPlayer,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 22,
        ),
        const SizedBox(width: 8),
        // Stop button
        _buildControlButton(
          icon: Icons.stop,
          onPressed: () => playerService.stop(),
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 22,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required double size,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
