import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../models/listening_progress.dart';
import '../models/show.dart';
import '../services/download_service.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../ui/theme/app_theme_tokens.dart';

// Re-export DownloadType for convenience
export '../services/download_service.dart' show DownloadType;

class EpisodeListItem extends StatefulWidget {
  final Episode episode;
  final Show? show;
  final AudioPlayerService playerService;
  final StorageService storageService;
  final VoidCallback? onOpenPlayer;
  final Widget? trailing;

  /// Whether to repeat the show name under the title. Off inside a show page.
  final bool showShowName;

  const EpisodeListItem({
    super.key,
    required this.episode,
    this.show,
    required this.playerService,
    required this.storageService,
    this.onOpenPlayer,
    this.trailing,
    this.showShowName = true,
  });

  @override
  State<EpisodeListItem> createState() => _EpisodeListItemState();
}

class _EpisodeListItemState extends State<EpisodeListItem> {
  ListeningProgress? _progress;
  bool _isLoading = true;
  bool _isFavourite = false;
  final DownloadService _downloadService = DownloadService();

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _loadFavouriteStatus();
    // Listen to player changes to update progress display
    widget.playerService.addListener(_onPlayerChanged);
    _downloadService.addListener(_onDownloadStateChanged);
  }

  void _onDownloadStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.playerService.removeListener(_onPlayerChanged);
    _downloadService.removeListener(_onDownloadStateChanged);
    super.dispose();
  }

  void _onPlayerChanged() {
    // Refresh UI when player state changes
    // This ensures the playing indicator updates when switching between episodes
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadProgress() async {
    final progress = await widget.storageService.getProgress(widget.episode.id);
    if (mounted) {
      setState(() {
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavouriteStatus() async {
    final isFavourite =
        await widget.storageService.isFavourite(widget.episode.id);
    if (mounted) {
      setState(() {
        _isFavourite = isFavourite;
      });
    }
  }

  Future<void> _toggleFavourite() async {
    await widget.storageService.toggleFavourite(widget.episode.id);
    await _loadFavouriteStatus();
  }

  Future<void> _playEpisode() async {
    final episode = widget.episode;
    final player = widget.playerService;
    if (player.currentEpisode?.id != episode.id || player.hasError) {
      await player.playEpisode(episode);
      if (!mounted || player.currentEpisode?.id != episode.id) return;
      if (player.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not play this episode. Try again.')),
        );
        return;
      }
    }
    widget.onOpenPlayer?.call();
  }

  Future<void> _downloadEpisode() async {
    await _downloadService.downloadEpisode(widget.episode,
        type: DownloadType.manual);
  }

  Widget _buildDownloadButton(ThemeData theme) {
    final status = _downloadService.getDownloadStatus(widget.episode.id);
    final progress = _downloadService.getDownloadProgress(widget.episode.id);

    switch (status) {
      case DownloadStatus.downloaded:
        return const IconButton(
          icon: Icon(Icons.download_done),
          tooltip: 'Downloaded',
          color: AppColors.signal,
          disabledColor: AppColors.signal,
          onPressed: null,
        );
      case DownloadStatus.downloading:
        return Tooltip(
          message: 'Downloading ${(progress * 100).toInt()}%',
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  backgroundColor: AppColors.outline,
                ),
              ),
            ),
          ),
        );
      case DownloadStatus.error:
        return IconButton(
          icon: const Icon(Icons.error_outline),
          tooltip: 'Download failed. Retry',
          color: AppColors.error,
          onPressed: _downloadEpisode,
        );
      case DownloadStatus.notDownloaded:
        return IconButton(
          icon: const Icon(Icons.download_outlined),
          tooltip: 'Download',
          color: AppColors.textMuted,
          onPressed: _downloadEpisode,
        );
    }
  }

  Widget _leading({required bool isPlaying, required bool isCompleted}) {
    final date = widget.episode.date;
    final Widget child;
    if (isPlaying) {
      child = const Icon(Icons.graphic_eq, color: AppColors.signal);
    } else if (date != null) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: AppTypography.display(
              size: 24,
              height: 1,
              color: isCompleted ? AppColors.textMuted : AppColors.textPrimary,
            ),
          ),
          Text(
            '${Episode.monthNames[date.month - 1].substring(0, 3)} '
            "'${(date.year % 100).toString().padLeft(2, '0')}",
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      );
    } else {
      child = const Icon(Icons.music_note, color: AppColors.textMuted);
    }
    return SizedBox(width: 48, height: 48, child: Center(child: child));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentEpisode =
        widget.playerService.currentEpisode?.id == widget.episode.id;
    final isCurrentlyPlaying =
        isCurrentEpisode && widget.playerService.isPlaying;

    // Use the player's live position for the loaded episode, stored progress
    // for everything else.
    ListeningProgress? progress;
    if (isCurrentEpisode && widget.playerService.duration > Duration.zero) {
      progress = ListeningProgress(
        episodeId: widget.episode.id,
        episodeName: widget.episode.displayName,
        showName: widget.episode.show,
        position: widget.playerService.position,
        duration: widget.playerService.duration,
        lastPlayed: DateTime.now(),
      );
    } else {
      progress = _isLoading ? null : _progress;
    }

    final isCompleted = progress?.isCompleted ?? false;
    final hasProgress =
        progress != null && progress.position > Duration.zero && !isCompleted;
    final progressPercentage =
        (progress?.duration != null && progress!.duration!.inMilliseconds > 0)
            ? progress.progressPercentage
            : 0.0;

    final notes = [
      if (widget.showShowName) widget.episode.show,
      if (isCompleted) 'Played',
      if (hasProgress && progressPercentage > 0)
        '${(progressPercentage * 100).toInt()}% played',
    ];

    return InkWell(
      onTap: _playEpisode,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.xxs,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isCurrentEpisode ? AppColors.surface : null,
          border: const Border(bottom: BorderSide(color: AppColors.outline)),
        ),
        child: Row(
          children: [
            _leading(
              isPlaying: isCurrentlyPlaying,
              isCompleted: isCompleted,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.episode.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isCurrentEpisode
                          ? AppColors.signal
                          : isCompleted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      notes.join(', '),
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (hasProgress) ...[
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progressPercentage,
                        minHeight: 3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            widget.trailing ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDownloadButton(theme),
                    IconButton(
                      icon: Icon(
                        _isFavourite ? Icons.favorite : Icons.favorite_border,
                      ),
                      tooltip: _isFavourite
                          ? 'Remove from favourites'
                          : 'Add to favourites',
                      color:
                          _isFavourite ? AppColors.signal : AppColors.textMuted,
                      onPressed: _toggleFavourite,
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
