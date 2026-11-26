import 'package:flutter/material.dart';

import '../ui/player/speaker_cone.dart';
import '../ui/theme/app_theme_tokens.dart';
import '../ui/theme/component_theme_extensions.dart';
import '../utils/platform_utils.dart';
import 'readable_width.dart';

class NavigationItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int index;
  final bool isProminent;

  const NavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.index,
    this.isProminent = false,
  });
}

class AdaptiveNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationItem> destinations;
  final Widget content;
  final Widget? bottomDock;
  final bool isAudioPlaying;
  final bool isLiveAudio;

  const AdaptiveNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.content,
    this.bottomDock,
    this.isAudioPlaying = false,
    this.isLiveAudio = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isDesktop) {
      return _DesktopLayout(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        content: content,
        bottomDock: bottomDock,
        isAudioPlaying: isAudioPlaying,
        isLiveAudio: isLiveAudio,
      );
    }

    return _MobileLayout(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      content: content,
      bottomDock: bottomDock,
      isAudioPlaying: isAudioPlaying,
      isLiveAudio: isLiveAudio,
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationItem> destinations;
  final Widget content;
  final Widget? bottomDock;
  final bool isAudioPlaying;
  final bool isLiveAudio;

  const _DesktopLayout({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.content,
    this.bottomDock,
    this.isAudioPlaying = false,
    this.isLiveAudio = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationTheme = theme.extension<NavigationChromeTheme>() ??
        NavigationChromeTheme.standard();

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Row(
        children: [
          Container(
            width: 264,
            decoration: BoxDecoration(
              color: navigationTheme.sidebarBackground,
              border: Border(
                right: BorderSide(color: navigationTheme.sidebarBorder),
              ),
            ),
            child: SafeArea(
              right: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SpeakerCone(
                              size: 34,
                              isPlaying: isAudioPlaying,
                              accent: isLiveAudio
                                  ? AppColors.onAir
                                  : AppColors.signal,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceRaised,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.xs),
                                border: Border.all(color: AppColors.outline),
                              ),
                              child: Text(
                                '174 BPM / 24/7',
                                style: AppTypography.kicker(
                                  size: 10,
                                  color: AppColors.signal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Bassdrive',
                          style: AppTypography.display(
                            size: 42,
                            weight: FontWeight.w900,
                            height: 0.9,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Worldwide drum & bass',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Divider(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      'CONSOLE',
                      style: AppTypography.kicker(size: 10),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: [
                        for (final destination in destinations)
                          _SidebarItem(
                            destination: destination,
                            isSelected: currentIndex == destination.index,
                            radius: navigationTheme.itemRadius,
                            activeBackground:
                                navigationTheme.activeItemBackground,
                            onTap: () =>
                                onDestinationSelected(destination.index),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isAudioPlaying
                                ? (isLiveAudio
                                    ? AppColors.onAir
                                    : AppColors.signal)
                                : AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            isAudioPlaying
                                ? (isLiveAudio
                                    ? 'SIGNAL: ON AIR'
                                    : 'SIGNAL: ARCHIVE')
                                : 'SIGNAL: STANDBY',
                            style: AppTypography.kicker(
                              size: 10.5,
                              color: isAudioPlaying
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: AppColors.background,
              child: Column(
                children: [
                  Expanded(child: ReadableWidth(child: content)),
                  if (bottomDock != null) ReadableWidth(child: bottomDock!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.isSelected,
    required this.radius,
    required this.activeBackground,
    required this.onTap,
  });

  final NavigationItem destination;
  final bool isSelected;
  final double radius;
  final Color activeBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isSelected || destination.isProminent
        ? AppColors.signal
        : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      child: Material(
        color: isSelected ? activeBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isSelected ? AppColors.signal : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected && destination.selectedIcon != null
                      ? destination.selectedIcon
                      : destination.icon,
                  color: iconColor,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    destination.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (destination.isProminent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.signalSurface
                          : AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(AppRadii.xs),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.signal
                            : AppColors.outlineStrong,
                      ),
                    ),
                    child: Text(
                      'DECK',
                      style: AppTypography.kicker(
                        size: 9,
                        color: isSelected
                            ? AppColors.signal
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationItem> destinations;
  final Widget content;
  final Widget? bottomDock;
  final bool isAudioPlaying;
  final bool isLiveAudio;

  const _MobileLayout({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.content,
    this.bottomDock,
    this.isAudioPlaying = false,
    this.isLiveAudio = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: content,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (bottomDock != null) bottomDock!,
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.backgroundDeep,
              border: Border(top: BorderSide(color: AppColors.outline)),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations
                  .map(
                    (d) => NavigationDestination(
                      icon: _mobileIcon(destination: d, isSelected: false),
                      selectedIcon:
                          _mobileIcon(destination: d, isSelected: true),
                      label: d.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileIcon({
    required NavigationItem destination,
    required bool isSelected,
  }) {
    final icon = isSelected && destination.selectedIcon != null
        ? destination.selectedIcon
        : destination.icon;
    if (!destination.isProminent) {
      return Icon(icon);
    }

    // The player tab is the one round, lit button in the bar.
    return AnimatedContainer(
      duration: AppMotion.regular,
      curve: AppMotion.entranceCurve,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.signal : AppColors.surfaceRaised,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.signal,
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: isSelected || isAudioPlaying
            ? [
                BoxShadow(
                  color: AppColors.signal.withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Icon(
        isAudioPlaying && !isSelected
            ? Icons.graphic_eq_rounded
            : Icons.play_arrow_rounded,
        color: isSelected ? AppColors.onSignal : AppColors.signal,
      ),
    );
  }
}
