import 'package:flutter/material.dart';
import '../models/show.dart';

class ShowListItem extends StatelessWidget {
  final Show show;
  final VoidCallback onTap;
  final String? dayLabel;

  const ShowListItem({
    super.key,
    required this.show,
    required this.onTap,
    this.dayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.3),
                theme.colorScheme.secondary.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.podcasts, color: theme.colorScheme.primary),
        ),
        title: Text(
          show.name,
          style: theme.textTheme.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              '${show.episodes.length} episodes',
              style: theme.textTheme.bodySmall,
            ),
            if (dayLabel != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  dayLabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
