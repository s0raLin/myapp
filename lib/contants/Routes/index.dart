import 'package:flutter/material.dart';

class NavItem {
  final String path;
  final String label;
  final IconData icon;
  // final int branchIndex;
  const NavItem({
    required this.path,
    required this.label,
    required this.icon,
    // required this.branchIndex,
  });
}

final customNavItems = [
  NavItem(path: "/home", label: "home", icon: Icons.home),
  NavItem(path: "/settings", label: "settings", icon: Icons.settings),
];
