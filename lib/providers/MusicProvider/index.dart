import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/model/Playlist/index.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

enum PlayMode { sequence, shuffle, repeat }

//区分点击还是自动切歌
enum PlayTrigger { user, auto }

class MusicProvider extends ChangeNotifier {
  //私有播放器实例
  final AudioPlayer player = AudioPlayer();
  StreamSubscription? _stateSubscription; //持有的监听器句柄
  StreamSubscription? _stateSubscription2;

  PackageInfo? _appInfo;
  PackageInfo? get appInfo => _appInfo;
  String get appVersion => _appInfo?.version ?? "加载中...";
  String get buildNumber => _appInfo?.buildNumber ?? "";

  Future<void> _loadAppInfo() async {
    _appInfo = await PackageInfo.fromPlatform();
    notifyListeners(); //初始化完成,通知UI刷新
  }

  // 音量控制
  double _volume = 1.0;
  double get volume => _volume;

  // 歌曲库
  final List<MusicInfo> _library = [];
  List<MusicInfo> get library => _library;
  // 全局播放队列
  List<MusicInfo> _queue = [];
  int _currentIndex = -1;

  List<MusicInfo> get queue => _queue;

  final _historyKey = "play_history";
  List<MusicInfo> _history = [];
  List<MusicInfo> get history => _history;

  final List<MusicInfo> _favList = [];
  List<MusicInfo> get favList => _favList;

  // Playlist management
  final String _playlistsKey = "user_playlists";
  final List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;

  // System playlist IDs
  static const String _favoritesPlaylistId = "system_favorites";
  static const String _recentPlaylistId = "system_recent";

  String get favoritesPlaylistId => _favoritesPlaylistId;

  List<Playlist> get userPlaylists =>
      _playlists.where((p) => !p.isSystem).toList();

  List<Playlist> get systemPlaylists =>
      _playlists.where((p) => p.isSystem).toList();

  Playlist? get favoritesPlaylist =>
      _playlists.firstWhere((p) => p.id == _favoritesPlaylistId);

  List<Map<String, dynamic>> _currentLyrics = [];

  List<Map<String, dynamic>> get currentLyrics => _currentLyrics;

  List<Map<String, dynamic>> _parseLrc(String? lrcContent) {
    if (lrcContent == null || lrcContent.isEmpty) return [];

    final List<Map<String, dynamic>> lyrics = [];
    // 正则匹配 [00:00.00] 格式
    final regExp = RegExp(r'\[(\d+):(\d+\.\d+)\](.*)');

    for (var line in lrcContent.split('\n')) {
      final match = regExp.firstMatch(line);
      if (match != null) {
        final min = int.parse(match.group(1)!);
        final sec = double.parse(match.group(2)!);
        final text = match.group(3)!.trim();

        lyrics.add({
          'time': Duration(milliseconds: (min * 60000 + sec * 1000).toInt()),
          'text': text,
        });
      }
    }
    // 按时间排序，防止歌词文件乱序
    lyrics.sort(
      (a, b) => (a['time'] as Duration).compareTo(b['time'] as Duration),
    );
    return lyrics;
  }

  Future<void> toggleFav(MusicInfo music) async {
    final isExist = _favList.any((m) => m.id == music.id);
    if (isExist) {
      _favList.removeWhere((m) => music.id == m.id);
    } else {
      _favList.add(music);
    }
    _saveFavList();
    notifyListeners();
  }

  Future<void> _saveFavList() async {
    final pfs = await SharedPreferences.getInstance();
    await pfs.setStringList("fav_list", _favList.map((m) => m.id).toList());
    // Sync with favorites system playlist
    _syncFavoritesPlaylist();
  }

  Future<void> _saveHistory() async {
    final pfs = await SharedPreferences.getInstance();
    await pfs.setStringList(_historyKey, _history.map((m) => m.id).toList());
  }

  Future<void> _addToHistory(MusicInfo music) async {
    _history.removeWhere((m) => m.id == music.id); //去重
    _history.insert(0, music); // 插到最前
    if (_history.length > 200) _history.removeLast(); //最多保留200条
    _saveHistory();
    notifyListeners();
  }

  //清空历史
  Future<void> clearHistory() async {
    _history.clear();
    final pfs = await SharedPreferences.getInstance();
    await pfs.remove(_historyKey);
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    final pfs = await SharedPreferences.getInstance();
    final ids = pfs.getStringList(_historyKey) ?? [];

    _history = ids
        .map((id) {
          try {
            return _library.firstWhere((m) => m.id == id);
          } catch (_) {
            return null; //歌曲已被删除
          }
        })
        .whereType<MusicInfo>()
        .toList();
    notifyListeners();
  }

  // Playlist persistence
  Future<void> _loadPlaylists() async {
    final pfs = await SharedPreferences.getInstance();
    final playlistStrings = pfs.getStringList(_playlistsKey) ?? [];

    _playlists.clear();
    for (final str in playlistStrings) {
      try {
        final playlist = Playlist.fromSerializedString(str);
        _playlists.add(playlist);
      } catch (e) {
        // Skip invalid playlists
      }
    }

    // Ensure system playlists exist
    _ensureSystemPlaylists();
    notifyListeners();
  }

  Future<void> _savePlaylists() async {
    final pfs = await SharedPreferences.getInstance();
    await pfs.setStringList(
      _playlistsKey,
      _playlists.map((p) => p.toSerializedString()).toList(),
    );
  }

  void _ensureSystemPlaylists() {
    // Favorites system playlist
    if (!_playlists.any((p) => p.id == _favoritesPlaylistId)) {
      _playlists.add(
        Playlist(
          id: _favoritesPlaylistId,
          name: "我喜欢",
          description: "收藏的歌曲",
          isSystem: true,
          songIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    // Recent system playlist
    if (!_playlists.any((p) => p.id == _recentPlaylistId)) {
      _playlists.add(
        Playlist(
          id: _recentPlaylistId,
          name: "最近播放",
          description: "最近播放的歌曲",
          isSystem: true,
          songIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  void _syncFavoritesPlaylist() {
    final favPlaylist = _playlists.firstWhere(
      (p) => p.id == _favoritesPlaylistId,
    );
    final index = _playlists.indexOf(favPlaylist);
    _playlists[index] = favPlaylist.copyWith(
      songIds: _favList.map((m) => m.id).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // Playlist CRUD operations
  String createPlaylist(String name, {String? description}) {
    final id = "user_${DateTime.now().microsecondsSinceEpoch}";
    final playlist = Playlist(
      id: id,
      name: name,
      description: description,
      isSystem: false,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _playlists.add(playlist);
    _savePlaylists();
    notifyListeners();
    return id;
  }

  void deletePlaylist(String id) {
    if (id == _favoritesPlaylistId) return; // Can't delete system playlists
    _playlists.removeWhere((p) => p.id == id);
    _savePlaylists();
    notifyListeners();
  }

  void renamePlaylist(String id, String newName) {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      _savePlaylists();
      notifyListeners();
    }
  }

  void addToPlaylist(String playlistId, MusicInfo music) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      if (!playlist.songIds.contains(music.id)) {
        _playlists[index] = playlist.copyWith(
          songIds: [...playlist.songIds, music.id],
          updatedAt: DateTime.now(),
        );
        _savePlaylists();
        notifyListeners();
      }
    }
  }

  void removeFromPlaylist(String playlistId, String musicId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      final newSongIds = playlist.songIds.where((id) => id != musicId).toList();
      _playlists[index] = playlist.copyWith(
        songIds: newSongIds,
        updatedAt: DateTime.now(),
      );
      _savePlaylists();
      notifyListeners();
    }
  }

  // Resolve playlist songs from library
  List<MusicInfo> getPlaylistSongs(String playlistId) {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    if (playlist.isSystem) {
      if (playlistId == _favoritesPlaylistId) {
        return _favList;
      }
      if (playlistId == _recentPlaylistId) {
        return _history;
      }
    }
    return playlist.songIds
        .map((id) => _library.firstWhereOrNull((m) => m.id == id))
        .whereType<MusicInfo>()
        .toList();
  }

  Playlist? getPlaylistById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isInQueue(String id) => _queue.any((m) => m.id == id);
  //添加到队尾
  void addToQueue(MusicInfo music) {
    _queue.add(music);
    notifyListeners();
  }

  //从队尾移除
  void removeFromQueue(int index) {
    if (index == _currentIndex) return; //不能删除当前播放的
    _queue.removeAt(index);
    if (index < _currentIndex) _currentIndex--; //维护当前index
    notifyListeners();
  }

  //清空队列
  void clearQueue() {
    _queue.clear();
    _currentIndex = -1;
    player.stop();
    notifyListeners();
  }

  void playFromLibrary(MusicInfo music) {
    //检查是否在队列里
    final existingIndex = _queue.indexWhere((m) => m.id == music.id);

    if (existingIndex != -1) {
      //已经在队列,直接跳过
      playByIndex(existingIndex);
      return;
    } else {
      //不在队列,加入队尾再播放
      _queue.add(music);
      playByIndex(_queue.length - 1);
    }
  }

  Future<void> playMusic(String path, {shouldPlay = true}) async {
    try {
      if (currentMusic?.id != path) {
        //停止当前播放,清理状态
        await player.stop();
      }

      //加载新路径
      await player.setFilePath(path);

      //播放
      if (shouldPlay) {
        player.play();
      }
    } catch (e) {
      return;
    }
  }

  //当前正在播放的音乐信息

  //当前正在播放的音乐对象
  MusicInfo? get currentMusic {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) {
      return null;
    }
    return _queue[_currentIndex];
  }

  // 清空队列,替换为新列表
  Future<void> replaceQueue(List<MusicInfo> songs, {int startIndex = 0}) async {
    _queue = List.from(songs);
    _currentIndex = -1;
    await player.stop();
    notifyListeners();
    if (_queue.isNotEmpty) {
      await playByIndex(startIndex);
    }
  }

  //切换播放/暂停
  void togglePlay() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
    notifyListeners(); //触发监听
  }

  PlayMode _playMode = PlayMode.sequence;
  PlayMode get playMode => _playMode;

  // 切换三种模式
  void togglePlayMode() {
    _playMode = switch (_playMode) {
      PlayMode.sequence => PlayMode.shuffle,
      PlayMode.shuffle => PlayMode.repeat,
      PlayMode.repeat => PlayMode.sequence,
    };
    notifyListeners();
  }

  Future playByIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    if (index == _currentIndex && player.playing) return;

    _currentIndex = index;

    // 处理歌词逻辑
    final music = _queue[index];
    // IMPORTANT: Always replace with a new list instance.
    // This ensures Provider selectors (e.g. context.select) detect the change.
    _currentLyrics = _parseLrc(music.lyrics);

    notifyListeners(); //确保UI收到歌词更新通知

    _addToHistory(music); //添加到历史
    // await player.stop(); //* 停止当前播放,清理状态
    // 直接设置路径，不需要调用 stop()
    // just_audio 会自动停止之前的播放并加载新的
    await player.setFilePath(music.id);
    player.play();
  }

  Future<void> playNext() => _playNext();
  Future<void> playPrev() => _playPrev();
  Future<void> _playNext({PlayTrigger trigger = PlayTrigger.auto}) async {
    if (_queue.isEmpty) return;

    switch (_playMode) {
      case PlayMode.repeat:
        if (trigger == PlayTrigger.user) {
          // 用户点击下一首
          await playByIndex((_currentIndex + 1) % _queue.length);
        } else {
          //单曲循环
          await player.seek(Duration.zero);
          player.play();
        }
        break;
      case PlayMode.shuffle:
        //随机,排除当前index
        final candidates = List.generate(_queue.length, (i) => i)
          ..remove(_currentIndex);
        if (candidates.isEmpty) return;
        await playByIndex(candidates[Random().nextInt(candidates.length)]);
        break;
      case PlayMode.sequence:
        // 顺序 到最后一首就停
        if (_currentIndex < _queue.length - 1) {
          await playByIndex(_currentIndex + 1);
        } else {
          if (trigger == PlayTrigger.user) {
            // 跳到第一首
            await playByIndex(0);
          } else {
            await player.seek(Duration.zero); //自动停下
          }
        }
        break;
    }
  }

  Future<void> _playPrev() async {
    if (_queue.isEmpty) return;

    final prevIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    await playByIndex(prevIndex);
  }

  MusicProvider() {
    _loadHistory(); //初始化时加载历史
    _loadPlaylists(); //初始化时加载歌单
    _loadAppInfo(); //初始化应用信息
    _stateSubscription = player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) _playNext();
    });
    _stateSubscription2 = player.playingStream.listen((_) {
      notifyListeners();
    }); //监听播放器状态变化并通知 UI
    // 初始化音量
    _loadVolume();
  }

  Future<void> _loadVolume() async {
    final pfs = await SharedPreferences.getInstance();
    _volume = pfs.getDouble('volume') ?? 1.0;
    player.setVolume(_volume);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await player.setVolume(_volume);
    final pfs = await SharedPreferences.getInstance();
    await pfs.setDouble('volume', _volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _stateSubscription?.cancel(); //取消监听
    _stateSubscription2?.cancel();
    player.dispose(); //销毁播放器释放的资源
    super.dispose();
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
