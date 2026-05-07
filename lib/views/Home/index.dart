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
    final history = context.watch<MusicProvider>().history;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('发现'),
            centerTitle: false,
          ),
          // ── 轮播图区域 ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: height / 3),
                  child: CarouselView.weighted(
                    itemSnapping: true,
                    controller: controller,
                    flexWeights: const <int>[1, 7, 1],

                    onTap: (index) => controller.animateToItem(
                      index,
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                    ),
                    children: ImageInfo.values
                        .map((image) => HeroLayoutCard(imageInfo: image))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),

          // ── 最近播放标题栏 ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '最近播放',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/user/recent'),
                    child: const Text('查看更多'),
                  ),
                ],
              ),
            ),
          ),

          // ── 最近播放横向列表 ─────────────────────────────────────────────────
          history.isEmpty
              ? SliverToBoxAdapter(
                  child: SizedBox(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 32,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '暂无播放记录',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverToBoxAdapter(
                  child: SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: history.take(6).length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return GestureDetector(
                          onTap: () {
                            context.read<MusicProvider>().playFromLibrary(item);
                            context.push('/music-detail', extra: item);
                          },
                          child: Container(
                            width: 100,
                            margin: EdgeInsets.only(
                              right: index == history.take(6).length - 1
                                  ? 0
                                  : 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    color: colorScheme.surfaceContainerHighest,
                                    child:
                                        item.coverBytes != null &&
                                            item.coverBytes!.isNotEmpty
                                        ? Image.memory(
                                            item.coverBytes!,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            Icons.music_note_rounded,
                                            color: colorScheme.primary,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall,
                                ),
                                Text(
                                  item.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                '排行榜',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          
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
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onInverseSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                imageInfo.subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onInverseSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
