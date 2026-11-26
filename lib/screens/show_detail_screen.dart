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

  Future<void> _playLatest() async {
    if (widget.show.episodes.isEmpty) return;
    final latest = widget.show.episodes.first;
    await widget.playerService.playEpisode(latest);
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent == true) {
      Navigator.pop(context);
      widget.onPlayEpisode?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredEpisodes = _filterEpisodes(widget.show.episodes);

    return ColoredBox(
      color: AppColors.background,
      child: ReadableWidth(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'SHOW ARCHIVE',
              style: AppTypography.kicker(
                size: 11,
                color: AppColors.textSecondary,
              ),
            ),
            actions: [
              if (widget.show.episodes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: TextButton.icon(
                    onPressed: _playLatest,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.signalSurface,
                      foregroundColor: AppColors.signal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 6,
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(
                      'Play latest',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.signal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(bottom: BorderSide(color: AppColors.outline)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShowMonogram(name: widget.show.name, size: 74),
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
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceRaised,
                                      borderRadius:
                                          BorderRadius.circular(AppRadii.xs),
                                      border: Border.all(
                                          color: AppColors.outline),
                                    ),
                                    child: Text(
                                      '${widget.show.episodes.length} episodes in the archive',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
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
