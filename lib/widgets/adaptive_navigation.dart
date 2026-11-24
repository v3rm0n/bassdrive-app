import 'package:flutter/material.dart';

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

  const AdaptiveNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isDesktop) {
      return _DesktopLayout(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        content: content,
      );
    }

    return _MobileLayout(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      content: content,
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationItem> destinations;
  final Widget content;

  const _DesktopLayout({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationTheme = theme.extension<NavigationChromeTheme>() ??
        NavigationChromeTheme.standard();

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 248,
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
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bassdrive',
                          style: AppTypography.display(size: 40),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Worldwide drum & bass',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
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
                ],
              ),
            ),
          ),
          Expanded(child: ReadableWidth(child: content)),
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
        vertical: 2,
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
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
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
                Text(
                  destination.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
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

  const _MobileLayout({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: content,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations
              .map(
                (d) => NavigationDestination(
                  icon: _mobileIcon(destination: d, isSelected: false),
                  selectedIcon: _mobileIcon(destination: d, isSelected: true),
                  label: d.label,
                ),
              )
              .toList(),
        ),
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
        color: isSelected ? AppColors.signal : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.signal, width: 1.5),
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: isSelected ? AppColors.onSignal : AppColors.signal,
      ),
    );
  }
}
