import 'package:flutter/material.dart';

import '../ui/theme/app_theme_tokens.dart';
import '../ui/theme/component_theme_extensions.dart';
import '../utils/platform_utils.dart';

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
        NavigationChromeTheme.console();

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: navigationTheme.sidebarBackground,
              border: Border(
                right: BorderSide(
                  color: navigationTheme.sidebarBorder.withValues(alpha: 0.62),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.radio,
                        size: 30,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Bassdrive',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'BROADCAST CONSOLE',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      final destination = destinations[index];
                      final isSelected = currentIndex == destination.index;
                      final itemBackground = isSelected
                          ? navigationTheme.activeItemBackground
                          : destination.isProminent
                              ? navigationTheme.prominentItemBackground
                              : navigationTheme.itemBackground;
                      final itemBorder = isSelected
                          ? navigationTheme.activeItemBorder
                          : destination.isProminent
                              ? navigationTheme.prominentItemBorder
                              : navigationTheme.sidebarBorder
                                  .withValues(alpha: 0.45);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        child: AnimatedContainer(
                          duration: AppMotion.regular,
                          curve: AppMotion.entranceCurve,
                          decoration: BoxDecoration(
                            color: itemBackground,
                            borderRadius: BorderRadius.circular(
                              navigationTheme.itemRadius,
                            ),
                            border: Border.all(color: itemBorder),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: navigationTheme.activeGlow
                                          .withValues(alpha: 0.22),
                                      blurRadius: 16,
                                      spreadRadius: 0.4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  onDestinationSelected(destination.index),
                              borderRadius: BorderRadius.circular(
                                navigationTheme.itemRadius,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: destination.isProminent
                                      ? AppSpacing.lg
                                      : AppSpacing.md,
                                  vertical: destination.isProminent
                                      ? AppSpacing.md
                                      : AppSpacing.sm,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected &&
                                              destination.selectedIcon != null
                                          ? destination.selectedIcon
                                          : destination.icon,
                                      color: isSelected
                                          ? AppColors.cyan
                                          : destination.isProminent
                                              ? AppColors.cyan
                                              : AppColors.textSecondary,
                                      size: destination.isProminent ? 27 : 23,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Text(
                                      destination.label,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: isSelected ||
                                                destination.isProminent
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        letterSpacing: destination.isProminent
                                            ? 0.25
                                            : 0.15,
                                        color: isSelected
                                            ? AppColors.textPrimary
                                            : destination.isProminent
                                                ? AppColors.cyan
                                                : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    '24/7 Drum & Bass Radio',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
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
    final theme = Theme.of(context);
    final navigationTheme = theme.extension<NavigationChromeTheme>() ??
        NavigationChromeTheme.console();

    return Scaffold(
      body: content,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        indicatorColor: navigationTheme.activeItemBackground,
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: _mobileIcon(
                  destination: d,
                  isSelected: false,
                ),
                selectedIcon: _mobileIcon(
                  destination: d,
                  isSelected: true,
                ),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _mobileIcon({
    required NavigationItem destination,
    required bool isSelected,
  }) {
    if (!destination.isProminent) {
      return Icon(isSelected && destination.selectedIcon != null
          ? destination.selectedIcon
          : destination.icon);
    }

    return AnimatedContainer(
      duration: AppMotion.regular,
      curve: AppMotion.entranceCurve,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.cyanStrong : AppColors.surfaceOverlay,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: isSelected ? AppColors.cyan : AppColors.outlineStrong,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.cyanGlow.withValues(alpha: 0.24),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Icon(
        isSelected && destination.selectedIcon != null
            ? destination.selectedIcon
            : destination.icon,
        color: isSelected ? Colors.black : AppColors.cyan,
      ),
    );
  }
}
