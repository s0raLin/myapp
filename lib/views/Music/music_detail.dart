import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MusicDetailPage extends StatefulWidget {
  const MusicDetailPage({super.key});

  @override
  State<MusicDetailPage> createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage> {
  // 窄屏模式下，是否强制显示歌词
  bool _showLyricsOnMobile = false;
  @override
  Widget build(BuildContext context) {
    // 用 select 只监听必要字段，避免无关变化触发重建
    final music = context.select<MusicProvider, MusicInfo?>(
      (p) => p.currentMusic,
    );

    if (music == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLiked = context.select<MusicProvider, bool>(
      (p) => p.favList.any((m) => m.id == music.id),
    );
    final lyrics = context.select<MusicProvider, List<Map<String, dynamic>>>(
      (p) => p.currentLyrics,
    );

    final isWide = MediaQuery.sizeOf(context).width > 700;
    final colorScheme = Theme.of(context).colorScheme;

    final mainContent = _MainContent(music: music, isLiked: isLiked);
    final Widget mobileContent;
    if (_showLyricsOnMobile) {
      mobileContent = GestureDetector(
        onTap: () => setState(() {
          _showLyricsOnMobile = false;
        }),
        child: _LyricsSection(lyrics: lyrics),
      );
    } else {
      mobileContent = _MainContent(
        music: music,
        isLiked: isLiked,
        onCoverTap: () => setState(() {
          _showLyricsOnMobile = true;
        }),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, music, colorScheme),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: isWide
            ? Row(
                children: [
                  Expanded(flex: 5, child: mainContent),
                  const VerticalDivider(width: 40, color: Colors.transparent),
                  Expanded(flex: 4, child: _LyricsSection(lyrics: lyrics)),
                ],
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: mobileContent,
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    MusicInfo music,
    ColorScheme scheme,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
        onPressed: () => context.pop(),
      ),
      title: Column(
        children: [
          Text(
            '正在播放',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          Text(
            music.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── 主内容区（避免在顶层 watch 全量 provider） ─────────────────────────────────

class _MainContent extends StatelessWidget {
  final MusicInfo music;
  final bool isLiked;
  final VoidCallback? onCoverTap; //新增回调

  const _MainContent({
    required this.music,
    required this.isLiked,
    this.onCoverTap,
  });

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.read<MusicProvider>();

    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: GestureDetector(
            onTap: onCoverTap, //点击封面触发
            child: _AlbumCover(
              title: music.title,
              coverBytes: music.coverBytes,
            ),
          ),
        ),
        const SizedBox(height: 32),
        _SongMeta(
          music: music,
          isLiked: isLiked,
          onToggleLike: () => musicProvider.toggleFav(music),
        ),
        const SizedBox(height: 24),
        _PlayerConsole(music: music),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── 子组件 ─────────────────────────────────────────────────────────────────────

class _AlbumCover extends StatelessWidget {
  final String title;
  final Uint8List? coverBytes;

  const _AlbumCover({required this.coverBytes, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxHeight.clamp(0.0, constraints.maxWidth);
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: size,
              height: size,
              color: theme.colorScheme.surfaceContainerHighest,
              child: coverBytes?.isNotEmpty == true
                  ? Image.memory(coverBytes!, fit: BoxFit.cover)
                  : Icon(
                      Icons.music_note_rounded,
                      size: size * 0.3,
                      // withOpacity 已弃用，改用 withValues
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _SongMeta extends StatelessWidget {
  final MusicInfo music;
  final bool isLiked;
  final VoidCallback onToggleLike;

  const _SongMeta({
    required this.music,
    required this.isLiked,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                music.title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${music.artist} · ${music.album}',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onToggleLike,
          icon: Icon(
            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isLiked ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 28,
          ),
        ),
      ],
    );
  }
}

// ─── 播放控制台 ──────────────────────────────────────────────────────────────────

class _PlayerConsole extends StatelessWidget {
  final MusicInfo music;

  const _PlayerConsole({required this.music});

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.read<MusicProvider>();

    return StreamBuilder<PositionData>(
      stream: musicProvider.positionDataStream,
      builder: (context, snapshot) {
        final data =
            snapshot.data ??
            PositionData(Duration.zero, Duration.zero, Duration.zero);
        final total = data.duration.inMilliseconds.toDouble();
        final pos = data.position.inMilliseconds.toDouble().clamp(
          0.0,
          total > 0 ? total : 0.0,
        );

        return Column(
          children: [
            // Slider 单独提取避免整列重建
            _ProgressSlider(
              pos: pos,
              total: total,
              onChanged: (v) =>
                  musicProvider.player.seek(Duration(milliseconds: v.toInt())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _durationText(data.position, Theme.of(context).colorScheme),
                _durationText(data.duration, Theme.of(context).colorScheme),
              ],
            ),
            const SizedBox(height: 16),
            // 播放/暂停按钮单独 StreamBuilder，减少重建范围
            _PlaybackControls(musicProvider: musicProvider),
          ],
        );
      },
    );
  }

  static Widget _durationText(Duration d, ColorScheme scheme) => Text(
    '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}',
    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
  );
}

class _ProgressSlider extends StatelessWidget {
  final double pos;
  final double total;
  final ValueChanged<double> onChanged;

  const _ProgressSlider({
    required this.pos,
    required this.total,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(year2023: false, overlayColor: Colors.transparent),
      child: Slider(
        max: total > 0 ? total : 1.0,
        value: pos,
        onChanged: onChanged,
      ),
    );
  }
}

// 仅监听 playingStream，不依赖 MusicProvider 其他状态
class _PlaybackControls extends StatelessWidget {
  final MusicProvider musicProvider;

  const _PlaybackControls({required this.musicProvider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<bool>(
      stream: musicProvider.player.playingStream,
      builder: (context, snap) {
        final isPlaying = snap.data ?? false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // TODO: 接入 shuffle 逻辑
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shuffle_rounded),
            ),
            IconButton(
              onPressed: musicProvider.playPrev,
              icon: const Icon(Icons.skip_previous_rounded, size: 42),
            ),
            GestureDetector(
              onTap: musicProvider.togglePlay,
              child: CircleAvatar(
                radius: 36,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            IconButton(
              onPressed: musicProvider.playNext,
              icon: const Icon(Icons.skip_next_rounded, size: 42),
            ),
            // TODO: 接入 repeat 逻辑
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.repeat_rounded),
            ),
          ],
        );
      },
    );
  }
}

// ─── 歌词区 ──────────────────────────────────────────────────────────────────────

class _LyricsSection extends StatefulWidget {
  final List<Map<String, dynamic>> lyrics;
  const _LyricsSection({required this.lyrics});

  @override
  State<_LyricsSection> createState() => _LyricsSectionState();
}

class _LyricsSectionState extends State<_LyricsSection> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  int _lastIndex = -1;

  // 修复：分离"首次定位"和"滚动动画"逻辑
  void _scrollToCurrent(int index, {bool animate = true}) {
    if (!_itemScrollController.isAttached) return;
    if (index == _lastIndex) return;
    _lastIndex = index;

    if (animate) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        alignment: 0.45,
      );
    } else {
      // 首次进入页面时直接跳转，不做动画，避免从顶部滑下来的违和感
      _itemScrollController.jumpTo(index: index, alignment: 0.45);
    }
  }

  // 修复：抽取计算逻辑，避免边界错误
  int _calcCurrentIndex(Duration position) {
    if (widget.lyrics.isEmpty) return 0;

    // 找到第一个时间 > position 的歌词
    final nextIndex = widget.lyrics.indexWhere(
      (l) => (l['time'] as Duration) > position,
    );

    if (nextIndex <= 0) {
      // nextIndex == -1：position 超过所有歌词时间，显示最后一句
      // nextIndex == 0：position 在第一句之前，显示第一句
      return nextIndex == -1 ? widget.lyrics.length - 1 : 0;
    }

    return nextIndex - 1;
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.read<MusicProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.lyrics.isEmpty) {
      return const Center(child: Text('歌詞が見つかりません'));
    }

    return StreamBuilder<PositionData>(
      stream: musicProvider.positionDataStream,
      builder: (context, snapshot) {
        final position = snapshot.data?.position ?? Duration.zero;
        final currentIndex = _calcCurrentIndex(position);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          // 修复：首次滚动（_lastIndex == -1）用 jump，后续用 animate
          _scrollToCurrent(currentIndex, animate: _lastIndex != -1);
        });

        return ShaderMask(
          shaderCallback: (rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0.0, 0.2, 0.8, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: ScrollablePositionedList.builder(
            itemCount: widget.lyrics.length,
            itemScrollController: _itemScrollController,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, i) {
              final isCurrent = i == currentIndex;
              final lyric = widget.lyrics[i];
              return GestureDetector(
                onTap: () {
                  final targetTime = lyric['time'] as Duration;
                  musicProvider.player.seek(targetTime);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedScale(
                  scale: isCurrent ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    opacity: isCurrent ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                      child: Text(
                        lyric['text'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isCurrent
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
