import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/views/Home/index.dart';
import 'package:myapp/views/Settings/index.dart';
import 'package:myapp/views/Splash/index.dart';
import 'package:myapp/views/index.dart';
import 'package:provider/provider.dart';

extension RouterCtx on BuildContext {
  void toSettings() => this.go('/settings');
  void toHome() => this.go('/home');
}

class IndexRouter extends StatefulWidget {
  const IndexRouter({super.key});

  @override
  State<IndexRouter> createState() => _IndexRouterState();
}

class _IndexRouterState extends State<IndexRouter> {
  final router = GoRouter(
    initialLocation: "/splash",
    routes: [
      GoRoute(path: "/splash", builder: (context, state) => SplashPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Provider.value(
            value: navigationShell,
            child: MainPage(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: "home",
                path: "/home",
                builder: (context, state) => HomePage(),
              ),
              GoRoute(
                name: "settings",
                path: "/settings",
                builder: (context, state) => SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      builder: (context, child) {
        return Provider.value(value: router, child: child!);
      },
    );
  }
}
