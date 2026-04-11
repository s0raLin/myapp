import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingService {
  static Future setColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("themeColor", color.toARGB32());
  }

  static Future setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("modeIndex", mode.index);
  }

  static Future<Color> loadColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt("themeColor");

    if (colorValue != null) {
      return Color(colorValue);
    }
    //如果没存过,返回默认颜色
    return Colors.teal;
  }

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt("modeIndex");

    if (modeIndex != null) {
      return ThemeMode.values[modeIndex];
    }
    return ThemeMode.light;
  }

  static Future setIsDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDark", isDark);
  }

  static Future loadIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool("isDark");
    if (isDark != null) {
      return isDark;
    }
    return false;
  }
}
