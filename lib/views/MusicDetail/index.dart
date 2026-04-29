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
  bool _showLyricsOnMobile = false;

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
    final lyrics = context.select<MusicProvider, List<Map<String, dynamic>>>(
      (p) => p.currentLyrics,
    );

    final isWide = MediaQuery.sizeOf(context).width > 700;
    final colorScheme = Theme.of(context).colorScheme;

    final mainContent = _MainContent(
      music: music,
      isLiked: isLiked,
      onAddToPlaylist: () => _showAddToPlaylistSheet(context, music),
    );
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
        onAddToPlaylist: () => _showAddToPlaylistSheet(context, music),
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

  Future<void> _showAddToPlaylistSheet(
      BuildContext context, MusicInfo song) async {
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
                      child: playlist.coverBytes != null &&
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
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5)
                            : null,
                      ),
                    ),
                    trailing: alreadyIn
                        ? const Icon(Icons.check_rounded,
                            color: Colors.green, size: 18)
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
            color:
                isLiked ? colorScheme.primary : colorScheme.onSurfaceVariant,
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
        final data = snapshot.data ??
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
              onChanged: (v) => musicProvider.player
                  .seek(Duration(milliseconds: v.toInt())),
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
    return SliderTheme(
      data: const SliderThemeData(
          year2023: false, overlayColor: Colors.transparent),
      child: Slider(
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
        final processingState = snapshot.data ?? ProcessingState.idle;
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
            IconButton.filled(
              onPressed: musicProvider.playPrev,
              icon: const Icon(Icons.skip_previous_rounded),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const CircleBorder(),
                fixedSize: const Size(56, 56),
              ),
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
            IconButton.filled(
              onPressed: musicProvider.playNext,
              icon: const Icon(Icons.skip_next_rounded),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const CircleBorder(),
                fixedSize: const Size(56, 56),
              ),
            ),
            const SizedBox(width: 16),
            // Volume
            StreamBuilder<double>(
              stream: musicProvider.player.volumeStream,
              builder: (context, snapshot) {
                final volume = snapshot.data ?? musicProvider.volume;
                return IconButton(
                  onPressed: () async {
                    // Toggle mute/unmute
                    final newVol = volume > 0 ? 0.0 : 1.0;
                    await musicProvider.setVolume(newVol);
                  },
                  icon: Icon(_getVolumeIcon(volume)),
                  color: colorScheme.onSurfaceVariant,
                );
              },
            ),
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

  IconData _getVolumeIcon(double volume) {
    if (volume == 0) return Icons.volume_off_rounded;
    if (volume < 0.5) return Icons.volume_down_rounded;
    return Icons.volume_up_rounded;
  }
}

class _LyricsSection extends StatelessWidget {
  final List<Map<String, dynamic>> lyrics;

  const _LyricsSection({required this.lyrics});

  @override
  Widget build(BuildContext context) {
    if (lyrics.isEmpty) {
      return const Center(
        child: Text(
          "暂无歌词",
          style: TextStyle(fontSize: 16, color: Colors.black38),
        ),
      );
    }

    final controller = ItemScrollController();
    final colorScheme = Theme.of(context).colorScheme;

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

        // Scroll to current lyric
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.isAttached) {
            controller.scrollTo(
                index: currentIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          }
        });

        return ScrollablePositionedList.builder(
          itemScrollController: controller,
          itemCount: lyrics.length,
          itemBuilder: (context, index) {
            final item = lyrics[index];
            final time = item['time'] as Duration;
            final text = item['text'] as String;
            final isActive = index == currentIndex;

            return GestureDetector(
              onTap: () {
                context.read<MusicProvider>().player.seek(time);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: isActive ? 20 : 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
