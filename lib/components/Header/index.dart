import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/router/IndexRouter/index.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    final router = context.read<GoRouter>();
    final routeName = router.state.name ?? "未知";

    return AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
      title: Title(
        color: Colors.black,
        child: Text(
          // routes[widget.navigationShell.currentIndex],
          routeName,
          style: const TextStyle(fontSize: 30),
        ),
      ),
      actions: [
        IconButton(onPressed: () => print("search"), icon: Icon(Icons.search)),
        IconButton(
          onPressed: () => {context.toSettings()},
          icon: Icon(Icons.settings),
        ),
      ],
    );
  }
}
