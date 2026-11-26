import 'package:flutter/material.dart';
import '../models/archive_day.dart';
import '../models/episode.dart';
import '../models/show.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../ui/theme/app_theme_tokens.dart';
import '../widgets/episode_list_item.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  nameAZ,
  nameZA,
  showAZ,
  showZA,
}

class FavouritesScreen extends StatefulWidget {
  final Map<String, ArchiveDay> archive;
  final AudioPlayerService playerService;
  final StorageService storageService;
  final VoidCallback? onPlayEpisode;
  const FavouritesScreen({
    super.key,
    required this.archive,
    required this.playerService,
    required this.storageService,
    this.onPlayEpisode,
  });

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Episode> _allFavouriteEpisodes = [];
  List<Episode> _filteredEpisodes = [];
  bool _isLoading = true;
  SortOption _currentSort = SortOption.dateNewest;
  String _searchQuery = '';
  String? _selectedShowFilter;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavourites() async {
    setState(() {
      _isLoading = true;
    });

    final favouriteIds = await widget.storageService.getFavourites();
    final episodes = <Episode>[];

    for (final dayEntry in widget.archive.entries) {
      for (final show in dayEntry.value.shows) {
        for (final episode in show.episodes) {
          if (favouriteIds.contains(episode.id)) {
            episodes.add(episode);
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _allFavouriteEpisodes = episodes;
        _applyFiltersAndSort();
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    var episodes = List<Episode>.from(_allFavouriteEpisodes);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      episodes = episodes.where((episode) {
        return episode.name.toLowerCase().contains(query) ||
            episode.show.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedShowFilter != null && _selectedShowFilter!.isNotEmpty) {
      episodes = episodes
          .where((episode) => episode.show == _selectedShowFilter)
          .toList();
    }

    switch (_currentSort) {
      case SortOption.dateNewest:
        episodes.sort((a, b) {
          if (a.date != null && b.date != null) {
            return b.date!.compareTo(a.date!);
          }
          return b.name.compareTo(a.name);
        });
      case SortOption.dateOldest:
        episodes.sort((a, b) {
          if (a.date != null && b.date != null) {
            return a.date!.compareTo(b.date!);
          }
          return a.name.compareTo(b.name);
        });
      case SortOption.nameAZ:
        episodes.sort((a, b) => a.displayName.compareTo(b.displayName));
      case SortOption.nameZA:
        episodes.sort((a, b) => b.displayName.compareTo(a.displayName));
      case SortOption.showAZ:
        episodes.sort((a, b) {
          final showCompare = a.show.compareTo(b.show);
          if (showCompare != 0) return showCompare;
          return a.displayName.compareTo(b.displayName);
        });
      case SortOption.showZA:
        episodes.sort((a, b) {
          final showCompare = b.show.compareTo(a.show);
          if (showCompare != 0) return showCompare;
          return b.displayName.compareTo(a.displayName);
        });
    }

    setState(() {
      _filteredEpisodes = episodes;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFiltersAndSort();
  }

  void _onSortChanged(SortOption sort) {
    setState(() {
      _currentSort = sort;
    });
    _applyFiltersAndSort();
  }

  void _onShowFilterChanged(String? show) {
    setState(() {
      _selectedShowFilter = show;
    });
    _applyFiltersAndSort();
  }

  List<String> _getUniqueShows() {
    final shows = _allFavouriteEpisodes.map((e) => e.show).toSet().toList();
    shows.sort();
    return shows;
  }

  String _getSortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.dateNewest:
        return 'Newest';
      case SortOption.dateOldest:
        return 'Oldest';
      case SortOption.nameAZ:
        return 'Title A-Z';
      case SortOption.nameZA:
        return 'Title Z-A';
      case SortOption.showAZ:
        return 'Show A-Z';
      case SortOption.showZA:
        return 'Show Z-A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uniqueShows = _getUniqueShows();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        actions: [
          if (!_isLoading && _allFavouriteEpisodes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Text(
                    '${_filteredEpisodes.length} SAVED',
                    style: AppTypography.kicker(
                      size: 10,
                      color: AppColors.signal,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh favourites',
            onPressed: _loadFavourites,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allFavouriteEpisodes.isEmpty
              ? _buildEmptyState(theme)
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        border: Border(
                          bottom: BorderSide(color: AppColors.outline),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search favourites...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  'SORT',
                                  style: AppTypography.kicker(size: 10),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                for (final sort in [
                                  SortOption.dateNewest,
                                  SortOption.dateOldest,
                                  SortOption.nameAZ,
                                  SortOption.showAZ,
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: _FilterPill(
                                      label: _getSortLabel(sort),
                                      isSelected: _currentSort == sort,
                                      onTap: () => _onSortChanged(sort),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (uniqueShows.length > 1) ...[
                            const SizedBox(height: AppSpacing.xs),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Text(
                                    'SHOW',
                                    style: AppTypography.kicker(size: 10),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: _FilterPill(
                                      label: 'All shows',
                                      isSelected: _selectedShowFilter == null,
                                      onTap: () => _onShowFilterChanged(null),
                                    ),
                                  ),
                                  for (final show in uniqueShows)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: _FilterPill(
                                        label: show,
                                        isSelected:
                                            _selectedShowFilter == show,
                                        onTap: () => _onShowFilterChanged(show),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: _filteredEpisodes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off_rounded,
                                    size: 40,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'No matches found',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  TextButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                      _onShowFilterChanged(null);
                                    },
                                    icon: const Icon(Icons.clear_all),
                                    label: const Text('Clear all filters'),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadFavourites,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 16),
                                itemCount: _filteredEpisodes.length,
                                itemBuilder: (context, index) {
                                  final episode = _filteredEpisodes[index];
                                  final show = Show(
                                    name: episode.show,
                                    episodes: [episode],
                                  );
                                  return EpisodeListItem(
                                    key: ValueKey(episode.id),
                                    episode: episode,
                                    show: show,
                                    playerService: widget.playerService,
                                    storageService: widget.storageService,
                                    onOpenPlayer: widget.onPlayEpisode,
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
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
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.outlineStrong),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 28,
                  color: AppColors.signal,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No favourites yet',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap the heart icon on any archived episode to save it to your crate.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.signal : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
              color: isSelected ? AppColors.signal : AppColors.outline,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? AppColors.onSignal
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
