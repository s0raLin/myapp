import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/components/BottomBar/index.dart';
import 'package:myapp/components/Drawer/index.dart';
import 'package:myapp/components/Header/index.dart';
import 'package:myapp/components/Sidebar/index.dart';

class MainPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onTabChanged(int idx) {
    widget.navigationShell.goBranch(idx);
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 800;
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = widget.navigationShell.currentIndex;
    final contentBackground = colorScheme.surfaceContainerLow;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: contentBackground,
      drawer: const MainDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isLargeScreen = constraints.maxWidth >= maxWidth;

          return Row(
            children: [
              if (isLargeScreen)
                SizedBox(
                  width: 168,
                  child: Sidebar(
                    currentIndex: currentIndex,
                    onTap: onTabChanged,
                  ),
                ),
              Expanded(
                child: Scaffold(
                  backgroundColor: contentBackground,
                  appBar: Header(scaffoldKey: _scaffoldKey),
                  body: widget.navigationShell,
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= maxWidth) {
            return SizedBox.shrink();
          }
          return BottomBar(currentIndex: currentIndex, onTap: onTabChanged);
        },
      ),
    );
  }
}
