import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../ui/player/player_primitives.dart';
import '../ui/theme/app_theme_tokens.dart';

class LiveStreamScreen extends StatelessWidget {
  final AudioPlayerService playerService;
  final String liveStreamUrl;
  final String? nowPlaying;
  final StorageService storageService;

  const LiveStreamScreen({
    super.key,
    required this.playerService,
    required this.liveStreamUrl,
    this.nowPlaying,
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
            final compactHeight = constraints.maxHeight < 680;
            final speakerSize = (constraints.maxHeight * (compactHeight ? 0.32 : 0.36))
                .clamp(168.0, wide ? 340.0 : 272.0)
                .toDouble();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? AppSpacing.xxl : AppSpacing.lg,
                vertical: compactHeight ? AppSpacing.md : AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight -
                      (compactHeight ? AppSpacing.md * 2 : AppSpacing.lg * 2),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
                                border: Border.all(color: AppColors.outline),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sensors_rounded,
                                    size: 14,
                                    color: isLivePlaying
                                        ? AppColors.onAir
                                        : AppColors.signal,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '24/7 BROADCAST / 174 BPM',
                                    style: AppTypography.kicker(
                                      size: 10.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Bassdrive',
                              textAlign: TextAlign.center,
                              style: AppTypography.display(
                                size: wide ? 84 : 64,
                                weight: FontWeight.w900,
                                height: 0.86,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Worldwide drum & bass, live around the clock.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: compactHeight ? AppSpacing.md : AppSpacing.lg,
                        ),
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
                        SizedBox(
                          height: compactHeight ? AppSpacing.md : AppSpacing.lg,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            border: Border.all(
                              color: isLivePlaying
                                  ? AppColors.onAir.withValues(alpha: 0.45)
                                  : AppColors.outlineStrong,
                            ),
                          ),
                          child: Column(
                            children: [
                              if (nowPlaying case final title?)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Now playing',
                                        style: AppTypography.kicker(
                                          size: 10.5,
                                          color: isLivePlaying
                                              ? AppColors.onAir
                                              : AppColors.signal,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        title,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                )
                              else if (episode == null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.graphic_eq_rounded,
                                        size: 16,
                                        color: isLivePlaying
                                            ? AppColors.onAir
                                            : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isLivePlaying
                                            ? 'LIVE STREAM ACTIVE / DIRECT FEED'
                                            : 'DIRECT STREAM READY / 24/7 D&B',
                                        style: AppTypography.kicker(
                                          size: 10.5,
                                          color: isLivePlaying
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (playerService.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(AppRadii.sm),
                                      border: Border.all(
                                        color: AppColors.error
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Flexible(
                                          child: Text(
                                            playerService.error ??
                                                'Playback stopped. Try again.',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (episode != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md),
                                  child: Column(
                                    children: [
                                      Text(
                                        'You\'re listening to an archived show',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        episode.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: AppColors.signal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: isLivePlaying
                                    ? OutlinedButton.icon(
                                        onPressed: playerService.pause,
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.surfaceRaised,
                                          side: const BorderSide(
                                            color: AppColors.onAir,
                                            width: 1.5,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.pause_rounded,
                                          color: AppColors.onAir,
                                        ),
                                        label: const Text('Pause live stream'),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: isLivePaused
                                            ? playerService.togglePlayPause
                                            : () => playerService
                                                .playLiveStream(liveStreamUrl),
                                        icon: const Icon(
                                            Icons.play_arrow_rounded),
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
