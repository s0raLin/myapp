import 'dart:convert';
import 'dart:typed_data';

class Playlist {
  final String id;
  final String name;
  final String? description;
  final Uint8List? coverBytes;
  final List<String> songIds;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverBytes,
    required this.songIds,
    this.isSystem = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    Uint8List? coverBytes,
    List<String>? songIds,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverBytes: coverBytes ?? this.coverBytes,
      songIds: songIds ?? this.songIds,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
    );
  }

  // Convert to SharedPreferences-compatible format (store as JSON string)
  String toSerializedString() {
    return jsonEncode(toJson());
  }

  factory Playlist.fromSerializedString(String str) {
    return Playlist.fromJson(jsonDecode(str));
  }
}
