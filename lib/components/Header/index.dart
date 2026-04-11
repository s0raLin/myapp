import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/contants/Routes/index.dart';
import 'package:myapp/router/Extensions/router.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Color? backgroundColor;

  const Header({super.key, this.scaffoldKey, this.backgroundColor});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.surfaceContainerLow,
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () {
          scaffoldKey?.currentState?.openDrawer();
        },
        icon: Icon(Icons.menu, color: colorScheme.onSurface),
      ),
      title: Container(
        height: 40,
        constraints: const BoxConstraints(maxWidth: 240), // 限制最大宽度以确保居中感
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: "搜索...",
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: colorScheme.primary,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            // 去掉 TextField 默认的边框和下划线
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: colorScheme.primary, width: 1),
            ),
          ),
          onSubmitted: (value) {
            // 处理搜索逻辑
          },
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.push("/settings");
          },
          icon: Icon(Icons.settings, color: colorScheme.onSurface),
        ),
      ],
    );
  }
}
