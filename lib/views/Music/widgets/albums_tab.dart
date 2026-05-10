import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:myapp/views/Music/widgets/album_card.dart';
import 'package:myapp/views/Music/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final library = musicProvider.library;

    // Group songs by album
    final albumsMap = <String, List<MusicInfo>>{};
    for (final song in library) {
      final albumName = song.album ?? "未知专辑";
      albumsMap.putIfAbsent(albumName, () => []).add(song);
    }

    final albums = albumsMap.entries.toList();
    return RefreshIndicator(
      onRefresh: () async {},
      child: albums.isEmpty
          ? EmptyState(
              icon: Icons.album_rounded,
              title: "还没有专辑",
              subtitle: "上传歌曲后会自动归类到专辑",
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final double horizontalPadding = width >= 1000 ? 20 : 16;
                final double spacing = width >= 1000 ? 16 : 12;
                final double maxExtent = width >= 1400
                    ? 220
                    : width >= 1000
                    ? 200
                    : width >= 700
                    ? 188
                    : 176;

                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    20,
                  ),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: maxExtent,
                    childAspectRatio: 0.92,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final entry = albums[index];
                    final albumName = entry.key;
                    final songs = entry.value;
                    final cover = songs
                        .firstWhere(
                          (s) => s.coverBytes != null && s.coverBytes!.isNotEmpty,
                          orElse: () => songs.first,
                        )
                        .coverBytes;
                    return AlbumCard(
                      albumName: albumName,
                      songCount: songs.length,
                      coverBytes: cover,
                      onTap: () {
                        context.push(
                          "/user/files/album-detail",
                          extra: {'albumName': albumName, 'songs': songs},
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
