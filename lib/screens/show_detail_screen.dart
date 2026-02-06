import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../models/listening_progress.dart';
import '../models/show.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../widgets/episode_list_item.dart';

class ShowDetailScreen extends StatefulWidget {
  final Show show;
  final AudioPlayerService playerService;
  final StorageService storageService;
  final VoidCallback? onPlayEpisode;
  const ShowDetailScreen({
    super.key,
    required this.show,
    required this.playerService,
    required this.storageService,
    this.onPlayEpisode,
  });

  @override
  State<ShowDetailScreen> createState() => _ShowDetailScreenState();
}

class _ShowDetailScreenState extends State<ShowDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Episode> _filterEpisodes(List<Episode> episodes) {
    if (_searchQuery.isEmpty) return episodes;
    return episodes
        .where(
          (episode) =>
              episode.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              episode.show.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  Future<void> _playEpisode(Episode episode) async {
    // Check if this episode is already the current episode
    final isCurrentEpisode =
        widget.playerService.currentEpisode?.id == episode.id;

    if (isCurrentEpisode) {
      // If already playing, pop back - user can navigate to player tab
      if (context.mounted) {
        Navigator.pop(context);
      }
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

    // Navigate to player screen
    if (mounted) {
      widget.onPlayEpisode?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredEpisodes = _filterEpisodes(widget.show.episodes);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.show.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                            theme.colorScheme.secondary.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.podcasts,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.show.name,
                            style: theme.textTheme.displaySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.show.episodes.length} episodes',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search episodes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredEpisodes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No episodes found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredEpisodes.length,
                    itemBuilder: (context, index) {
                      final episode = filteredEpisodes[index];
                      return EpisodeListItem(
                        episode: episode,
                        show: widget.show,
                        playerService: widget.playerService,
                        storageService: widget.storageService,
                        onTap: () => _playEpisode(episode),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
