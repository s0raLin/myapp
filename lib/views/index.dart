import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/components/BottomBar/index.dart';
import 'package:myapp/components/Drawer/index.dart';
import 'package:myapp/components/Header/index.dart';
import 'package:myapp/components/NowPlayingBar/index.dart';
import 'package:myapp/components/SideBar/index.dart';

class MainPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late bool showNavigationDrawer;
  late int currentIndex;

  void onTabChanged(int idx) {
    currentIndex = idx;
    widget.navigationShell.goBranch(idx);
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showNavigationDrawer = MediaQuery.of(context).size.width >= 450;
    currentIndex = widget.navigationShell.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return showNavigationDrawer
        ? _buildDrawerScaffold(context)
        : _buildBottomBarScaffold(context);
  }

  Widget _buildDrawerScaffold(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // final bool isLargeScreen = constraints.maxWidth >= maxWidth;

          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SideBar(currentIndex: currentIndex, onTap: onTabChanged),
                    const VerticalDivider(thickness: 1, width: 1),

                    //主内容区
                    Expanded(child: widget.navigationShell),
                  ],
                ),
              ),
              NowPlayingBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomBarScaffold(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MainDrawer(),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                //主内容区
                Expanded(
                  child: Column(
                    children: [
                      Header(scaffoldKey: _scaffoldKey),
                      Expanded(child: widget.navigationShell),
                    ],
                  ),
                ),
              ],
            ),
          ),
          NowPlayingBar(),
        ],
      ),

      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          return BottomBar(currentIndex: currentIndex, onTap: onTabChanged);
        },
      ),
    );
  }
}
