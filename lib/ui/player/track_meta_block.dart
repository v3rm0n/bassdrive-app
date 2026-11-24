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
          style: AppTypography.display(size: scale.titleSize),
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: scale.metaSpacing),
        Text(
          subtitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.signal,
          ),
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (detail != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            detail!,
            style: theme.textTheme.bodyMedium,
            textAlign: align,
          ),
        ],
      ],
    );
  }
}
