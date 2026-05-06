import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// ─── 入口页面 ────────────────────────────────────────────────────────────────

/// ======================== 主页面 ========================
class MusicDetailPage extends StatefulWidget {
  const MusicDetailPage({super.key});

  @override
  State<MusicDetailPage> createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final music = context.select<MusicProvider, MusicInfo?>(
      (p) => p.currentMusic,
    );
    if (music == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLiked = context.select<MusicProvider, bool>(
      (p) => p.favList.any((m) => m.id == music.id),
    );

    final isWide = MediaQuery.sizeOf(context).width > 700;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, music, colorScheme, isWide),
      body: isWide
          ? _WideLayout(music: music, isLiked: isLiked)
          : _NarrowLayout(
              music: music,
              isLiked: isLiked,
              tabController: _tabController,
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    MusicInfo music,
    ColorScheme scheme,
    bool isWide,
  ) {
    final tt = Theme.of(context).textTheme;
    final titleWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '正在播放',
          style: tt.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        Text(
          music.title,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
        onPressed: () => context.pop(),
      ),
      title: titleWidget,
      bottom: isWide
          ? null
          : TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '歌曲'),
                Tab(text: '歌词'),
              ],
              indicatorColor: scheme.primary,
              labelColor: scheme.primary,
              unselectedLabelColor: scheme.onSurfaceVariant,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}

/// ======================== 布局 ========================
class _WideLayout extends StatelessWidget {
  final MusicInfo music;
  final bool isLiked;

  const _WideLayout({required this.music, required this.isLiked, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _CoverTabContent(music: music, isLiked: isLiked),
          ),
          const VerticalDivider(width: 40, color: Colors.transparent),
          const Expanded(flex: 4, child: _LyricsSection()),
        ],
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final MusicInfo music;
  final bool isLiked;
  final TabController tabController;

  const _NarrowLayout({
    required this.music,
    required this.isLiked,
    required this.tabController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _CoverTabContent(music: music, isLiked: isLiked),
        ),
        const _LyricsSection(),
      ],
    );
  }
}

/// ======================== 歌曲封面 + 元信息 + 控制台 ========================
class _CoverTabContent extends StatelessWidget {
  final MusicInfo music;
  final bool isLiked;

  const _CoverTabContent({
    required this.music,
    required this.isLiked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MusicProvider>();

    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: GestureDetector(
            onTap: () => _showSongInfoSheet(context, music),
            child: _AlbumCover(
              title: music.title,
              coverBytes: music.coverBytes,
            ),
          ),
        ),
        const SizedBox(height: 28),
        _SongMeta(
          music: music,
          isLiked: isLiked,
          onToggleLike: () => provider.toggleFav(music),
          onAddToPlaylist: () => _showAddToPlaylistSheet(context, music),
        ),
        const SizedBox(height: 20),
        _PlayerConsole(music: music),
        const SizedBox(height: 28),
      ],
    );
  }

  // ... _showAddToPlaylistSheet 和 _showSongInfoSheet 保持不变（代码较长，未改动核心逻辑）
  Future<void> _showAddToPlaylistSheet(
    BuildContext context,
    MusicInfo song,
  ) async {
    /* 原代码 */
  }
  Future<void> _showSongInfoSheet(BuildContext context, MusicInfo music) async {
    /* 原代码 */
  }
}

/// ======================== 封面 ========================
class _AlbumCover extends StatelessWidget {
  final String title;
  final Uint8List? coverBytes;

  const _AlbumCover({required this.title, required this.coverBytes, super.key});

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
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// ======================== 歌曲信息 ========================
class _SongMeta extends StatelessWidget {
  final MusicInfo music;
  final bool isLiked;
  final VoidCallback onToggleLike;
  final VoidCallback? onAddToPlaylist;

  const _SongMeta({
    required this.music,
    required this.isLiked,
    required this.onToggleLike,
    this.onAddToPlaylist,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${music.artist} · ${music.album}',
                style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onToggleLike,
          icon: Icon(
            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isLiked ? cs.primary : cs.onSurfaceVariant,
            size: 28,
          ),
        ),
        if (onAddToPlaylist != null)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: cs.onSurfaceVariant,
              size: 24,
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'add', child: Text('添加到歌单')),
            ],
            onSelected: (_) => onAddToPlaylist?.call(),
          ),
      ],
    );
  }
}

/// ======================== 播放控制台 ========================
class _PlayerConsole extends StatelessWidget {
  final MusicInfo music;

  const _PlayerConsole({required this.music, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MusicProvider>();

    return StreamBuilder<PositionData>(
      stream: provider.positionDataStream,
      builder: (context, snapshot) {
        final data =
            snapshot.data ??
            PositionData(Duration.zero, Duration.zero, Duration.zero);
        final totalMs = data.duration.inMilliseconds.toDouble();
        final posMs = data.position.inMilliseconds.toDouble().clamp(
          0.0,
          totalMs,
        );

        return Column(
          children: [
            _DraggableProgressBar(
              position: posMs,
              total: totalMs,
              onSeek: (ms) =>
                  provider.player.seek(Duration(milliseconds: ms.toInt())),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PlayerConsole._durationText(
                  data.position,
                  Theme.of(context).colorScheme,
                ),
                _PlayerConsole._durationText(
                  data.duration,
                  Theme.of(context).colorScheme,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _PlaybackControls(musicProvider: provider),
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

/// ======================== 歌词区域 ========================
class _LyricsSection extends StatefulWidget {
  const _LyricsSection({super.key});

  @override
  State<_LyricsSection> createState() => _LyricsSectionState();
}

class _LyricsSectionState extends State<_LyricsSection>
    with AutomaticKeepAliveClientMixin {
  final ItemScrollController _scrollController = ItemScrollController();

  int _lastAutoScrollIndex = -1;
  List<Map<String, dynamic>> _prevLyrics = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次依赖变化时重新检查歌词（页面重新进入时触发）
    _handleLyricsChange();
  }

  @override
  void didUpdateWidget(covariant _LyricsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleLyricsChange();
  }

  void _handleLyricsChange() {
    final currentLyrics = context.read<MusicProvider>().currentLyrics;
    // final currentHash = Object.hashAll(currentLyrics.map((e) => e['time']));

    // 检测歌词是否发生变化（切换歌曲时）
    if (!_listsAreEqual(currentLyrics, _prevLyrics)) {
      _prevLyrics = List.from(currentLyrics); // 深拷贝
      _lastAutoScrollIndex = -1; // 重置滚动位置
    }
  }

  // 简单的列表比较（避免 lint 警告且更可靠）
  bool _listsAreEqual(
    List<Map<String, dynamic>> a,
    List<Map<String, dynamic>> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i]['time'] != b[i]['time'] || a[i]['text'] != b[i]['text']) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final lyrics = context.watch<MusicProvider>().currentLyrics;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (lyrics.isEmpty) {
      return Center(
        child: Text(
          '暂无歌词',
          style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return StreamBuilder<PositionData>(
      stream: context.read<MusicProvider>().positionDataStream,
      builder: (context, snapshot) {
        final position = snapshot.data?.position ?? Duration.zero;

        // 计算当前歌词索引
        int currentIndex = 0;
        for (var i = 0; i < lyrics.length; i++) {
          if (position >= (lyrics[i]['time'] as Duration)) {
            currentIndex = i;
          } else {
            break;
          }
        }

        // 自动滚动
        if (currentIndex != _lastAutoScrollIndex &&
            _scrollController.isAttached) {
          _lastAutoScrollIndex = currentIndex;
          final isNearEnd = currentIndex >= lyrics.length - 3;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _scrollController.scrollTo(
              index: currentIndex,
              alignment: isNearEnd ? 0.1 : 0.5,
              duration: Duration(milliseconds: isNearEnd ? 340 : 300),
              curve: Curves.easeOutCubic,
            );
          });
        }

        return Stack(
          children: [
            ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              itemCount: lyrics.length,
              padding: const EdgeInsets.symmetric(vertical: 80),
              itemBuilder: (context, index) {
                final item = lyrics[index];
                final isActive = index == currentIndex;
                final isNear = (index - currentIndex).abs() == 1;

                return _LyricLine(
                  text: item['text'] as String,
                  isActive: isActive,
                  isNear: isNear,
                  onTap: () => context.read<MusicProvider>().player.seek(
                    item['time'] as Duration,
                  ),
                );
              },
            ),
            // 顶部/底部渐隐
            _buildFadeGradient(cs, Alignment.topCenter),
            _buildFadeGradient(cs, Alignment.bottomCenter),
          ],
        );
      },
    );
  }

  Widget _buildFadeGradient(ColorScheme cs, Alignment alignment) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: alignment,
              end: alignment == Alignment.topCenter
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              colors: [cs.surface, cs.surface.withValues(alpha: 0.0)],
            ),
          ),
        ),
      ),
    );
  }
}

/// ======================== 单行歌词 ========================
class _LyricLine extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool isNear;
  final VoidCallback onTap;

  const _LyricLine({
    required this.text,
    required this.isActive,
    required this.isNear,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final style = isActive
        ? TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: cs.primary,
            height: 1.4,
          )
        : isNear
        ? TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: cs.onSurface.withValues(alpha: 0.6),
            height: 1.4,
          )
        : TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
            height: 1.4,
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          style: style,
          child: Text(
            text.isEmpty ? '\u00a0' : text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

//可拖动进度条
class _DraggableProgressBar extends StatelessWidget {
  final double position; // 当前毫秒
  final double total; // 总时长毫秒
  final ValueChanged<double> onSeek;

  const _DraggableProgressBar({
    super.key,
    required this.position,
    required this.total,
    required this.onSeek,
  });

  // 格式化时间函数
  String _formatMs(double ms) {
    final s = (ms / 1000).round();
    final m = s ~/ 60;
    final sec = s % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 确保 value 不超过 range
    final double safeValue = position.clamp(0.0, total > 0 ? total : 1.0);
    final double safeTotal = total > 0 ? total : 1.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        // Material 3 默认指示器是矩形/圆角矩形，适合显示时间
        showValueIndicator: ShowValueIndicator.onDrag,
      ),
      child: Slider(
        year2023: false,
        value: safeValue,
        max: safeTotal,
        divisions: total > 0 ? total.toInt() : null, // 增加刻度感，使 label 弹出
        label: _formatMs(safeValue), // 拖动时显示的悬浮文字
        onChanged: (value) {
          // M3 的 Slider 会在 onChanged 时自动处理内部状态
          onSeek(value);
        },
      ),
    );
  }
}

// ─── 播放按钮组 ────────────────────────────────────────────────────────────────

class _PlaybackControls extends StatelessWidget {
  final MusicProvider musicProvider;

  const _PlaybackControls({required this.musicProvider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<ProcessingState>(
      stream: musicProvider.player.processingStateStream,
      builder: (context, snapshot) {
        final playing = musicProvider.player.playing;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 播放模式
            IconButton(
              onPressed: musicProvider.togglePlayMode,
              icon: Icon(_getModeIcon(musicProvider.playMode)),
              color: colorScheme.onSurfaceVariant,
              tooltip: '播放模式',
            ),
            const SizedBox(width: 12),
            // 上一首
            _RoundIconButton(
              tooltip: '上一首',
              icon: Icons.skip_previous_rounded,
              onPressed: musicProvider.playPrev,
            ),
            const SizedBox(width: 12),
            // 播放/暂停
            IconButton.filled(
              onPressed: musicProvider.togglePlay,
              icon: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const CircleBorder(),
                fixedSize: const Size(64, 64),
              ),
            ),
            const SizedBox(width: 12),
            // 下一首
            _RoundIconButton(
              tooltip: '下一首',
              icon: Icons.skip_next_rounded,
              onPressed: musicProvider.playNext,
            ),
            const SizedBox(width: 12),
            // 音量
            _VolumeButton(musicProvider: musicProvider),
          ],
        );
      },
    );
  }

  IconData _getModeIcon(PlayMode mode) {
    switch (mode) {
      case PlayMode.sequence:
        return Icons.repeat_rounded;
      case PlayMode.shuffle:
        return Icons.shuffle_rounded;
      case PlayMode.repeat:
        return Icons.repeat_one_rounded;
    }
  }
}

// ─── 通用圆形图标按钮 ──────────────────────────────────────────────────────────

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;

  const _RoundIconButton({required this.icon, this.tooltip, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: cs.onSurfaceVariant,
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(14),
      ),
    );
  }
}

// ─── 音量按钮（带弹出滑条） ────────────────────────────────────────────────────

class _VolumeButton extends StatefulWidget {
  final MusicProvider musicProvider;

  const _VolumeButton({required this.musicProvider});

  @override
  State<_VolumeButton> createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<_VolumeButton> {
  final MenuController _menuController = MenuController();
  double _lastNonZeroVolume = 1.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<double>(
      stream: widget.musicProvider.player.volumeStream,
      builder: (context, snapshot) {
        final volume = snapshot.data ?? widget.musicProvider.volume;
        if (volume > 0) _lastNonZeroVolume = volume;

        final IconData icon;
        if (volume == 0) {
          icon = Icons.volume_off_rounded;
        } else if (volume < 0.5) {
          icon = Icons.volume_down_rounded;
        } else {
          icon = Icons.volume_up_rounded;
        }

        return MenuAnchor(
          controller: _menuController,
          alignmentOffset: const Offset(-8, -6),
          menuChildren: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: SizedBox(
                height: 160,
                child: RotatedBox(
                  quarterTurns: -1,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      inactiveTrackColor: cs.surfaceContainerHighest,
                      activeTrackColor: cs.primary,
                    ),
                    child: Slider(
                      value: volume.clamp(0.0, 1.0),
                      onChanged: (v) => widget.musicProvider.setVolume(v),
                    ),
                  ),
                ),
              ),
            ),
          ],
          child: IconButton(
            tooltip: _menuController.isOpen ? '静音' : '音量',
            onPressed: () async {
              if (_menuController.isOpen) {
                final newVol = volume == 0
                    ? _lastNonZeroVolume.clamp(0.0, 1.0)
                    : 0.0;
                await widget.musicProvider.setVolume(newVol);
                return;
              }
              _menuController.open();
            },
            icon: Icon(icon),
            style: IconButton.styleFrom(
              foregroundColor: cs.onSurfaceVariant,
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
          ),
        );
      },
    );
  }
}
