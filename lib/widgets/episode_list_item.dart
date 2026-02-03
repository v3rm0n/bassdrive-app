import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../models/listening_progress.dart';
import '../models/show.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class EpisodeListItem extends StatefulWidget {
  final Episode episode;
  final Show show;
  final AudioPlayerService playerService;
  final StorageService storageService;
  final VoidCallback? onTap;

  const EpisodeListItem({
    super.key,
    required this.episode,
    required this.show,
    required this.playerService,
    required this.storageService,
    this.onTap,
  });

  @override
  State<EpisodeListItem> createState() => _EpisodeListItemState();
}

class _EpisodeListItemState extends State<EpisodeListItem> {
  ListeningProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    // Listen to player changes to update progress display
    widget.playerService.addListener(_onPlayerChanged);
  }

  @override
  void dispose() {
    widget.playerService.removeListener(_onPlayerChanged);
    super.dispose();
  }

  void _onPlayerChanged() {
    // Refresh progress when this episode is currently playing
    if (widget.playerService.currentEpisode?.id == widget.episode.id) {
      _loadProgress();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentlyPlaying =
        widget.playerService.currentEpisode?.id == widget.episode.id &&
        widget.playerService.isPlaying;

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

    final progress = _progress;
    final hasProgress =
        progress != null &&
        progress.position > const Duration(seconds: 10) &&
        !progress.isCompleted;
    final isCompleted = progress?.isCompleted ?? false;

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
          Text(
            widget.episode.show,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasProgress) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress.progressPercentage,
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
                  '${(progress.progressPercentage * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ] else if (isCompleted)
            Text(
              'Completed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontSize: 11,
              ),
            ),
        ],
      ),
      trailing: isCurrentlyPlaying
          ? IconButton(
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
            )
          : hasProgress
          ? IconButton(
              icon: const Icon(Icons.play_circle_outline),
              onPressed: widget.onTap,
            )
          : null,
      onTap: widget.onTap,
    );
  }
}
