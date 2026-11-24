import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../ui/player/player_primitives.dart';
import '../ui/theme/app_theme_tokens.dart';

class LiveStreamScreen extends StatelessWidget {
  final AudioPlayerService playerService;
  final String liveStreamUrl;
  final StorageService storageService;

  const LiveStreamScreen({
    super.key,
    required this.playerService,
    required this.liveStreamUrl,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLivePlaying = playerService.isLive && playerService.isPlaying;
    final bool isLivePaused = playerService.isLive && !playerService.isPlaying;
    final episode = playerService.isLive ? null : playerService.currentEpisode;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final speakerSize = (constraints.maxHeight * 0.4)
                .clamp(180.0, wide ? 380.0 : 300.0)
                .toDouble();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? AppSpacing.xxl : AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.lg * 2,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bassdrive',
                          style: AppTypography.display(
                            size: wide ? 88 : 64,
                            weight: FontWeight.w900,
                            height: 0.85,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Worldwide drum & bass, live around the clock.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Center(
                          child: GestureDetector(
                            onLongPress: () => _showDeveloperMenu(context),
                            child: SizedBox(
                              width: speakerSize,
                              height: speakerSize + AppSpacing.md,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  SpeakerCone(
                                    size: speakerSize,
                                    isPlaying: isLivePlaying,
                                    accent: AppColors.onAir,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: LiveBadge(
                                      isPlaying: isLivePlaying,
                                      isReadyState: !playerService.isLive,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (playerService.hasError)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppColors.error, size: 20),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    playerService.error ??
                                        'Playback stopped. Try again.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (episode != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You\'re listening to an archived show',
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  episode.title,
                                  style: theme.textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: isLivePlaying
                              ? OutlinedButton.icon(
                                  onPressed: playerService.pause,
                                  icon: const Icon(Icons.pause),
                                  label: const Text('Pause live stream'),
                                )
                              : ElevatedButton.icon(
                                  onPressed: isLivePaused
                                      ? playerService.togglePlayPause
                                      : () => playerService
                                          .playLiveStream(liveStreamUrl),
                                  icon: const Icon(Icons.play_arrow),
                                  label: Text(
                                    episode != null
                                        ? 'Switch to live'
                                        : 'Listen live',
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeveloperMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Developer Menu',
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Secret settings for debugging',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Clear All App State',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text(
                  'Removes all saved progress, completed episodes, and settings',
                ),
                onTap: () => _showClearConfirmation(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Clear All App State?'),
        content: const Text(
          'This will permanently delete all listening progress, completed episodes, and app settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await storageService.clearAllAppState();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All app state has been cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: AppColors.onSignal,
            ),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }
}
