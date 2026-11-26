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
    final lamp = isPlaying
        ? AppColors.onAir
        : (isReadyState ? AppColors.signal : AppColors.textMuted);

    return AnimatedContainer(
      duration: AppMotion.quick,
      curve: AppMotion.entranceCurve,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: isPlaying ? AppColors.onAir : AppColors.outlineStrong,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlaying
                ? AppColors.onAir.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
                        color: AppColors.onAir.withValues(alpha: 0.8),
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
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
