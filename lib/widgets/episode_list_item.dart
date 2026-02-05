import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../models/listening_progress.dart';
import '../models/show.dart';
import '../services/download_service.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class EpisodeListItem extends StatefulWidget {
  final Episode episode;
  final Show? show;
  final AudioPlayerService playerService;
  final StorageService storageService;
  final VoidCallback? onTap;
  final Widget? trailing;

  const EpisodeListItem({
    super.key,
    required this.episode,
    this.show,
    required this.playerService,
    required this.storageService,
    this.onTap,
    this.trailing,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Check if this episode is loaded in the player (regardless of playing/paused state)
    final isCurrentEpisode =
        widget.playerService.currentEpisode?.id == widget.episode.id;
    final isCurrentlyPlaying =
        isCurrentEpisode && widget.playerService.isPlaying;

    if (_isLoading) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.music_note,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        title: Text(
          widget.episode.displayName,
          style: theme.textTheme.bodyLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          widget.episode.show,
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // Use player's real-time position/duration when this is the current episode
    // AND we have valid duration from the player
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
      // Use stored progress for previously played items
      progress = _progress;
    }

    // Show progress indicator if we have position data and it's not completed
    // Show if position > 0 (not just > 10s) to always show progress for played items
    final isCompleted = progress?.isCompleted ?? false;
    final hasProgress =
        progress != null && progress.position > Duration.zero && !isCompleted;

    // Calculate display percentage - use stored percentage if available, otherwise calculate
    // If we have position but no duration, we can't show percentage but we still show progress exists
    final progressPercentage =
        (progress?.duration != null && progress!.duration!.inMilliseconds > 0)
            ? progress.progressPercentage
            : 0.0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isCurrentlyPlaying
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isCurrentlyPlaying
              ? Icons.equalizer
              : isCompleted
                  ? Icons.check_circle
                  : Icons.music_note,
          color: isCurrentlyPlaying
              ? theme.colorScheme.primary
              : isCompleted
                  ? Colors.green
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      title: Text(
        widget.episode.displayName,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isCurrentlyPlaying ? FontWeight.w600 : FontWeight.normal,
          color: isCurrentlyPlaying ? theme.colorScheme.primary : null,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.episode.show,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCompleted) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.green,
                ),
              ],
              // Download indicator
              if (_downloadService.isDownloaded(widget.episode.id)) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.download_done,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
          if (hasProgress) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progressPercentage,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progressPercentage * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: widget.trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  _isFavourite ? Icons.favorite : Icons.favorite_border,
                ),
                iconSize: 24,
                color: _isFavourite
                    ? Colors.red
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                onPressed: _toggleFavourite,
              ),
              if (isCurrentEpisode)
                IconButton(
                  icon: Icon(
                    widget.playerService.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  iconSize: 32,
                  color: theme.colorScheme.primary,
                  onPressed: () {
                    if (widget.playerService.isPlaying) {
                      widget.playerService.pause();
                    } else {
                      widget.playerService.play();
                    }
                  },
                ),
            ],
          ),
      onTap: widget.onTap,
    );
  }
}
