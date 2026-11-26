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
    final countLabel = '$count ${count == 1 ? 'episode' : 'episodes'}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.outline)),
          ),
          child: Row(
            children: [
              ShowMonogram(name: show.name, size: 52),
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
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (dayLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.signalSurface,
                              borderRadius: BorderRadius.circular(AppRadii.xs),
                              border: Border.all(
                                color: AppColors.signal.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              dayLabel!.toUpperCase(),
                              style: AppTypography.kicker(
                                size: 9.5,
                                color: AppColors.signal,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(AppRadii.xs),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Text(
                            countLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (latest != null)
                          Text(
                            'Latest $latest',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.outline),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
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
          border: Border.all(color: AppColors.outlineStrong),
        ),
        child: Text(
          initialsFor(name),
          style: AppTypography.display(
            size: size * 0.46,
            weight: FontWeight.w800,
            color: AppColors.signal,
            height: 1,
          ),
        ),
      ),
    );
  }
}
