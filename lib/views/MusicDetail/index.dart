import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
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
  late final PageController _mobilePageController;

  @override
  void initState() {
    super.initState();
    _mobilePageController = PageController();
  }

  @override
  void dispose() {
    _mobilePageController.dispose();
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

    final mainContent = _MainContent(
      music: music,
      isLiked: isLiked,
      onCoverTap: () => _showSongInfoSheet(context),
      onAddToPlaylist: () => _showAddToPlaylistSheet(context, music),
    );

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
                  Expanded(flex: 4, child: _LyricsSection()),
                ],
              )
            : PageView(
                controller: _mobilePageController,
                physics: const PageScrollPhysics(),
                children: [mainContent, _LyricsSection()],
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

  Future<void> _showAddToPlaylistSheet(
    BuildContext context,
    MusicInfo song,
  ) async {
    final musicProvider = context.read<MusicProvider>();
    final userPlaylists = musicProvider.userPlaylists;

    if (userPlaylists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("还没有可用的歌单，请先创建歌单"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "添加到歌单",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: userPlaylists.length,
                itemBuilder: (context, index) {
                  final playlist = userPlaylists[index];
                  final alreadyIn = playlist.songIds.contains(song.id);
                  return ListTile(
                    enabled: !alreadyIn,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child:
                          playlist.coverBytes != null &&
                              playlist.coverBytes!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                playlist.coverBytes!,
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      playlist.name,
                      style: TextStyle(
                        color: alreadyIn
                            ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5)
                            : null,
                      ),
                    ),
                    trailing: alreadyIn
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.green,
                            size: 18,
                          )
                        : null,
                    onTap: alreadyIn
                        ? null
                        : () {
                            musicProvider.addToPlaylist(playlist.id, song);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("已添加到「${playlist.name}」"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSongInfoSheet(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final mp = context.read<MusicProvider>();
    final music = mp.currentMusic;
    if (music == null) return;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainer,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                        ),
                        child: music.coverBytes?.isNotEmpty == true
                            ? Image.memory(music.coverBytes!, fit: BoxFit.cover)
                            : Icon(
                                Icons.music_note_rounded,
                                color: cs.primary.withValues(alpha: 0.6),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          music.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${music.artist} · ${music.album}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundIconButton(
                    tooltip: '上一首',
                    icon: Icons.skip_previous_rounded,
                    onPressed: () {
                      mp.playPrev();
                    },
                  ),
                  const SizedBox(width: 14),
                  _RoundIconButton(
                    tooltip: '下一首',
                    icon: Icons.skip_next_rounded,
                    onPressed: () {
                      mp.playNext();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 主内容区（避免在顶层 watch 全量 provider） ─────────────────────────────────

class _MainContent extends StatelessWidget {
  final MusicInfo music;
  final bool isLiked;
  final VoidCallback? onCoverTap;
  final VoidCallback? onAddToPlaylist;

  const _MainContent({
    required this.music,
    required this.isLiked,
    this.onCoverTap,
    this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.read<MusicProvider>();

    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: GestureDetector(
            onTap: onCoverTap,
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
          onAddToPlaylist: onAddToPlaylist,
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
  final VoidCallback? onAddToPlaylist;

  const _SongMeta({
    required this.music,
    required this.isLiked,
    required this.onToggleLike,
    this.onAddToPlaylist,
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
        if (onAddToPlaylist != null)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "add_to_playlist",
                child: Text("添加到歌单"),
              ),
            ],
            onSelected: (value) {
              if (value == "add_to_playlist") {
                onAddToPlaylist!();
              }
            },
          ),
      ],
    );
  }
}

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
    final cs = Theme.of(context).colorScheme;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        overlayColor: Colors.transparent,
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.surfaceContainerHighest,
      ),
      child: Slider(
        year2023: false,
        max: total > 0 ? total : 1.0,
        value: pos,
        onChanged: onChanged,
      ),
    );
  }
}

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
            IconButton(
              onPressed: musicProvider.togglePlayMode,
              icon: Icon(_getModeIcon(musicProvider.playMode)),
              color: colorScheme.onSurfaceVariant,
              tooltip: "播放模式",
            ),
            const SizedBox(width: 16),
            // Previous
            _RoundIconButton(
              tooltip: '上一首',
              icon: Icons.skip_previous_rounded,
              onPressed: musicProvider.playPrev,
            ),
            const SizedBox(width: 16),
            // Play/Pause
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
            const SizedBox(width: 16),
            // Next
            _RoundIconButton(
              tooltip: '下一首',
              icon: Icons.skip_next_rounded,
              onPressed: musicProvider.playNext,
            ),
            const SizedBox(width: 16),
            // Volume
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

class _LyricsSection extends StatefulWidget {
  const _LyricsSection();

  @override
  State<_LyricsSection> createState() => _LyricsSectionState();
}

class _LyricsSectionState extends State<_LyricsSection> {
  final ItemScrollController _scrollController = ItemScrollController();
  int _lastAutoScrollIndex = -1;
  int _currentLyricsHash = 0;

  @override
  Widget build(BuildContext context) {
    final lyrics = context.select<MusicProvider, List<Map<String, dynamic>>>(
      (p) => p.currentLyrics,
    );

      debugPrint(
      '_LyricsSection build: lyrics.length=${lyrics.length}, isEmpty=${lyrics.isEmpty}',
    );

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;




    if (lyrics.isEmpty) {
      return Center(
        child: Text(
          "暂无歌词",
          style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    // If lyrics source changes (e.g., switch track), reset auto-scroll state.
    final nextHash = Object.hashAll(lyrics.map((e) => e['time']));
    if (nextHash != _currentLyricsHash) {
      _currentLyricsHash = nextHash;
      _lastAutoScrollIndex = -1;
    }

    return StreamBuilder<PositionData>(
      stream: context.read<MusicProvider>().positionDataStream,
      builder: (context, snapshot) {
        final position = snapshot.data?.position ?? Duration.zero;

        // Find current lyric index
        var currentIndex = 0;
        for (var i = 0; i < lyrics.length; i++) {
          final time = lyrics[i]['time'] as Duration;
          if (position >= time) {
            currentIndex = i;
          } else {
            break;
          }
        }

        // Auto scroll only when index changes. This avoids "bounce" near end.
        if (currentIndex != _lastAutoScrollIndex) {
          _lastAutoScrollIndex = currentIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (_scrollController.isAttached) {
              // Near the end, alignment can cause repeated clamping/jitter.
              // Use a smaller alignment so the list doesn't fight the boundary.
              final isNearEnd = currentIndex >= lyrics.length - 3;
              _scrollController.scrollTo(
                index: currentIndex,
                alignment: isNearEnd ? 0.1 : 0.35,
                duration: Duration(milliseconds: isNearEnd ? 340 : 260),
                curve: Curves.easeOutCubic,
              );
            }
          });
        }

        return Stack(
          children: [
            ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              itemCount: lyrics.length,
              padding: const EdgeInsets.symmetric(vertical: 56),
              itemBuilder: (context, index) {
                final item = lyrics[index];
                final time = item['time'] as Duration;
                final text = item['text'] as String;
                final isActive = index == currentIndex;

                final baseStyle = tt.bodyLarge?.copyWith(
                  height: 1.35,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                );
                final activeStyle = tt.titleMedium?.copyWith(
                  height: 1.35,
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                );

                return InkWell(
                  onTap: () => context.read<MusicProvider>().player.seek(time),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 22,
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      style: isActive
                          ? (activeStyle ?? const TextStyle())
                          : (baseStyle ?? const TextStyle()),
                      child: Text(
                        text.isEmpty ? ' ' : text,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Top fade
            IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [cs.surface, cs.surface.withValues(alpha: 0.0)],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom fade
            IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [cs.surface, cs.surface.withValues(alpha: 0.0)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

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

        IconData icon;
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
