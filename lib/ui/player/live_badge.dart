import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';

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
    final label = isPlaying ? 'LIVE' : (isReadyState ? 'READY' : 'PAUSED');

    return AnimatedContainer(
      duration: AppMotion.quick,
      curve: AppMotion.entranceCurve,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isPlaying ? AppColors.error : AppColors.cyanStrong,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}
