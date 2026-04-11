import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension RouterCtx on BuildContext {
  void toSettings() => go('/settings');
  void toHome() => go('/home');
  void toMusic() => go('/music');
  void toFiles() => go("/files");
  void toLogin() => go("/login");
  void toRegister() => go("/register");
}
