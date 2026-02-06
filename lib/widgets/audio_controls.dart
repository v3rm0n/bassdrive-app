import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';

class AudioControls extends StatelessWidget {
  final AudioPlayerService playerService;
  final bool showSkipButtons;
  final double iconSize;
  final Color? iconColor;
  final VoidCallback? onPlayPressed;

  const AudioControls({
    super.key,
    required this.playerService,
    this.showSkipButtons = true,
    this.iconSize = 32,
    this.iconColor,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary;
    final isPlaying = playerService.isPlaying;
    final isLoading = playerService.isLoading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward 10s
        if (showSkipButtons && !playerService.isLive) ...[
          _buildSkipButton(
            context,
            icon: Icons.replay_10,
            onPressed: () =>
                playerService.skipBackward(const Duration(seconds: 10)),
            color: color,
          ),
          const SizedBox(width: 24),
        ],
        // Play/Pause button with animated container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: iconSize * 2.2,
          height: iconSize * 2.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isPlaying ? 0.4 : 0.2),
                blurRadius: isPlaying ? 20 : 10,
                spreadRadius: isPlaying ? 2 : 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isLoading
                  ? null
                  : (onPlayPressed ?? playerService.togglePlayPause),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: iconSize * 0.8,
                          height: iconSize * 0.8,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          key: ValueKey<bool>(isPlaying),
                          size: iconSize * 1.2,
                          color: theme.colorScheme.onPrimary,
                        ),
                ),
              ),
            ),
          ),
        ),
        // Skip forward 30s
        if (showSkipButtons && !playerService.isLive) ...[
          const SizedBox(width: 24),
          _buildSkipButton(
            context,
            icon: Icons.forward_30,
            onPressed: () =>
                playerService.skipForward(const Duration(seconds: 30)),
            color: color,
          ),
        ],
      ],
    );
  }

  Widget _buildSkipButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: iconSize * 0.9,
            color: color,
          ),
        ),
      ),
    );
  }
}
