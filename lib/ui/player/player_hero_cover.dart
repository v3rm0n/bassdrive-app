import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';
import 'player_layout_scale.dart';
import 'speaker_cone.dart';

/// The player's hero: a speaker that thumps in time while audio plays, with
/// an optional status badge pinned to its top edge.
class PlayerHeroCover extends StatelessWidget {
  const PlayerHeroCover({
    super.key,
    required this.scale,
    required this.isPlaying,
    this.isLive = false,
    this.badge,
  });

  final PlayerLayoutScale scale;
  final bool isPlaying;
  final bool isLive;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: scale.heroSize,
      height: scale.heroSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          SpeakerCone(
            size: scale.heroSize,
            isPlaying: isPlaying,
            accent: isLive ? AppColors.onAir : AppColors.signal,
          ),
          if (badge != null)
            Positioned(
              bottom: -AppSpacing.xs,
              child: badge!,
            ),
        ],
      ),
    );
  }
}
