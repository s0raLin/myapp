import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/contants/Routes/index.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  const BottomBar({super.key, required this.currentIndex, required this.onTap});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    final shell = context.read<StatefulNavigationShell>();

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 7, 0, 17),
        borderRadius: BorderRadius.circular(20),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        items: customNavItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}
