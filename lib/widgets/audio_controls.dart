import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';

class AudioControls extends StatelessWidget {
  final AudioPlayerService playerService;
  final bool showSkipButtons;
  final double iconSize;
  final Color? iconColor;

  const AudioControls({
    super.key,
    required this.playerService,
    this.showSkipButtons = true,
    this.iconSize = 32,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showSkipButtons && !playerService.isLive) ...[
          IconButton(
            icon: Icon(Icons.replay_10, size: iconSize * 0.9),
            color: color,
            onPressed: () =>
                playerService.skipBackward(const Duration(seconds: 10)),
          ),
          const SizedBox(width: 16),
        ],
        Container(
          width: iconSize * 2,
          height: iconSize * 2,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: playerService.isLoading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    ),
                  )
                : IconButton(
                    key: ValueKey(playerService.isPlaying),
                    icon: Icon(
                      playerService.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: iconSize,
                      color: Colors.black,
                    ),
                    onPressed: playerService.togglePlayPause,
                  ),
          ),
        ),
        if (showSkipButtons && !playerService.isLive) ...[
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.forward_30, size: iconSize * 0.9),
            color: color,
            onPressed: () =>
                playerService.skipForward(const Duration(seconds: 30)),
          ),
        ],
      ],
    );
  }
}
