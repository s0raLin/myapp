import 'package:flutter/material.dart';
import 'package:myapp/router/IndexRouter/index.dart';

class SideBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SideBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 重点：使用 NavigationDrawer 而不是 Rail
    return SizedBox(
      width: 200,
      child: NavigationDrawer(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        // 这里的背景色会自动适配 M3 规范
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.secondaryContainer, // 选中后的胶囊颜色
        children: [
          // 1. 修复标题：给标题增加 M3 标准内边距 (28, 16, 16, 10)
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 16, 10),
            child: Text(
              "Miku Music",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          // 也可以在这里插入像图中那样的 "Add timer" 按钮
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   child: FloatingActionButton.extended(...),
          // ),
          const SizedBox(height: 10),

          // 2. 映射导航项
          ...navItems.map((item) {
            return NavigationDrawerDestination(
              icon: item.i!,
              label: Text(
                item.label,
                style: TextStyle(
                  // 对应你提到的 M3 变更：选中项使用 secondary
                  color: navItems.indexOf(item) == currentIndex
                      ? colorScheme.secondary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: navItems.indexOf(item) == currentIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
