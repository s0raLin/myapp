import 'dart:io';

import 'package:metadata_god/metadata_god.dart';
import 'package:mime/mime.dart';
import 'package:myapp/model/Music/index.dart';
// import 'package:on_audio_query_forked/on_audio_query.dart';

import 'package:path/path.dart' as p; // 推荐使用 path 库处理后缀

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:permission_handler/permission_handler.dart';

class ScanProgress {
  final String currentPath; //正在处理的路径
  final MusicInfo? music; //如果解析了音乐,则返回对象
  // final int currentIndex; // 新增：当前第几首
  // final int totalCount; // 新增：总共多少首

  ScanProgress({
    required this.currentPath,
    this.music,
    // required this.currentIndex,
    // required this.totalCount,
  });
}

class MusicService {
  static Future<bool> ensureAndroidAudioPermission() async {
    if (!Platform.isAndroid) return true;

    final audioStatus = await Permission.audio.request();
    final storageStatus = await Permission.manageExternalStorage.request();

    return audioStatus.isGranted && storageStatus.isGranted;
  }

  // 增加初始化标志，避免重复初始化
  static bool _isMetadataInitialized = false;

  static Future<void> _ensureInitialized() async {
    if (!_isMetadataInitialized) {
      await MetadataGod.initialize();
      _isMetadataInitialized = true;
    }
  }

  static Future<MusicInfo> parse(String path) async {
    await _ensureInitialized();
    final metadata = await MetadataGod.readMetadata(file: path);

    final title = metadata.title ?? p.basename(path);
    final artist = metadata.artist ?? "未知歌手";
    final album = metadata.album ?? "未知专辑";
    final duration = metadata.duration ?? Duration.zero;
    final coverBytes = metadata.picture?.data;

    debugPrint(
      "封面: ${coverBytes != null ? '${coverBytes.length} bytes' : 'null'} → $path",
    );

    // 2. 手动寻找并读取外部 .lrc 文件
    String lyrics = "";
    final baseName = p.withoutExtension(path);
    final lrcPath = "$baseName.lrc";
    final file = File(lrcPath);

    if (await file.exists()) {
      lyrics = await file.readAsString();
    }

    return MusicInfo(
      id: path,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      coverBytes: coverBytes,
      lyrics: lyrics,
    );
  }

  static Future<List<FileSystemEntity>> scanDirectory(
    String selectedDirectory,
  ) async {
    // 遍历文件夹
    final dir = Directory(selectedDirectory);

    try {
      List<FileSystemEntity> entities = dir.listSync(recursive: true);

      final List<File> musicFiles = entities.whereType<File>().where((file) {
        final mimeType = lookupMimeType(file.path);
        return mimeType != null && mimeType.startsWith("audio/");
      }).toList();
      return musicFiles;
    } catch (e) {
      return [];
    }
  }

  static Stream<ScanProgress> scanDirectories(
    List<String> selectedDirectories,
  ) async* {
    if (kIsWeb) return;
    for (final directoryPath in selectedDirectories) {
      final dir = Directory(directoryPath);

      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        yield ScanProgress(currentPath: entity.path);
        if (entity is File) {
          final mimeType = lookupMimeType(entity.path);
          if (mimeType != null && mimeType.startsWith("audio/")) {
            try {
              final music = await parse(entity.path);

              //汇报解析成功的音乐数据
              yield ScanProgress(currentPath: entity.path, music: music);
            } catch (e, stack) {
              debugPrint("解析失败: ${entity.path}");
              debugPrint("错误: $e");
              debugPrint("$stack");
              continue;
            }
          }
        }
      }
    }
  }

  //保存歌词
  static Future<void> saveLyrics(String? lrcContent, String path) async {
    if (lrcContent==null || lrcContent.isEmpty) return;

    try {
      if (path.startsWith("/") && await File(path).exists()) {
        final lrcPath = path.contains(RegExp(r'\.([^./\\]+)$'))
            ? path.replaceFirstMapped(
                RegExp(r'\.([^./\\]+)$'),
                (match) => '.lrc',
              )
            : '$path.lrc';
        final lrcFile = File(lrcPath);
        await lrcFile.writeAsString(lrcContent);
        debugPrint("歌词已成功通过正则替换保存至: $lrcPath");
      }
    } catch (e) {
      debugPrint("歌词保存本地失败: $e");
    }
  }
}
