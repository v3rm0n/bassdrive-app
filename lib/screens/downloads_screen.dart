import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../services/audio_player_service.dart';
import '../services/download_service.dart';
import '../services/storage_service.dart';
import '../ui/theme/app_theme_tokens.dart';
import '../widgets/episode_list_item.dart';

class DownloadsScreen extends StatefulWidget {
  final AudioPlayerService playerService;
  final StorageService storageService;
  final VoidCallback? onPlayEpisode;
  const DownloadsScreen({
    super.key,
    required this.playerService,
    required this.storageService,
    this.onPlayEpisode,
  });

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  static const int _maxStorageBytes = 2 * 1024 * 1024 * 1024; // 2 GB limit
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
    final totalBytes = _downloadService.totalDownloadedBytes;
    final usageRatio = (totalBytes / _maxStorageBytes).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (downloadedEpisodes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: TextButton.icon(
                onPressed: _deleteAllDownloads,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete All'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Studio storage telemetry card
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.outlineStrong),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: const Icon(
                        Icons.storage_rounded,
                        size: 20,
                        color: AppColors.signal,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OFFLINE STORAGE VAULT',
                            style: AppTypography.kicker(
                              size: 10,
                              color: AppColors.signal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${downloadedEpisodes.length} episodes / ${_formatStorageSize(totalBytes)} of 2.0 GB',
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                  child: LinearProgressIndicator(
                    value: usageRatio,
                    minHeight: 5,
                    backgroundColor: AppColors.outline,
                    color: usageRatio > 0.85
                        ? AppColors.onAir
                        : AppColors.signal,
                  ),
                ),
              ],
            ),
          ),
          // Downloads list
          Expanded(
            child: downloadedEpisodes.isEmpty
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.lg),
                                border:
                                    Border.all(color: AppColors.outlineStrong),
                              ),
                              child: const Icon(
                                Icons.download_done_rounded,
                                size: 28,
                                color: AppColors.signal,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'No Downloads',
                              style: theme.textTheme.displaySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Episodes you play will be automatically downloaded for offline listening.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
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
                          return false;
                        },
                        child: EpisodeListItem(
                          key: ValueKey(episode.id),
                          episode: episode,
                          playerService: widget.playerService,
                          storageService: widget.storageService,
                          onOpenPlayer: widget.onPlayEpisode,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceRaised,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.xs),
                                  border: Border.all(color: AppColors.outline),
                                ),
                                child: Text(
                                  downloaded.formattedFileSize,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete download',
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
