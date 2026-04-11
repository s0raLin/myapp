import 'package:flutter/material.dart';
import 'package:myapp/contants/Routes/index.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationBar(
      elevation: 0,
      height: 65,
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.secondaryContainer,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: customNavItems.map((item) {
        return NavigationDestination(
          tooltip: item.tooltip,
          icon: Icon(item.icon),
          selectedIcon: Icon(item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }
}
