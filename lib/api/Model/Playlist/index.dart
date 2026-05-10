import 'dart:convert';
import 'dart:typed_data';

class Playlist {
  final String id;
  final String name;
  final String? description;
  final Uint8List? coverBytes; // 注意：JSON只提供URL，Bytes需要后续下载

  final List<String> songIds;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  final int trackCount;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverBytes,
    required this.songIds,
    this.isSystem = false,
    required this.createdAt,
    required this.updatedAt,
    required this.trackCount,
  });

  // --- 新增：从网易云 JSON 转换的工厂方法 ---
  factory Playlist.fromNeteaseJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'].toString(),
      name: json['name'] ?? '未知歌单',
      description: json['description'],
      songIds: [], // 原始 JSON 不含歌曲列表，需另行请求
      isSystem: json['specialType'] == 5, // 5 通常代表“我喜欢的音乐”
      // 网易云返回的是毫秒时间戳
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createTime'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updateTime'] ?? 0),
      coverBytes: null,
      trackCount: json['trackCount'] ?? 0, // 图片需通过 coverImgUrl 另行下载
    );
  }

  // --- 标准 JSON 转换 ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songIds': songIds,
      'isSystem': isSystem,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      songIds: List<String>.from(json['songIds'] ?? []),
      isSystem: json['isSystem'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      trackCount: json['trackCount'] ?? 0,
    );
  }

  // --- 格式化输出 (toString) ---
  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, songs: ${songIds.length}, isSystem: $isSystem)';
  }

  // --- 序列化存取 (SharedPreferences 常用) ---
  String toSerializedString() => jsonEncode(toJson());

  factory Playlist.fromSerializedString(String str) =>
      Playlist.fromJson(jsonDecode(str));
}
