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
            width: 44,
            height: 44,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
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

  Widget _leading({
    required bool isCurrentEpisode,
    required bool isPlaying,
    required bool isCompleted,
  }) {
    final date = widget.episode.date;
    final Widget child;
    if (isPlaying) {
      child = const Icon(Icons.graphic_eq_rounded, color: AppColors.signal);
    } else if (date != null) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: AppTypography.display(
              size: 22,
              height: 0.95,
              color: isCurrentEpisode
                  ? AppColors.signal
                  : (isCompleted ? AppColors.textMuted : AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${Episode.monthNames[date.month - 1].substring(0, 3).toUpperCase()} '
            "'${(date.year % 100).toString().padLeft(2, '0')}",
            style: AppTypography.kicker(
              size: 9.5,
              letterSpacing: 0.5,
              color: isCurrentEpisode
                  ? AppColors.signal
                  : AppColors.textMuted,
            ),
          ),
        ],
      );
    } else {
      child = Icon(
        Icons.music_note_rounded,
        color: isCurrentEpisode ? AppColors.signal : AppColors.textMuted,
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isCurrentEpisode
            ? AppColors.signalSurface
            : AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: isCurrentEpisode ? AppColors.signal : AppColors.outline,
        ),
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentEpisode =
        widget.playerService.currentEpisode?.id == widget.episode.id;
    final isCurrentlyPlaying =
        isCurrentEpisode && widget.playerService.isPlaying;

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

    final dateLabel = widget.episode.dateLabel;
    final notes = [
      if (widget.showShowName) widget.episode.show,
      if (!widget.showShowName && dateLabel != null) 'Aired $dateLabel',
      if (isCompleted) 'Played',
      if (hasProgress && progressPercentage > 0)
        '${(progressPercentage * 100).toInt()}% played',
    ];

    return Material(
      color: isCurrentEpisode ? AppColors.surface : Colors.transparent,
      child: InkWell(
        onTap: _playEpisode,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            13,
            AppSpacing.xs,
            13,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isCurrentEpisode ? AppColors.signal : Colors.transparent,
                width: 3,
              ),
              bottom: const BorderSide(color: AppColors.outline),
            ),
          ),
          child: Row(
            children: [
              _leading(
                isCurrentEpisode: isCurrentEpisode,
                isPlaying: isCurrentlyPlaying,
                isCompleted: isCompleted,
              ),
              const SizedBox(width: AppSpacing.md),
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
                      const SizedBox(height: 3),
                      Text(
                        notes.join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isCurrentEpisode
                              ? AppColors.textSecondary
                              : AppColors.textMuted,
                        ),
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
                          _isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        tooltip: _isFavourite
                            ? 'Remove from favourites'
                            : 'Add to favourites',
                        color: _isFavourite
                            ? AppColors.signal
                            : AppColors.textMuted,
                        onPressed: _toggleFavourite,
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
