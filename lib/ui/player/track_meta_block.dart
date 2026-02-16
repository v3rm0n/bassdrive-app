import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';
import '../theme/component_theme_extensions.dart';
import 'player_layout_scale.dart';

class TrackMetaBlock extends StatelessWidget {
  const TrackMetaBlock({
    super.key,
    required this.title,
    required this.subtitle,
    required this.scale,
    this.align = TextAlign.center,
  });

  final String title;
  final String subtitle;
  final PlayerLayoutScale scale;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTheme =
        theme.extension<SectionHeaderTheme>() ?? SectionHeaderTheme.console();

    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.displaySmall?.copyWith(
            color: headerTheme.titleColor,
            height: 1.1,
          ),
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: scale.metaSpacing),
        Text(
          subtitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: headerTheme.subtitleColor,
            height: 1.2,
          ),
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: 120,
          height: 2,
          decoration: BoxDecoration(
            color: headerTheme.ruleColor,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        ),
      ],
    );
  }
}
