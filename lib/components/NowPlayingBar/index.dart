import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:provider/provider.dart';

/// 底部播放进度栏组件
class NowPlayingBar extends StatelessWidget {
  static const double _breakpoint = 700.0; // 响应式切换阈值
  const NowPlayingBar({super.key});

  /// 时间格式化辅助函数：将 Duration 转为 00:00 格式
  static String _fmt(Duration d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.inMinutes.remainder(60))}:${p(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    // 监听当前音乐信息，如果没有播放内容则隐藏
    final music = context.select<MusicProvider, MusicInfo?>(
      (p) => p.currentMusic,
    );
    if (music == null) return const SizedBox.shrink();

    return _BarContainer(
      onTap: () => context.push('/music-detail'), // 点击跳转详情页
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _breakpoint;
          // 根据容器宽度决定布局模式
          if (isWide) return _WideLayout(music: music, fmt: _fmt);
          return _CompactLayout(music: music);
        },
      ),
    );
  }
}

/// 播放栏外层容器：处理背景色、圆角、高度和点击反馈
class _BarContainer extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _BarContainer({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: SizedBox(
          width: double.infinity,
          height: 84, // 固定高度
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 宽屏模式布局：左右固定/自适应，中间绝对居中
class _WideLayout extends StatelessWidget {
  final MusicInfo music;
  final String Function(Duration) fmt;
  const _WideLayout({required this.music, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final mp = context.read<MusicProvider>();

    // 使用 Stack 配合 Center 实现中间内容绝对居中
    return Stack(
      alignment: Alignment.center,
      children: [
        // 左侧：歌曲信息
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300), // 限制左侧最大宽度避免挤压中间
            child: _TrackInfo(music: music),
          ),
        ),

        // 中间：播放控制按钮和进度条（绝对居中）
        _PlaybackCenter(fmt: fmt),

        // 右侧：功能操作
        Align(
          alignment: Alignment.centerRight,
          child: _QueueActions(
            showCompactPlayPause: false,
            onPlayPause: mp.togglePlay,
          ),
        ),
      ],
    );
  }
}

/// 紧凑模式布局：仅显示歌曲信息和基本控制
class _CompactLayout extends StatelessWidget {
  final MusicInfo music;
  const _CompactLayout({required this.music});

  @override
  Widget build(BuildContext context) {
    final mp = context.read<MusicProvider>();
    return Row(
      children: [
        Expanded(child: _TrackInfo(music: music)),
        _QueueActions(showCompactPlayPause: true, onPlayPause: mp.togglePlay),
      ],
    );
  }
}

/// 歌曲基本信息：封面 + 歌名 + 歌手
class _TrackInfo extends StatelessWidget {
  final MusicInfo music;
  const _TrackInfo({required this.music});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AlbumArt(coverBytes: music.coverBytes),
        const SizedBox(width: 12),
        Flexible(
          // 使用 Flexible 允许文本在空间不足时省略
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                music.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                music.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 中间播放控制区域
class _PlaybackCenter extends StatelessWidget {
  final String Function(Duration) fmt;
  const _PlaybackCenter({required this.fmt});

  @override
  Widget build(BuildContext context) {
    final mp = context.read<MusicProvider>();
    final cs = Theme.of(context).colorScheme;
    // 监听播放状态
    final isPlaying = context.select<MusicProvider, bool>(
      (p) => p.player.playing,
    );
    final isShuffle = context.select<MusicProvider, bool>(
      (p) => p.playMode == PlayMode.shuffle,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MiniIconButton(
              icon: isShuffle ? Icons.sort_rounded : Icons.shuffle_rounded,
              tooltip: isShuffle ? '顺序播放' : '随机播放',
              color: isShuffle ? cs.primary : cs.onSurfaceVariant,
              onPressed: mp.togglePlayMode,
            ),
            _MiniIconButton(
              icon: Icons.skip_previous_rounded,
              onPressed: mp.playPrev,
            ),
            // 主播放按钮
            _MiniIconButton(
              icon: isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              size: 40, // 突出显示
              color: cs.primary,
              onPressed: mp.togglePlay,
            ),
            _MiniIconButton(
              icon: Icons.skip_next_rounded,
              onPressed: mp.playNext,
            ),
          ],
        ),
        const SizedBox(height: 4),
        _ProgressBar(fmt: fmt),
      ],
    );
  }
}

/// 进度条组件：使用 StreamBuilder 实现秒级更新
class _ProgressBar extends StatelessWidget {
  final String Function(Duration) fmt;
  const _ProgressBar({required this.fmt});

  @override
  Widget build(BuildContext context) {
    final mp = context.read<MusicProvider>();
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<PositionData>(
      stream: mp.positionDataStream, // 监听位置、缓存、时长流
      builder: (context, snap) {
        final pos =
            snap.data ??
            PositionData(Duration.zero, Duration.zero, Duration.zero);
        final durationMs = pos.duration.inMilliseconds;
        final positionMs = pos.position.inMilliseconds;

        // 计算百分比
        double value = (durationMs > 0) ? positionMs / durationMs : 0.0;

        return SizedBox(
          width: 320, // 固定宽度确保居中视觉稳定
          child: Row(
            children: [
              Text(fmt(pos.position), style: _ts(cs)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    year2023: false,
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: value.clamp(0.0, 1.0),
                    onChanged: (v) => mp.player.seek(
                      Duration(milliseconds: (durationMs * v).toInt()),
                    ),
                  ),
                ),
              ),
              Text(fmt(pos.duration), style: _ts(cs)),
            ],
          ),
        );
      },
    );
  }

  TextStyle _ts(ColorScheme cs) =>
      TextStyle(fontSize: 10, color: cs.onSurfaceVariant);
}

/// 更多操作：包括播放队列菜单
class _QueueActions extends StatelessWidget {
  final bool showCompactPlayPause;
  final VoidCallback onPlayPause;
  const _QueueActions({
    required this.showCompactPlayPause,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = context.select<MusicProvider, bool>(
      (p) => p.player.playing,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCompactPlayPause)
          _MiniIconButton(
            icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onPressed: onPlayPause,
          ),
        // 点击弹出播放队列菜单
        MenuAnchor(
          menuChildren: [/* ...此处省略内部 List 逻辑... */],
          builder: (context, controller, child) {
            return _MiniIconButton(
              icon: Icons.queue_music_rounded,
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 以下为基础 UI 小组件，增加了容错处理
// ---------------------------------------------------------------------------

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? color;
  final String? tooltip;

  const _MiniIconButton({
    required this.icon,
    required this.onPressed,
    this.size = 28,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}

class _AlbumArt extends StatelessWidget {
  final Uint8List? coverBytes;
  const _AlbumArt({this.coverBytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: coverBytes != null && coverBytes!.isNotEmpty
          ? Image.memory(coverBytes!, fit: BoxFit.cover)
          : const Icon(Icons.music_note_rounded),
    );
  }
}
