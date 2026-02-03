import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';
import '../widgets/audio_controls.dart';

class LiveStreamScreen extends StatelessWidget {
  final AudioPlayerService playerService;
  final String liveStreamUrl;

  const LiveStreamScreen({
    super.key,
    required this.playerService,
    required this.liveStreamUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showPlayButton =
        !playerService.isLive && !playerService.isPlaying;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.radio, size: 100, color: Colors.white),
              ),
              const SizedBox(height: 40),
              Text(
                'Bassdrive Live',
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '24/7 Drum \u0026 Bass Radio',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: playerService.isPlaying && playerService.isLive
                      ? Colors.green.withValues(alpha: 0.2)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (playerService.isPlaying && playerService.isLive)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      playerService.isPlaying && playerService.isLive
                          ? 'LIVE'
                          : 'OFFLINE',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: playerService.isPlaying && playerService.isLive
                            ? Colors.green
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (playerService.hasError)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          playerService.error ?? 'An error occurred',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (showPlayButton)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        playerService.playLiveStream(liveStreamUrl),
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(
                      'Start Listening',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                )
              else
                AudioControls(
                  playerService: playerService,
                  showSkipButtons: false,
                  iconSize: 48,
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
