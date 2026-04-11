import 'package:flutter/material.dart';

class NavItem {
  final String path;
  final String label;
  final IconData icon;
  final String tooltip;

  const NavItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.tooltip,
  });
}

const customNavItems = <NavItem>[
  NavItem(
    path: "/home",
    label: "首页",
    icon: Icons.home_rounded,
    tooltip: "前往首页",
  ),
  NavItem(
    path: "/music",
    label: "音乐",
    icon: Icons.library_music_rounded,
    tooltip: "前往音乐",
  ),
  NavItem(
    path: "/files",
    label: "文件",
    icon: Icons.folder_copy_rounded,
    tooltip: "前往文件",
  ),
];

int navIndexFromPath(String path) {
  final index = customNavItems.indexWhere((item) => path.startsWith(item.path));
  return index >= 0 ? index : 0;
}
