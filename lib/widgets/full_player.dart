import 'package:flutter/material.dart';

import '../screens/listening_stats_screen.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../ui/player/player_primitives.dart';
import '../ui/theme/app_theme_tokens.dart';

class FullPlayer extends StatefulWidget {
  final AudioPlayerService playerService;
  final StorageService storageService;
  final String? liveStreamUrl;

  const FullPlayer({
    super.key,
    required this.playerService,
    required this.storageService,
    required this.liveStreamUrl,
  });

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  void _showStats() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListeningStatsScreen(
          storageService: widget.storageService,
        ),
      ),
    );
  }

  Future<void> _handlePlayButton() async {
    final hasContent = widget.playerService.isLive ||
        widget.playerService.currentEpisode != null;

    if (!hasContent) {
      // Start live stream when nothing is playing
      final url = widget.liveStreamUrl;
      if (url != null) await widget.playerService.playLiveStream(url);
    } else {
      // Toggle play/pause when something is already loaded
      await widget.playerService.togglePlayPause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.playerService,
      builder: (context, _) => _buildPlayer(context),
    );
  }

  Widget _buildPlayer(BuildContext context) {
    final viewState = PlayerViewState.fromService(widget.playerService);

    final isReadyState = !viewState.hasContent;
    final liveAvailable = widget.liveStreamUrl != null;
    final showLiveBadge = viewState.isLive || (isReadyState && liveAvailable);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart),
                    onPressed: _showStats,
                    tooltip: 'Listening stats',
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = PlayerLayoutScale.forViewport(
                      constraints.maxWidth, constraints.maxHeight);
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: scale.horizontalPadding,
                          vertical: AppSpacing.sm,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: scale.maxContentWidth,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PlayerHeroCover(
                                  scale: scale,
                                  isPlaying: viewState.isPlaying,
                                  isLive: viewState.isLive,
                                  badge: showLiveBadge
                                      ? LiveBadge(
                                          isPlaying: viewState.isPlaying,
                                          isReadyState: isReadyState,
                                        )
                                      : null,
                                ),
                                SizedBox(height: scale.sectionSpacing),
                                TrackMetaBlock(
                                  title: viewState.title,
                                  subtitle: isReadyState && !liveAvailable
                                      ? 'Choose an episode from Downloads'
                                      : viewState.subtitle,
                                  detail: viewState.detail,
                                  scale: scale,
                                ),
                                SizedBox(height: scale.sectionSpacing),
                                TimelineProgressRow(
                                  viewState: viewState,
                                  scale: scale,
                                  onSeek: widget.playerService.seek,
                                ),
                                if (!viewState.showTimeline)
                                  SizedBox(
                                    height: scale.timelineBottomSpacing,
                                  ),
                                TransportCluster(
                                  viewState: viewState,
                                  scale: scale,
                                  onPrimaryPressed:
                                      isReadyState && !liveAvailable
                                          ? null
                                          : _handlePlayButton,
                                  onSkipBack: viewState.showTimeline
                                      ? () => widget.playerService.skipBackward(
                                          const Duration(seconds: 10))
                                      : null,
                                  onSkipForward: viewState.showTimeline
                                      ? () => widget.playerService.skipForward(
                                          const Duration(seconds: 30))
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
