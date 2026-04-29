// ─── HomePage ─────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/contants/Assets/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum ImageInfo {
  image0("1", "", MyAssets.background),
  image1("2", "", MyAssets.background2),
  image2("3", "", MyAssets.background3),
  image3("4", "", MyAssets.background4);

  const ImageInfo(this.title, this.subtitle, this.url);
  final String title;
  final String subtitle;
  final String url;
}

class _HomePageState extends State<HomePage> {
  final CarouselController controller = CarouselController(initialItem: 1);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = context.read<MusicProvider>().history;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('发现'),
            centerTitle: false,
            actions: [
              IconButton(
                tooltip: '搜索',
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          // ── 轮播图区域 ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 根据屏幕宽度动态调整宽高比和最大宽度
                  final double maxWidth = constraints.maxWidth > 1400
                      ? 1200 // 超宽屏限制最大宽度
                      : constraints.maxWidth;

                  final double aspectRatio = constraints.maxWidth > 1100
                      ? 16 /
                            7.5 // 桌面端：让它更接近正方形一些，不那么长
                      : constraints.maxWidth > 800
                      ? 16 / 8.2
                      : 16 / 9; // 手机端保持 16:9

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxWidth,
                        maxHeight: 380, // 给一个较高的上限，避免过低
                      ),
                      child: AspectRatio(
                        aspectRatio: aspectRatio,
                        child: Card.filled(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: CarouselView.weighted(
                            itemSnapping: true,
                            controller: controller,
                            flexWeights: const <int>[1, 7, 1],
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onTap: (index) => controller.animateToItem(
                              index,
                              duration: const Duration(milliseconds: 650),
                              curve: Curves.easeOutCubic,
                            ),
                            children: ImageInfo.values
                                .map(
                                  (image) => HeroLayoutCard(imageInfo: image),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── 歌曲推荐标题栏 ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '歌曲推荐',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('播放全部'),
                  ),
                ],
              ),
            ),
          ),

          // ── 歌曲列表 ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: ListTileTheme(
              data: ListTileThemeData(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: SliverList.separated(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Card(
                    color: colorScheme.surfaceContainerLow,
                    child: ListTile(
                      onTap: () => context.push("/music/$index"),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                        child: const Icon(Icons.library_music_rounded),
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.artist} · ${item.album}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      horizontalTitleGap: 4,
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 6),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }
}

class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({super.key, required this.imageInfo});

  final ImageInfo imageInfo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image(
            image: AssetImage(imageInfo.url),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                colorScheme.scrim.withValues(alpha: 0.55),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                imageInfo.title,
                style: textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                imageInfo.subtitle,
                style: textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
