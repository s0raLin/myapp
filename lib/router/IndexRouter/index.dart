import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/providers/ThemeProvider/index.dart';
import 'package:myapp/views/Files/index.dart';
import 'package:myapp/views/Home/index.dart';
import 'package:myapp/views/Login/index.dart';
import 'package:myapp/views/Login/register.dart';
import 'package:myapp/views/Music/index.dart';
import 'package:myapp/views/Music/music_detail.dart';
import 'package:myapp/views/Settings/index.dart';
import 'package:myapp/views/Splash/index.dart';
import 'package:myapp/views/index.dart';
import 'package:provider/provider.dart';

class AppNavItem {
  final String name;
  final String path;
  final Widget page;
  final IconData icon;
  final String label;
  final List<RouteBase> routes;

  AppNavItem({
    required this.name,
    required this.path,
    required this.page,
    required this.icon,
    required this.label,
    this.routes = const [],
  });
}

final List<AppNavItem> navItems = [
  AppNavItem(
    name: "home",
    path: "/home",
    page: HomePage(),
    icon: Icons.home,
    label: "首页",
  ),
  AppNavItem(
    name: "music",
    path: "/music",
    page: MusicPage(),
    icon: Icons.music_note,
    label: "音乐",
  ),
  AppNavItem(
    name: "files",
    path: "/files",
    page: FilesPage(),
    icon: Icons.folder,
    label: "文件",
  ),
];

final _shellBranches = navItems.map((item) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        name: item.name,
        path: item.path,
        builder: (context, state) => item.page,
        routes: item.routes,
      ),
    ],
  );
}).toList();

final _routes = [
  GoRoute(path: "/splash", builder: (context, state) => SplashPage()),
  GoRoute(path: "/login", builder: (context, state) => LoginPage()),
  GoRoute(path: "/register", builder: (context, state) => RegisterPage()),
  GoRoute(
    path: "/music/:songId",
    builder: (context, state) =>
        MusicDetailPage(id: state.pathParameters["songId"]),
  ),
  GoRoute(
    name: "settings",
    path: "/settings",
    builder: (context, state) => SettingsPage(),
  ),
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        MainPage(navigationShell: navigationShell),
    branches: _shellBranches,
  ),
];

final _router = GoRouter(initialLocation: "/splash", routes: _routes);

class IndexRouter extends StatelessWidget {
  const IndexRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          theme: themeProvider.themeData,
          themeMode: themeProvider.themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
