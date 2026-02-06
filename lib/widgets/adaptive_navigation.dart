import 'package:flutter/material.dart';
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

    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(
                      Icons.radio,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Bassdrive',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Navigation Items
              Expanded(
                child: ListView.builder(
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final destination = destinations[index];
                    final isSelected = currentIndex == destination.index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Material(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => onDestinationSelected(destination.index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: destination.isProminent ? 20 : 16,
                              vertical: destination.isProminent ? 18 : 14,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected && destination.selectedIcon != null
                                      ? destination.selectedIcon
                                      : destination.icon,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : destination.isProminent
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                  size: destination.isProminent ? 28 : 24,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  destination.label,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight:
                                        isSelected || destination.isProminent
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    fontSize: destination.isProminent ? 18 : 16,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : destination.isProminent
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '24/7 Drum & Bass Radio',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content Area
        Expanded(child: content),
      ],
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon:
                    d.selectedIcon != null ? Icon(d.selectedIcon) : null,
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
