import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/api/Client/index.dart';
import 'package:myapp/model/Playlist/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:provider/provider.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("音乐库"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "单曲"),
              Tab(text: "专辑"),
              Tab(text: "播放队列"),
              Tab(text: "歌单"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLeft(),
            _buildCenter(),
            _buildQueue(),
            _buildPlaylists(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeft() {
    return RefreshIndicator(
      onRefresh: () async {},
      child: Center(
        child: TextButton(
          onPressed: () {
            MusicApi.pickAndUploadMusic();
          },
          child: const Text("上传"),
        ),
      ),
    );
  }

  Widget _buildCenter() {
    return RefreshIndicator(
      onRefresh: () async {},
      child: const Center(child: Text("专辑列表")),
    );
  }

  Widget _buildQueue() {
    final musicProvider = context.watch<MusicProvider>();
    final queue = musicProvider.queue;

    return RefreshIndicator(
      onRefresh: () async {},
      child: queue.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue_music_rounded,
                      size: 64, color: Colors.black26),
                  SizedBox(height: 16),
                  Text("播放队列为空"),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: queue.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final music = queue[index];
                final isCurrent = music.id == musicProvider.currentMusic?.id;
                return Card(
                  color: isCurrent
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : null,
                  child: ListTile(
                    selected: isCurrent,
                    onTap: () {
                      musicProvider.playFromLibrary(music);
                      context.push("/music-detail", extra: music);
                    },
                    leading: Container(
                      width: 50,
                      height: 50,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: music.coverBytes != null
                          ? Image.memory(music.coverBytes!, fit: BoxFit.cover)
                          : const Icon(Icons.music_note),
                    ),
                    title: Text(
                      music.title,
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(music.artist),
                    trailing: IconButton(
                      onPressed: () {
                        context.read<MusicProvider>().removeFromQueue(index);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPlaylists() {
    final musicProvider = context.watch<MusicProvider>();
    final userPlaylists = musicProvider.userPlaylists;
    final favorites = musicProvider.favoritesPlaylist;

    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Favorites card
            if (favorites != null)
              _PlaylistCard(
                playlist: favorites,
                songCount: musicProvider.favList.length,
                onTap: () {
                  context.push("/user/favorites");
                },
              ),
            const SizedBox(height: 16),
            // User playlists section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "我的歌单",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: () => _showCreatePlaylistDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text("新建"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            userPlaylists.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        "还没有创建歌单\n点击右上角新建",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: userPlaylists
                        .map((playlist) => _PlaylistCard(
                              playlist: playlist,
                              songCount: playlist.songIds.length,
                                onTap: () {
                                  context
                                      .push("/playlist/${playlist.id}");
                                },
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("新建歌单"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "歌单名称",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("创建"),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      context.read<MusicProvider>().createPlaylist(name);
    }
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final int songCount;
  final VoidCallback onTap;

  const _PlaylistCard({
    required this.playlist,
    required this.songCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 140,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: playlist.coverBytes != null &&
                            playlist.coverBytes!.isNotEmpty
                        ? Image.memory(
                            playlist.coverBytes!,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.playlist_play_rounded,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$songCount 首",
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
