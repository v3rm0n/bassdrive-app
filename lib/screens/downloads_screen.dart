import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../models/listening_progress.dart';
import '../services/audio_player_service.dart';
import '../services/download_service.dart';
import '../services/storage_service.dart';
import '../widgets/episode_list_item.dart';

class DownloadsScreen extends StatefulWidget {
  final AudioPlayerService playerService;
  final StorageService storageService;
  final VoidCallback onOpenPlayer;

  const DownloadsScreen({
    super.key,
    required this.playerService,
    required this.storageService,
    required this.onOpenPlayer,
  });

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final DownloadService _downloadService = DownloadService();

  @override
  void initState() {
    super.initState();
    _downloadService.addListener(_onDownloadStateChanged);
  }

  @override
  void dispose() {
    _downloadService.removeListener(_onDownloadStateChanged);
    super.dispose();
  }

  void _onDownloadStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _playEpisode(Episode episode) async {
    // Check if this episode is already the current episode
    final isCurrentEpisode =
        widget.playerService.currentEpisode?.id == episode.id;

    if (isCurrentEpisode) {
      // If already playing, open the full player
      widget.onOpenPlayer();
      return;
    }

    final progress = await widget.storageService.getProgress(episode.id);

    await widget.playerService.playEpisode(
      episode,
      startPosition: progress?.position,
    );

    await widget.storageService.saveProgress(
      ListeningProgress(
        episodeId: episode.id,
        episodeName: episode.displayName,
        showName: episode.show,
        position: progress?.position ?? Duration.zero,
        lastPlayed: DateTime.now(),
      ),
    );
  }

  Future<void> _deleteAllDownloads() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Downloads'),
        content: const Text(
          'Are you sure you want to delete all downloaded episodes? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _downloadService.deleteAllDownloads();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All downloads deleted')),
        );
      }
    }
  }

  Future<void> _deleteDownload(String episodeId, String episodeName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Delete "$episodeName" from downloads?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _downloadService.deleteDownload(episodeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download deleted')),
        );
      }
    }
  }

  String _formatStorageSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloadedEpisodes = _downloadService.downloadedEpisodes.values
        .toList()
      ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (downloadedEpisodes.isNotEmpty)
            TextButton.icon(
              onPressed: _deleteAllDownloads,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete All'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Storage info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.storage,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Storage Used',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${downloadedEpisodes.length} episodes • ${_formatStorageSize(_downloadService.totalDownloadedBytes)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Downloads list
          Expanded(
            child: downloadedEpisodes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download_done,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Downloads',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Episodes you play will be automatically\ndownloaded for offline listening',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: downloadedEpisodes.length,
                    itemBuilder: (context, index) {
                      final downloaded = downloadedEpisodes[index];
                      final episode = Episode(
                        name: downloaded.episodeName,
                        show: downloaded.showName,
                        url: downloaded.originalUrl,
                        encodedUrl: downloaded.originalUrl,
                      );

                      return Dismissible(
                        key: Key(downloaded.episodeId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: theme.colorScheme.error,
                          child: Icon(
                            Icons.delete,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                        confirmDismiss: (_) async {
                          await _deleteDownload(
                            downloaded.episodeId,
                            downloaded.episodeName,
                          );
                          return false; // We handle deletion manually
                        },
                        child: EpisodeListItem(
                          episode: episode,
                          playerService: widget.playerService,
                          storageService: widget.storageService,
                          onTap: () => _playEpisode(episode),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                downloaded.formattedFileSize,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteDownload(
                                  downloaded.episodeId,
                                  downloaded.episodeName,
                                ),
                                color: theme.colorScheme.error,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
