import 'package:flutter/material.dart';
import '../models/archive_day.dart';
import '../models/episode.dart';
import '../models/show.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
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
  List<Episode> _allFavouriteEpisodes = [];
  List<Episode> _filteredEpisodes = [];
  bool _isLoading = true;
  SortOption _currentSort = SortOption.dateNewest;
  String _searchQuery = '';
  String? _selectedShowFilter;
  bool _showFilters = false;

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

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      episodes = episodes.where((episode) {
        return episode.name.toLowerCase().contains(query) ||
            episode.show.toLowerCase().contains(query);
      }).toList();
    }

    // Apply show filter
    if (_selectedShowFilter != null && _selectedShowFilter!.isNotEmpty) {
      episodes = episodes
          .where((episode) => episode.show == _selectedShowFilter)
          .toList();
    }

    // Apply sorting
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

  Future<void> _playEpisode(Episode episode) async {
    // Check if this episode is already the current episode
    final isCurrentEpisode =
        widget.playerService.currentEpisode?.id == episode.id;

    if (isCurrentEpisode) {
      // If already playing, do nothing - user can navigate to player tab
      return;
    }

    final progress = await widget.storageService.getProgress(episode.id);

    await widget.playerService.playEpisode(
      episode,
      startPosition: progress?.position,
    );

    // Navigate to player screen
    widget.onPlayEpisode?.call();
  }

  List<String> _getUniqueShows() {
    final shows = _allFavouriteEpisodes.map((e) => e.show).toSet().toList();
    shows.sort();
    return shows;
  }

  String _getSortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.dateNewest:
        return 'Date: Newest First';
      case SortOption.dateOldest:
        return 'Date: Oldest First';
      case SortOption.nameAZ:
        return 'Name: A to Z';
      case SortOption.nameZA:
        return 'Name: Z to A';
      case SortOption.showAZ:
        return 'Show: A to Z';
      case SortOption.showZA:
        return 'Show: Z to A';
    }
  }

  IconData _getSortIcon(SortOption sort) {
    switch (sort) {
      case SortOption.dateNewest:
        return Icons.arrow_downward;
      case SortOption.dateOldest:
        return Icons.arrow_upward;
      case SortOption.nameAZ:
      case SortOption.showAZ:
        return Icons.sort_by_alpha;
      case SortOption.nameZA:
      case SortOption.showZA:
        return Icons.sort_by_alpha_outlined;
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
          IconButton(
            icon:
                Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavourites,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilters ? null : 0,
            child: ClipRect(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showFilters ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Field
                      TextField(
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search favourites...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Sort Dropdown
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<SortOption>(
                              value: _currentSort,
                              onChanged: (value) {
                                if (value != null) {
                                  _onSortChanged(value);
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Sort by',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items: SortOption.values.map((sort) {
                                return DropdownMenuItem(
                                  value: sort,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getSortIcon(sort),
                                        size: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_getSortLabel(sort)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      // Show Filter (only if there are shows to filter)
                      if (uniqueShows.length > 1) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                value: _selectedShowFilter,
                                onChanged: _onShowFilterChanged,
                                decoration: InputDecoration(
                                  labelText: 'Filter by show',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All shows'),
                                  ),
                                  ...uniqueShows.map((show) {
                                    return DropdownMenuItem(
                                      value: show,
                                      child: Text(
                                        show,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Active filters indicator
                      if (_searchQuery.isNotEmpty ||
                          _selectedShowFilter != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (_searchQuery.isNotEmpty)
                              Chip(
                                label: Text('Search: $_searchQuery'),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => _onSearchChanged(''),
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                              ),
                            if (_selectedShowFilter != null)
                              Chip(
                                label: Text('Show: $_selectedShowFilter'),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => _onShowFilterChanged(null),
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Results count
          if (!_isLoading && _allFavouriteEpisodes.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${_filteredEpisodes.length} of ${_allFavouriteEpisodes.length} favourites',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          // Episode List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _allFavouriteEpisodes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
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
                    : _filteredEpisodes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No matches found',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () {
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
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _filteredEpisodes.length,
                              itemBuilder: (context, index) {
                                final episode = _filteredEpisodes[index];
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
          ),
        ],
      ),
    );
  }
}
