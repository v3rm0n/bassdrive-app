import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';
import 'player_layout_scale.dart';

class TrackMetaBlock extends StatelessWidget {
  const TrackMetaBlock({
    super.key,
    required this.title,
    required this.subtitle,
    required this.scale,
    this.detail,
    this.align = TextAlign.center,
  });

  final String title;
  final String subtitle;
  final String? detail;
  final PlayerLayoutScale scale;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAxis = align == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          title,
          style: AppTypography.display(
            size: scale.titleSize,
            weight: FontWeight.w800,
            height: 0.94,
          ),
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: scale.metaSpacing),
        Text(
          subtitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.signal,
            fontWeight: FontWeight.w600,
          ),
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (detail != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.outline),
            ),
            child: Text(
              detail!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: align,
            ),
          ),
        ],
      ],
    );
  }
}
