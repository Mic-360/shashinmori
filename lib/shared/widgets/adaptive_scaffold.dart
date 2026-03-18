import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdaptiveDestination {
  const AdaptiveDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
    this.floatingActionButton,
    super.key,
  });

  final List<AdaptiveDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // ── Mobile: bottom navigation bar ──
        if (constraints.maxWidth < 600) {
          return Scaffold(
            body: child,
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
              ],
            ),
          );
        }

        // ── Tablet: navigation rail ──
        if (constraints.maxWidth < 1200) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: onDestinationSelected,
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: SvgPicture.asset(
                      'assets/favicon.svg',
                      width: 32,
                      height: 32,
                    ),
                  ),
                  destinations: [
                    for (final destination in destinations)
                      NavigationRailDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: Text(destination.label),
                      ),
                  ],
                ),
                VerticalDivider(
                  width: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.2),
                ),
                Expanded(child: child),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }

        // ── Desktop: navigation drawer ──
        return Scaffold(
          body: Row(
            children: [
              NavigationDrawer(
                selectedIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/favicon.svg',
                          width: 36,
                          height: 36,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'ShashinMori',
                          style: tt.titleLarge?.copyWith(
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final destination in destinations)
                    NavigationDrawerDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: Text(destination.label),
                    ),
                ],
              ),
              VerticalDivider(
                width: 1,
                color: cs.outlineVariant.withValues(alpha: 0.2),
              ),
              Expanded(child: child),
            ],
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}
