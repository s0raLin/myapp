import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/components/BottomBar/index.dart';
import 'package:myapp/components/Header/index.dart';
import 'package:myapp/components/Sidebar/index.dart';
import 'package:myapp/contants/Routes/index.dart';

class MainPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var currentIndex = 0;

  void onTabChanged(int idx) {
    setState(() {
      context.go(customNavItems[idx].path);
      currentIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 800;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isLargeScreen = constraints.maxWidth >= maxWidth;

          return Row(
            children: [
              if (isLargeScreen)
                Sidebar(currentIndex: currentIndex, onTap: onTabChanged),
              Expanded(
                child: Scaffold(appBar: Header(), body: widget.navigationShell),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= maxWidth) {
            return const SizedBox.shrink();
          }
          return BottomBar(currentIndex: currentIndex, onTap: onTabChanged);
        },
      ),
    );
  }
}
