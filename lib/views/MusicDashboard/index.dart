import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

class MusicDashboardPage extends StatelessWidget {
  const MusicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          // 定义响应式变量
          final int crossAxisCount;
          final List<QuiltedGridTile> pattern;
          final double horizontalPadding;
          final double spacing;

          // 响应式逻辑
          if (width < 600) {
            // 1. 窄屏 (手机)
            crossAxisCount = 2;
            horizontalPadding = 16.0;
            spacing = 12.0;
            pattern = const [
              QuiltedGridTile(2, 2), // 专辑封面
              QuiltedGridTile(1, 2), // 播放控制
              QuiltedGridTile(1, 1), // 采样率
              QuiltedGridTile(1, 1), // 输出设备
              QuiltedGridTile(2, 2), // 歌词预览
            ];
          } else if (width < 1024) {
            // 2. 中等屏 (平板/窄窗口)
            crossAxisCount = 4;
            horizontalPadding = 24.0;
            spacing = 16.0;
            pattern = const [
              QuiltedGridTile(2, 2), // 专辑封面
              QuiltedGridTile(1, 2), // 播放控制
              QuiltedGridTile(1, 1), // 采样率
              QuiltedGridTile(1, 1), // 输出设备
              QuiltedGridTile(1, 4), // 歌词横向长条
            ];
          } else {
            // 3. 宽屏 (桌面)
            crossAxisCount = 6;
            horizontalPadding = 32.0;
            spacing = 20.0;
            pattern = const [
              QuiltedGridTile(3, 3), // 专辑封面 (占据一半高度和一半宽度)
              QuiltedGridTile(1, 3), // 播放控制
              QuiltedGridTile(1, 1), // 采样率
              QuiltedGridTile(1, 1), // 输出设备
              QuiltedGridTile(1, 1), // 备用占位
              QuiltedGridTile(1, 3), // 歌词预览
            ];
          }

          return Center(
            child: ConstrainedBox(
              // 关键：限制桌面端内容最大宽度
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: const Text(
                      "M3Music",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    centerTitle: false,
                    backgroundColor: Colors.transparent,
                    scrolledUnderElevation: 0,
                    pinned: true,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      32,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverQuiltedGridDelegate(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        repeatPattern: QuiltedGridRepeatPattern.inverted,
                        pattern: pattern,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _DashboardCard(index: index, screenWidth: width),
                        childCount: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final int index;
  final double screenWidth;

  const _DashboardCard({required this.index, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 状态配置
    final Color bgColor;
    final Color onColor;
    final String label;
    final IconData icon;

    switch (index) {
      case 0:
        bgColor = colorScheme.primaryContainer;
        onColor = colorScheme.onPrimaryContainer;
        label = "Now Playing";
        icon = Icons.album_rounded;
        break;
      case 1:
        bgColor = colorScheme.secondaryContainer;
        onColor = colorScheme.onSecondaryContainer;
        label = "Control";
        icon = Icons.play_arrow_rounded;
        break;
      case 2:
        bgColor = colorScheme.surfaceContainerHighest.withOpacity(0.5);
        onColor = colorScheme.onSurfaceVariant;
        label = "96kHz";
        icon = Icons.high_quality_rounded;
        break;
      case 3:
        bgColor = colorScheme.surfaceContainerHighest.withOpacity(0.5);
        onColor = colorScheme.onSurfaceVariant;
        label = "LDAC";
        icon = Icons.bluetooth_audio_rounded;
        break;
      default:
        bgColor = colorScheme.tertiaryContainer;
        onColor = colorScheme.onTertiaryContainer;
        label = "Lyrics Preview";
        icon = Icons.short_text_rounded;
    }

    // 桌面端微调：让图标和文字不要太大
    final double responsiveIconSize = screenWidth > 1024 ? 24 : 28;
    final double responsivePadding = screenWidth > 1024 ? 20 : 16;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28), // 稍微调圆润一点更现代
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent, // 保证水波纹在 Container 之上
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            if (index == 0) {
              context.push("/dashboard/cover-flow");
            }
          },
          child: Padding(
            padding: EdgeInsets.all(responsivePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: onColor, size: responsiveIconSize),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      color: onColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontSize: screenWidth > 1024 ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
