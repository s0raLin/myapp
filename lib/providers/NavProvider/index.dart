import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/router/IndexRouter/index.dart';

class NavProvider extends ChangeNotifier {
  StatefulNavigationShell? _shell;

  //获取当前shell
  StatefulNavigationShell? get shell => _shell;

  // 更新shell
  void updateShell(StatefulNavigationShell newShell) {
    _shell = newShell;
    notifyListeners(); //通知UI更新状态
  }

  //封装跳转逻辑
  void jumpTo(int index) {
    _shell?.goBranch(index);
  }

  void jumpByPath(String path) {
    //查找path开头的匹配项 例如 "/user/recent" 会匹配到 "/user" 所在的 index
    final index = navItems.indexWhere((item) => path.startsWith(item.path));

    if (index != -1) {
      _shell?.goBranch(index);
    }
  }
}
