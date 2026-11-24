import 'package:flutter/material.dart';

import '../models/show.dart';
import '../ui/theme/app_theme_tokens.dart';

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
    final count = show.episodes.length;
    final latest = show.episodes.isEmpty ? null : show.episodes.first.dateLabel;
    final details = [
      if (dayLabel != null) dayLabel!,
      '$count ${count == 1 ? 'episode' : 'episodes'}',
      if (latest != null) 'latest $latest',
    ].join(', ');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.outline)),
        ),
        child: Row(
          children: [
            ShowMonogram(name: show.name, size: 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Two-letter mark for a show, cut from its name like a record-label stamp.
class ShowMonogram extends StatelessWidget {
  const ShowMonogram({super.key, required this.name, required this.size});

  final String name;
  final double size;

  static String initialsFor(String name) {
    const skip = {'the', 'a', 'an', 'with', 'and', '&', '-', 'show'};
    final words = name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !skip.contains(w.toLowerCase()))
        .toList();
    if (words.isEmpty) return name.isEmpty ? '?' : name[0].toUpperCase();
    final letters = words.take(2).map((w) => w.characters.first.toUpperCase());
    return letters.join();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Text(
          initialsFor(name),
          style: AppTypography.display(
            size: size * 0.5,
            color: AppColors.signal,
            height: 1,
          ),
        ),
      ),
    );
  }
}
