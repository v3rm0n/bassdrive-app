import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';
import '../theme/component_theme_extensions.dart';
import 'player_layout_scale.dart';
import 'player_view_state.dart';

class TransportCluster extends StatelessWidget {
  const TransportCluster({
    super.key,
    required this.viewState,
    required this.scale,
    required this.onPrimaryPressed,
    this.onSkipBack,
    this.onSkipForward,
  });

  final PlayerViewState viewState;
  final PlayerLayoutScale scale;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSkipBack;
  final VoidCallback? onSkipForward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controlTheme = theme.extension<TransportControlTheme>() ??
        TransportControlTheme.console();
    final showSkipButtons = viewState.showTimeline;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showSkipButtons)
          _SecondaryControl(
            icon: Icons.replay_10,
            size: controlTheme.secondarySize,
            iconColor: controlTheme.secondaryIcon,
            background: controlTheme.secondaryBackground,
            onPressed: onSkipBack,
          ),
        if (showSkipButtons) SizedBox(width: scale.transportGap),
        _PrimaryControl(
          isLoading: viewState.isLoading,
          isPlaying: viewState.isPlaying,
          size: controlTheme.primarySize,
          iconColor: controlTheme.primaryIcon,
          background: controlTheme.primaryBackground,
          ringColor: controlTheme.ringColor,
          onPressed: viewState.isLoading ? null : onPrimaryPressed,
        ),
        if (showSkipButtons) SizedBox(width: scale.transportGap),
        if (showSkipButtons)
          _SecondaryControl(
            icon: Icons.forward_30,
            size: controlTheme.secondarySize,
            iconColor: controlTheme.secondaryIcon,
            background: controlTheme.secondaryBackground,
            onPressed: onSkipForward,
          ),
      ],
    );
  }
}

class _PrimaryControl extends StatelessWidget {
  const _PrimaryControl({
    required this.isLoading,
    required this.isPlaying,
    required this.size,
    required this.iconColor,
    required this.background,
    required this.ringColor,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isPlaying;
  final double size;
  final Color iconColor;
  final Color background;
  final Color ringColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.quick,
      curve: AppMotion.entranceCurve,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        boxShadow: [
          BoxShadow(
            color: ringColor.withValues(alpha: isPlaying ? 0.52 : 0.24),
            blurRadius: isPlaying ? 24 : 12,
            spreadRadius: isPlaying ? 4 : 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: AnimatedSwitcher(
              duration: AppMotion.quick,
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey<String>('loading'),
                      width: size * 0.36,
                      height: size * 0.36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      key: ValueKey<bool>(isPlaying),
                      size: size * 0.52,
                      color: iconColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryControl extends StatelessWidget {
  const _SecondaryControl({
    required this.icon,
    required this.size,
    required this.iconColor,
    required this.background,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final Color iconColor;
  final Color background;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(icon, color: iconColor, size: size * 0.46),
        ),
      ),
    );
  }
}
