import 'package:flutter/material.dart';
import '../models/archive_day.dart';
import '../models/episode.dart';
import '../models/show.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../widgets/episode_list_item.dart';

class FavouritesScreen extends StatefulWidget {
  final Map<String, ArchiveDay> archive;
  final AudioPlayerService playerService;
  final StorageService storageService;
  final VoidCallback? onOpenPlayer;

  const FavouritesScreen({
    super.key,
    required this.archive,
    required this.playerService,
    required this.storageService,
    this.onOpenPlayer,
  });

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<Episode> _favouriteEpisodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    setState(() {
      _isLoading = true;
    });

    final favouriteIds = await widget.storageService.getFavourites();
    final episodes = <Episode>[];

    // Search through all archive days and shows to find favourite episodes
    for (final dayEntry in widget.archive.entries) {
      for (final show in dayEntry.value.shows) {
        for (final episode in show.episodes) {
          if (favouriteIds.contains(episode.id)) {
            episodes.add(episode);
          }
        }
      }
    }

    // Sort by date (newest first)
    episodes.sort((a, b) {
      if (a.date != null && b.date != null) {
        return b.date!.compareTo(a.date!);
      }
      return b.name.compareTo(a.name);
    });

    if (mounted) {
      setState(() {
        _favouriteEpisodes = episodes;
        _isLoading = false;
      });
    }
  }

  Future<void> _playEpisode(Episode episode) async {
    // Check if this episode is already the current episode
    final isCurrentEpisode =
        widget.playerService.currentEpisode?.id == episode.id;

    if (isCurrentEpisode) {
      // If already playing, open the full player
      widget.onOpenPlayer?.call();
      return;
    }

    final progress = await widget.storageService.getProgress(episode.id);

    await widget.playerService.playEpisode(
      episode,
      startPosition: progress?.position,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavourites,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.primary),
            )
          : _favouriteEpisodes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favourites yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on any episode to add it here',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavourites,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _favouriteEpisodes.length,
                    itemBuilder: (context, index) {
                      final episode = _favouriteEpisodes[index];
                      // Create a minimal Show object for the episode
                      final show = Show(
                        name: episode.show,
                        episodes: [episode],
                      );
                      return EpisodeListItem(
                        episode: episode,
                        show: show,
                        playerService: widget.playerService,
                        storageService: widget.storageService,
                        onTap: () => _playEpisode(episode),
                      );
                    },
                  ),
                ),
    );
  }
}
