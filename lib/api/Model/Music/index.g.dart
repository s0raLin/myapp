// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Music _$MusicFromJson(Map<String, dynamic> json) => Music(
  title: json['title'] as String,
  artist: json['artist'] as String,
  album: json['album'] as String,
  duration: const DurationConverter().fromJson(
    (json['duration'] as num).toInt(),
  ),
  ossKey: json['ossKey'] as String,
  coverUrl: json['coverUrl'] as String?,
  lyricUrl: json['lyricUrl'] as String?,
);

Map<String, dynamic> _$MusicToJson(Music instance) => <String, dynamic>{
  'title': instance.title,
  'artist': instance.artist,
  'album': instance.album,
  'duration': const DurationConverter().toJson(instance.duration),
  'ossKey': instance.ossKey,
  'coverUrl': instance.coverUrl,
  'lyricUrl': instance.lyricUrl,
};
