import 'package:flutter/material.dart';

import '../ui/theme/app_theme_tokens.dart';
import '../widgets/readable_width.dart';
import '../services/storage_service.dart';

class ListeningStatsScreen extends StatefulWidget {
  final StorageService storageService;

  const ListeningStatsScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<ListeningStatsScreen> createState() => _ListeningStatsScreenState();
}

class _ListeningStatsScreenState extends State<ListeningStatsScreen> {
  Duration _liveStreamTime = Duration.zero;
  Duration _archivesTime = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final liveStreamTime =
        await widget.storageService.getLiveStreamListeningTime();
    final archivesTime = await widget.storageService.getArchivesListeningTime();

    if (mounted) {
      setState(() {
        _liveStreamTime = liveStreamTime;
        _archivesTime = archivesTime;
        _isLoading = false;
      });
    }
  }

  Future<void> _resetStats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset listening stats?'),
        content: const Text(
          'Are you sure you want to reset all listening statistics? This action cannot be undone.',
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
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.storageService.resetListeningTime();
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statistics reset successfully')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDurationDetailed(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0 || parts.isEmpty) parts.add('${seconds}s');

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalTime = _liveStreamTime + _archivesTime;

    return ColoredBox(
      color: AppColors.background,
      child: ReadableWidth(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Listening stats'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadStats,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _resetStats,
                tooltip: 'Reset statistics',
              ),
            ],
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      Text('Time listened', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(totalTime),
                        style: AppTypography.display(size: 72, height: 1),
                      ),
                      Text(
                        _formatDurationDetailed(totalTime),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      _SplitBar(
                        live: _liveStreamTime,
                        archive: _archivesTime,
                      ),
                      const SizedBox(height: 8),
                      _buildTimeCard(
                        context,
                        icon: Icons.radio,
                        title: 'Live stream',
                        duration: _liveStreamTime,
                        color: AppColors.onAir,
                        total: totalTime,
                      ),
                      _buildTimeCard(
                        context,
                        icon: Icons.library_music,
                        title: 'Archived shows',
                        duration: _archivesTime,
                        color: AppColors.signal,
                        total: totalTime,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Time counts while audio plays and is stored only on this device.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Duration duration,
    required Color color,
    required Duration total,
  }) {
    final theme = Theme.of(context);
    final percentage = total.inSeconds > 0
        ? (duration.inSeconds / total.inSeconds * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title, style: theme.textTheme.titleMedium),
          ),
          Text(
            _formatDuration(duration),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFeatures: AppTypography.tabular,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: Text(
              '$percentage%',
              textAlign: TextAlign.end,
              style: theme.textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// One bar split between live and archive listening.
class _SplitBar extends StatelessWidget {
  const _SplitBar({required this.live, required this.archive});

  final Duration live;
  final Duration archive;

  @override
  Widget build(BuildContext context) {
    final total = live.inSeconds + archive.inSeconds;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: SizedBox(
        height: 12,
        child: total == 0
            ? const ColoredBox(color: AppColors.outline)
            : Row(
                children: [
                  if (live.inSeconds > 0)
                    Expanded(
                      flex: live.inSeconds,
                      child: const ColoredBox(color: AppColors.onAir),
                    ),
                  if (live.inSeconds > 0 && archive.inSeconds > 0)
                    const SizedBox(width: 2),
                  if (archive.inSeconds > 0)
                    Expanded(
                      flex: archive.inSeconds,
                      child: const ColoredBox(color: AppColors.signal),
                    ),
                ],
              ),
      ),
    );
  }
}
