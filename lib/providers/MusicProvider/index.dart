import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/service/Music/index.dart';
import 'package:rxdart/rxdart.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class MusicProvider extends ChangeNotifier {
  //私有播放器实例
  final AudioPlayer player = AudioPlayer();

  //当前正在播放的音乐信息
  MusicInfo? _currentMusic;
  MusicInfo? get currentMusic => _currentMusic;

  //切换播放/暂停
  void togglePlay() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
    notifyListeners(); //触发监听
  }

  //播放下一首歌
  Future<void> playMusic(String filePath, {bool shouldPlay = true}) async {
    try {
      // 检查是否为同一首歌
      if (_currentMusic?.id == filePath) {
        if (shouldPlay && !player.playing) player.play();
        return;
      }

      //无论播不播放, 先解析元数据
      _currentMusic = await MusicService.parse(filePath);
      notifyListeners();

      // 音频加载,设置播放源
      // just_audio设置路径后自动异步获取duration
      await player.setFilePath(filePath);

      // 根据参数决定是否开始播放
      if (shouldPlay) {
        player.play();
      }
    } catch (e) {
      //播放出错
      debugPrint("！！！播放器报错了！！！: $e");
      return;
    }
  }

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        player.positionStream, // 当前播放位置
        player.bufferedPositionStream, // 缓冲位置
        player.durationStream, // 总时长
        (position, bufferedPosition, duration) => // 输出
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );
}
