import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';
import '../theme/component_theme_extensions.dart';
import 'player_layout_scale.dart';

class PlayerHeroCover extends StatelessWidget {
  const PlayerHeroCover({
    super.key,
    required this.scale,
    required this.icon,
    required this.isPlaying,
    this.badge,
  });

  final PlayerLayoutScale scale;
  final IconData icon;
  final bool isPlaying;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme =
        theme.extension<BroadcastCardTheme>() ?? BroadcastCardTheme.console();

    return AnimatedContainer(
      duration: AppMotion.regular,
      curve: AppMotion.entranceCurve,
      width: scale.heroSize,
      height: scale.heroSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardTheme.radius + 4),
        border: Border.all(color: cardTheme.border),
        boxShadow: [
          BoxShadow(
            color: cardTheme.glow.withValues(alpha: isPlaying ? 0.44 : 0.2),
            blurRadius: isPlaying ? 46 : 26,
            spreadRadius: isPlaying ? 6 : 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardTheme.radius + 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceOverlay,
                AppColors.surfaceRaised,
                AppColors.surface,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.12, -0.22),
                      radius: 0.92,
                      colors: [
                        AppColors.cyanGlow
                            .withValues(alpha: isPlaying ? 0.46 : 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: scale.heroSize * 0.38,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (badge != null)
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: badge!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
