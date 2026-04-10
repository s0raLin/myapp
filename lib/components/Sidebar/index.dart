import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/contants/Routes/index.dart';

class Sidebar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  const Sidebar({super.key, required this.currentIndex, required this.onTap});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  // var currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    // final currentName = router.state.name;

    return Container(
      width: 100,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 7, 0, 17),
        borderRadius: BorderRadius.circular(20),
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: widget.currentIndex,
        onDestinationSelected: widget.onTap,
        destinations: customNavItems.map((item) {
          return NavigationRailDestination(
            icon: Icon(item.icon),
            label: Text(item.label),
          );
        }).toList(),
      ),
    );
  }
}
