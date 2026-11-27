import 'package:flutter/material.dart';

import '../screens/listening_stats_screen.dart';
import '../services/audio_player_service.dart';
import '../services/download_service.dart';
import '../services/storage_service.dart';
import '../ui/player/player_primitives.dart';
import '../ui/theme/app_theme_tokens.dart';

class FullPlayer extends StatefulWidget {
  final AudioPlayerService playerService;
  final StorageService storageService;
  final String? liveStreamUrl;
  final String? nowPlaying;

  const FullPlayer({
    super.key,
    required this.playerService,
    required this.storageService,
    required this.liveStreamUrl,
    this.nowPlaying,
  });

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  final DownloadService _downloadService = DownloadService();
  bool _isFavourite = false;
  String? _loadedEpisodeId;

  @override
  void initState() {
    super.initState();
    _syncEpisodeStatus();
    widget.playerService.addListener(_syncEpisodeStatus);
    _downloadService.addListener(_onDownloadChanged);
  }

  @override
  void dispose() {
    widget.playerService.removeListener(_syncEpisodeStatus);
    _downloadService.removeListener(_onDownloadChanged);
    super.dispose();
  }

  void _onDownloadChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _syncEpisodeStatus() async {
    final episodeId = widget.playerService.currentEpisode?.id;
    if (episodeId == _loadedEpisodeId) return;
    _loadedEpisodeId = episodeId;
    if (episodeId == null) {
      if (mounted) setState(() => _isFavourite = false);
      return;
    }
    final fav = await widget.storageService.isFavourite(episodeId);
    if (mounted && _loadedEpisodeId == episodeId) {
      setState(() => _isFavourite = fav);
    }
  }

  Future<void> _toggleFavourite() async {
    final episode = widget.playerService.currentEpisode;
    if (episode == null) return;
    await widget.storageService.toggleFavourite(episode.id);
    final fav = await widget.storageService.isFavourite(episode.id);
    if (mounted) {
      setState(() => _isFavourite = fav);
    }
  }

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
    final viewState = PlayerViewState.fromService(
      widget.playerService,
      nowPlaying: widget.nowPlaying,
    );

    final isReadyState = !viewState.hasContent;
    final liveAvailable = widget.liveStreamUrl != null;
    final showLiveBadge = viewState.isLive || (isReadyState && liveAvailable);
    final currentEpisode = widget.playerService.currentEpisode;

    final String modeKicker = viewState.isLive
        ? 'LIVE STREAM DECK'
        : (currentEpisode != null ? 'ARCHIVE PLAYBACK' : 'BROADCAST DECK');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.xxs,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: viewState.isPlaying
                                ? (viewState.isLive
                                    ? AppColors.onAir
                                    : AppColors.signal)
                                : AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          modeKicker,
                          style: AppTypography.kicker(
                            size: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (currentEpisode != null && !viewState.isLive) ...[
                    IconButton(
                      icon: Icon(
                        _isFavourite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavourite
                            ? AppColors.signal
                            : AppColors.textSecondary,
                      ),
                      onPressed: _toggleFavourite,
                      tooltip: _isFavourite
                          ? 'Remove from favourites'
                          : 'Add to favourites',
                    ),
                  ],
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
                                      ? (DownloadService.isSupported
                                          ? 'Choose an episode from Downloads'
                                          : 'Check your connection and try again')
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
