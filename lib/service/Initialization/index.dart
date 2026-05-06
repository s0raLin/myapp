import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:myapp/service/Settings/index.dart';

class InitializationService {
  // 1. 启动前的硬性初始化
  static Future<void> preRunInit() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (!kIsWeb && Platform.isLinux || Platform.isWindows) {
      JustAudioMediaKit.ensureInitialized(
        linux: true,
        windows: false,
        android: true,
      );
    }
  }

  /// 2. 异步业务数据加载
  static Future<Map<String, dynamic>> loadInitialSettings() async {
    // 聚合所有 SettingService 的加载调用
    final results = await Future.wait([
      SettingService.loadColor(),
      SettingService.loadThemeMode(),
      SettingService.loadListDensity(),
      SettingService.loadAudioQuality(),
      SettingService.loadShowLyricCover(),
      SettingService.loadAutoPlayOnStart(),
      SettingService.loadShowNotificationDetail(),
      SettingService.loadDoubleTapToPlay(),
      SettingService.loadPlaylistSortBy(),
      SettingService.loadMaxHistoryCount(),
    ]);

    return {
      'seedColor': results[0],
      'themeMode': results[1],
      'listDensity': results[2],
      'audioQuality': results[3],
      'showLyricCover': results[4],
      'autoPlayOnStart': results[5],
      'showNotificationDetail': results[6],
      'doubleTapToPlay': results[7],
      'playlistSortBy': results[8],
      'maxHistoryCount': results[9],
    };
  }
}
