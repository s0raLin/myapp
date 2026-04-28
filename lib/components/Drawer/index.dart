import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/contants/Assets/index.dart';
import 'package:myapp/providers/UserProvider/index.dart';
import 'package:myapp/router/Extensions/router.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class Destination {
  final String path;
  final String label;
  final Widget icon;
  final Widget selectedIcon;

  Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}

class _MainDrawerState extends State<MainDrawer> {
  int _screenIndex = 0;
  final _destinations = <Destination>[
    Destination(
      path: "/files",
      label: "选择目录",
      icon: const Icon(Icons.folder),
      selectedIcon: const Icon(Icons.folder),
    ),
    Destination(
      path: "/settings",
      label: "设置",
      icon: const Icon(Icons.settings),
      selectedIcon: const Icon(Icons.settings),
    ),
    Destination(
      path: "/about",
      label: "关于",
      icon: const Icon(Icons.info_outline),
      selectedIcon: const Icon(Icons.info_outline),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final username = userProvider.user?.username ?? "游客";

    final avatarUrl = userProvider.user?.avatarURL;
    final email = userProvider.user?.email ?? "请登录账号";
    final isLoggedIn = userProvider.user != null;

    // 构建菜单项列表
    final allItems = <Widget>[];

    // 普通导航项
    for (int i = 0; i < _destinations.length; i++) {
      final destination = _destinations[i];
      allItems.add(
        NavigationDrawerDestination(
          icon: destination.icon,
          label: Text(destination.label),
          selectedIcon: destination.selectedIcon,
        ),
      );
    }

    // 登录/登出项
    if (!isLoggedIn) {
      allItems.add(
        const NavigationDrawerDestination(
          icon: Icon(Icons.login),
          label: Text("登录/注册"),
          selectedIcon: Icon(Icons.login),
        ),
      );
    } else {
      allItems.add(
        const NavigationDrawerDestination(
          icon: Icon(Icons.logout),
          label: Text("退出登录"),
          selectedIcon: Icon(Icons.logout),
        ),
      );
    }

    return NavigationDrawer(
      selectedIndex: _screenIndex,
      onDestinationSelected: (int idx) async {
        setState(() {
          _screenIndex = idx;
        });



        // 处理登录/注册页面跳转
        if (!isLoggedIn && idx == allItems.length - 1) {
          context.push("/login");
          return;
        }

        // 普通导航项跳转
        if (idx < _destinations.length) {
          context.push(_destinations[idx].path);
        }
      },
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(username),
          accountEmail: Text(email),
          currentAccountPicture: CircleAvatar(
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl)
                : AssetImage(MyAssets.avatar),
          ),
        ),
        ...allItems,
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
      ],
    );
  }
}
