import 'package:flutter/material.dart';
import '../models/archive_day.dart';
import '../models/show.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../widgets/show_list_item.dart';
import 'show_detail_screen.dart';

class ArchiveScreen extends StatefulWidget {
  final Map<String, ArchiveDay> archive;
  final AudioPlayerService playerService;
  final StorageService storageService;

  const ArchiveScreen({
    super.key,
    required this.archive,
    required this.playerService,
    required this.storageService,
  });

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.archive.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<String, Show>> _getAllFilteredShows() {
    if (_searchQuery.isEmpty) return [];

    final List<MapEntry<String, Show>> results = [];
    for (final entry in widget.archive.entries) {
      final day = entry.key;
      final shows = entry.value.shows;
      for (final show in shows) {
        if (show.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          results.add(MapEntry(day, show));
        }
      }
    }
    return results;
  }

  List<Show> _filterShows(List<Show> shows) {
    if (_searchQuery.isEmpty) return shows;
    return shows
        .where(
          (show) =>
              show.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = widget.archive.keys.toList();
    final filteredResults = _isSearching ? _getAllFilteredShows() : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive'),
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: days
                    .map((day) => Tab(text: day.substring(0, 3)))
                    .toList(),
              ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search shows...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _isSearching = false;
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
                  _isSearching = value.isNotEmpty;
                });
              },
            ),
          ),
          Expanded(
            child: _isSearching
                ? _buildSearchResults(filteredResults!, theme)
                : TabBarView(
                    controller: _tabController,
                    children: days.map((day) {
                      final archiveDay = widget.archive[day]!;
                      final filteredShows = _filterShows(archiveDay.shows);

                      if (filteredShows.isEmpty) {
                        return Center(
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
                                'No shows found',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filteredShows.length,
                        itemBuilder: (context, index) {
                          final show = filteredShows[index];
                          return ShowListItem(
                            show: show,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowDetailScreen(
                                    show: show,
                                    playerService: widget.playerService,
                                    storageService: widget.storageService,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    List<MapEntry<String, Show>> results,
    ThemeData theme,
  ) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No shows found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final entry = results[index];
        final day = entry.key;
        final show = entry.value;
        return ShowListItem(
          show: show,
          dayLabel: day.substring(0, 3),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowDetailScreen(
                  show: show,
                  playerService: widget.playerService,
                  storageService: widget.storageService,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
