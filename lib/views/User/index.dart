import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/components/Shared/index.dart';
import 'package:myapp/model/Playlist/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:myapp/providers/NavProvider/index.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final nav = context.read<NavProvider>();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. 沉浸式顶部栏
          SliverAppBar(
            pinned: true,
            title: const Text("个人主页"),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert), // 纵向三个点
                onSelected: (value) {
                  if (value == "edit") {
                    context.push("/user/edit-profile");
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: "share",
                    child: ListTile(
                      leading: Icon(Icons.share_outlined),
                      title: Text('分享'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('编辑'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: colorScheme.error),
                      title: Text(
                        '删除',
                        style: TextStyle(color: colorScheme.error),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 2. 用户信息卡片区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const M3UserCard(
                username: "蒼璃 s0raLin",
                description: "用户中心与收藏",
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 3. 快捷入口
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  _PlaylistQuickCard(
                    onTap: () => context.push("/user/playlist/favorites"),
                    title: "喜欢",
                    icon: Icons.favorite_rounded,
                  ),
                  _PlaylistQuickCard(
                    onTap: () => context.push("/user/recent"),
                    title: "最近",
                    icon: Icons.history_rounded,
                  ),
                  _PlaylistQuickCard(
                    onTap: () => context.push("/user/files"),
                    title: "本地",
                    icon: Icons.folder_special_rounded,
                  ),
                  _PlaylistQuickCard(
                    onTap: () => context.push("/user/network"),
                    title: "网络",
                    icon: Icons.cloud_queue,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 4. 歌单管理区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(title: "我的歌单"),
                  const SizedBox(height: 12),
                  // 新建歌单按钮 + 进入音乐库链接
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () => _showCreatePlaylistDialog(context),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text("新建歌单"),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: () => nav.jumpByPath("/music"),
                        icon: const Icon(Icons.library_music_rounded, size: 18),
                        label: const Text("音乐库"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 歌单列表
                  Consumer<MusicProvider>(
                    builder: (context, musicProvider, _) {
                      final userPlaylists = musicProvider.userPlaylists;
                      if (userPlaylists.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: AppPanel(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor:
                                      colorScheme.secondaryContainer,
                                  foregroundColor:
                                      colorScheme.onSecondaryContainer,
                                  child: const Icon(Icons.queue_music_rounded),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "还没有创建歌单\n点击上方「新建歌单」按钮创建",
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220, // ← 关键：限制每个卡片最大宽度为 220
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: userPlaylists.length,
                        itemBuilder: (context, index) {
                          final playlist = userPlaylists[index];
                          return _UserPlaylistCard(
                            playlist: playlist,
                            songCount: playlist.songIds.length,
                            onTap: () {
                              context.push("/user/playlist/${playlist.id}");
                            },
                            onMoreTap: () {
                              _showPlaylistOptions(
                                context,
                                playlist,
                                musicProvider,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// --- 用户播放列表卡（用于网格） ---
class _UserPlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final int songCount;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _UserPlaylistCard({
    required this.playlist,
    required this.songCount,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final actionBackground = colorScheme.surfaceContainerHigh.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.9 : 0.82,
    );
    return MediaGridCard(
      title: playlist.name,
      subtitle: "$songCount 首",
      coverBytes: playlist.coverBytes,
      fallbackIcon: Icons.playlist_play_rounded,
      onTap: onTap,
      coverAspectRatio: 1.22,
      titleLines: 1,
      contentSpacing: 4,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      trailing: Material(
        color: actionBackground,
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onMoreTap,
          icon: Icon(
            Icons.more_horiz_rounded,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// --- 播放列表管理 ---
Future<void> _showPlaylistOptions(
  BuildContext context,
  Playlist playlist,
  MusicProvider provider,
) async {
  await showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!playlist.isSystem) ...[
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("重命名"),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, playlist, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outlined),
              title: const Text("删除"),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(context, playlist, provider);
              },
            ),
          ] else
            ListTile(
              leading: const Icon(Icons.info_outlined),
              title: const Text("系统歌单"),
              onTap: () => Navigator.pop(context),
            ),
        ],
      ),
    ),
  );
}

Future<void> _showRenameDialog(
  BuildContext context,
  Playlist playlist,
  MusicProvider provider,
) async {
  final controller = TextEditingController(text: playlist.name);
  final newName = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("重命名歌单"),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: "歌单名称"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("取消"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text("确定"),
        ),
      ],
    ),
  );
  if (!context.mounted) return;
  if (newName != null && newName.isNotEmpty) {
    provider.renamePlaylist(playlist.id, newName);
  }
}

Future<void> _showDeleteConfirmDialog(
  BuildContext context,
  Playlist playlist,
  MusicProvider provider,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("删除歌单"),
      content: Text("确定要删除「${playlist.name}」吗？"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("取消"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("删除"),
        ),
      ],
    ),
  );
  if (!context.mounted) return;
  if (confirmed == true) {
    provider.deletePlaylist(playlist.id);
  }
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
        decoration: const InputDecoration(hintText: "歌单名称"),
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
  if (!context.mounted) return;
  if (name != null && name.isNotEmpty) {
    context.read<MusicProvider>().createPlaylist(name);
  }
}

// --- 优化后的用户信息卡片 ---
class M3UserCard extends StatelessWidget {
  final String username;
  final String description;
  const M3UserCard({
    super.key,
    required this.username,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppPanel(
      color: colorScheme.surfaceContainer,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colorScheme.primary,
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurfaceVariant,
                  child: const Icon(Icons.person_rounded, size: 34),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () => context.push("/user/edit-profile"),
                child: const Text("编辑"),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: colorScheme.outlineVariant),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("动态", "128", colorScheme),
              _buildStatItem("关注", "1.2k", colorScheme),
              _buildStatItem("粉丝", "8.5k", colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

// --- 优化后的快捷入口卡片 ---
class _PlaylistQuickCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _PlaylistQuickCard({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      height: 116,
      child: QuickActionCard(title: title, icon: icon, onTap: onTap),
    );
  }
}
