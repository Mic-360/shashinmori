import 'package:flutter/material.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
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

        if (constraints.maxWidth < 1200) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: onDestinationSelected,
                  destinations: [
                    for (final destination in destinations)
                      NavigationRailDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: Text(destination.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationDrawer(
                selectedIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                children: [
                  const DrawerHeader(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text('ShashinMori'),
                    ),
                  ),
                  for (final destination in destinations)
                    NavigationDrawerDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: Text(destination.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}
