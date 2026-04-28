import 'package:flutter/material.dart';

class RecentlyPlayedPage extends StatelessWidget {
  const RecentlyPlayedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("最近播放"),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: "清空历史",
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _MusicListTile(
                  title: "歌曲名称 $index",
                  subtitle: "歌手名 - 专辑名",
                  imageUrl: null, // 传入图片地址
                  onTap: () {
                    // 播放逻辑
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;

  const _MusicListTile({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: imageUrl != null
              ? Image.network(imageUrl!, fit: BoxFit.cover)
              : const Icon(Icons.music_note),
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          // 弹出底部菜单：下一首播放、收藏、删除记录等
        },
      ),
    );
  }
}
