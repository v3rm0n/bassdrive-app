import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../models/show.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../widgets/episode_list_item.dart';
import '../widgets/show_list_item.dart';
import '../ui/theme/app_theme_tokens.dart';
import '../widgets/readable_width.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredEpisodes = _filterEpisodes(widget.show.episodes);

    return ColoredBox(
      color: AppColors.background,
      child: ReadableWidth(
        child: Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShowMonogram(name: widget.show.name, size: 72),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.show.name,
                                style: theme.textTheme.displaySmall,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.show.episodes.length} episodes in the archive',
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
                        hintText: 'Search episodes',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                tooltip: 'Clear search',
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
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
              const Divider(),
              Expanded(
                child: filteredEpisodes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No episodes match "$_searchQuery"',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: filteredEpisodes.length,
                        itemBuilder: (context, index) {
                          final episode = filteredEpisodes[index];
                          return EpisodeListItem(
                            key: ValueKey(episode.id),
                            episode: episode,
                            show: widget.show,
                            showShowName: false,
                            playerService: widget.playerService,
                            storageService: widget.storageService,
                            onOpenPlayer: () {
                              if (ModalRoute.of(context)?.isCurrent != true) {
                                return;
                              }
                              Navigator.pop(context);
                              widget.onPlayEpisode?.call();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
