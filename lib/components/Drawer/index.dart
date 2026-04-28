import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/contants/Assets/index.dart';
import 'package:myapp/providers/UserProvider/index.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class Destination {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}

class _MainDrawerState extends State<MainDrawer> {
  int _screenIndex = 0;
  late final List<Destination> _destinations;

  late String _username;

  late String _avatarUrl;
  late String _email;

  @override
  void initState() {
    super.initState();

    final userProvider = context.read<UserProvider>();
    final isLoggedIn = userProvider.user != null;

    _username = userProvider.user?.username ?? "游客";
    _avatarUrl = userProvider.user?.avatarURL ?? "";
    _email = userProvider.user?.email ?? "请登录账号";

    _destinations = <Destination>[
      !isLoggedIn
          ? Destination(
              path: "/login",
              label: "登录/注册",
              icon: Icons.login,
              selectedIcon: Icons.login,
            )
          : Destination(
              label: "退出登录",
              icon: Icons.logout,
              selectedIcon: Icons.logout,
              path: "/logout",
            ),

      Destination(
        path: "/files",
        label: "选择目录",
        icon: Icons.folder,
        selectedIcon: Icons.folder,
      ),
      Destination(
        path: "/settings",
        label: "设置",
        icon: Icons.settings,
        selectedIcon: Icons.settings,
      ),

      Destination(
        path: "/about",
        label: "关于",
        icon: Icons.info_outline,
        selectedIcon: Icons.info_outline,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: _screenIndex,
      onDestinationSelected: (int idx) async {
        setState(() {
          _screenIndex = idx;
        });

        // 普通导航项跳转
        if (idx < _destinations.length) {
          context.push(_destinations[idx].path);
        }
      },
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(_username),
          accountEmail: Text(_email),
          currentAccountPicture: CircleAvatar(
            backgroundImage: _avatarUrl.isNotEmpty
                ? NetworkImage(_avatarUrl)
                : AssetImage(MyAssets.avatar),
          ),
        ),
        ..._destinations.map((destination) {
          return NavigationDrawerDestination(
            icon: Icon(destination.icon),
            label: Text(destination.label),
          );
        }),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
      ],
    );
  }
}
