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
  final VoidCallback? onPlayEpisode;
  const ArchiveScreen({
    super.key,
    required this.archive,
    required this.playerService,
    required this.storageService,
    this.onPlayEpisode,
  });

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen>
    with SingleTickerProviderStateMixin {
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Open on today's shows: the archive is organised by the weekday they air.
    final days = widget.archive.keys.toList();
    final today = _weekdays[DateTime.now().weekday - 1];
    final todayIndex = days.indexOf(today);
    _tabController = TabController(
      length: widget.archive.length,
      vsync: this,
      initialIndex: todayIndex < 0 ? 0 : todayIndex,
    );
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
                    .map((day) => Tab(
                          text: day.substring(0, 3),
                          height: 44,
                        ))
                    .toList(),
              ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search all shows',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear search',
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
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
            child: _isSearching && filteredResults != null
                ? _buildSearchResults(filteredResults, theme)
                : TabBarView(
                    controller: _tabController,
                    children: days.map((day) {
                      final archiveDay = widget.archive[day]!;
                      final filteredShows = _filterShows(
                        archiveDay.shows,
                      );

                      if (filteredShows.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No shows on $day',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
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
                                    onPlayEpisode: widget.onPlayEpisode,
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
            Text(
              'No shows match "$_searchQuery"',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Search by show or DJ name.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final entry = results[index];
        final day = entry.key;
        final show = entry.value;
        return ShowListItem(
          show: show,
          dayLabel: day,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowDetailScreen(
                  show: show,
                  playerService: widget.playerService,
                  storageService: widget.storageService,
                  onPlayEpisode: widget.onPlayEpisode,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
