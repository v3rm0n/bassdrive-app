import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';

/// Studio on-air lamp. Red and lit while the live stream plays.
class LiveBadge extends StatelessWidget {
  const LiveBadge({
    super.key,
    required this.isPlaying,
    this.isReadyState = false,
  });

  final bool isPlaying;
  final bool isReadyState;

  @override
  Widget build(BuildContext context) {
    final label = isPlaying ? 'On air' : (isReadyState ? 'Ready' : 'Paused');
    final lamp = isPlaying ? AppColors.onAir : AppColors.textMuted;

    return AnimatedContainer(
      duration: AppMotion.quick,
      curve: AppMotion.entranceCurve,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: isPlaying ? AppColors.onAir : AppColors.outlineStrong,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: lamp,
              shape: BoxShape.circle,
              boxShadow: isPlaying
                  ? [
                      BoxShadow(
                        color: AppColors.onAir.withValues(alpha: 0.7),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isPlaying
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
