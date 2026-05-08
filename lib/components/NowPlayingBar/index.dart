import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:myapp/contants/Assets/index.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:provider/provider.dart';

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  static String _fmt(Duration d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.inMinutes.remainder(60))}:${p(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final music = context.select<MusicProvider, MusicInfo?>(
      (p) => p.currentMusic,
    );
    if (music == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final bool isWide = MediaQuery.of(context).size.width >= 800; // 宽屏阈值建议略微调大

    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/music-detail'),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          width: double.infinity,
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: isWide
              ? _buildWideLayout(context, music)
              : _buildCompactLayout(context, music),
        ),
      ),
    );
  }

  // --- 宽屏布局：左(3) 中(4) 右(3) ---
  Widget _buildWideLayout(BuildContext context, MusicInfo music) {
    final mp = context.read<MusicProvider>();
    final isPlaying = context.select<MusicProvider, bool>(
      (p) => p.player.playing,
    );

    return Row(
      children: [
        // 左侧：歌曲信息 (Flex 3)
        Expanded(flex: 3, child: _TrackInfoTile(music: music)),

        // 中间：控制与进度 (Flex 4) - 核心控制区
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconButton(
                    Icons.shuffle_rounded,
                    mp.togglePlayMode,
                    size: 20,
                  ),
                  _IconButton(Icons.skip_previous_rounded, mp.playPrev),
                  _IconButton(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    mp.togglePlay,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _IconButton(Icons.skip_next_rounded, mp.playNext),
                  _IconButton(Icons.repeat_rounded, () {}, size: 20), // 示例
                ],
              ),
              const _ProgressBar(fmt: _fmt),
            ],
          ),
        ),

        // 右侧：音量与功能 (Flex 3)
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const _VolumeControl(),
              _IconButton(Icons.queue_music_rounded, () => _showQueue(context)),
            ],
          ),
        ),
      ],
    );
  }

  // --- 紧凑布局 ---
  Widget _buildCompactLayout(BuildContext context, MusicInfo music) {
    final mp = context.read<MusicProvider>();
    final isPlaying = context.select<MusicProvider, bool>(
      (p) => p.player.playing,
    );

    return Row(
      children: [
        Expanded(child: _TrackInfoTile(music: music)),
        _IconButton(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          mp.togglePlay,
        ),
        _IconButton(Icons.queue_music_rounded, () => _showQueue(context)),
      ],
    );
  }

  // 内部辅助方法：显示播放队列
  void _showQueue(BuildContext context) {
    final mp = context.read<MusicProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _QueueSheet(mp: mp),
    );
  }
}

// ---------------------------------------------------------------------------
// 抽离的子组件（保持功能独立，但减少过度嵌套）
// ---------------------------------------------------------------------------

/// 歌曲信息块（封面+文字）
class _TrackInfoTile extends StatelessWidget {
  final MusicInfo music;
  const _TrackInfoTile({required this.music});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: music.coverBytes != null && music.coverBytes!.isNotEmpty
              ? Image.memory(
                  music.coverBytes!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 56,
                  height: 56,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.music_note_rounded),
                ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                music.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                music.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 进度条（使用 StreamBuilder 局部刷新）
class _ProgressBar extends StatelessWidget {
  final String Function(Duration) fmt;
  const _ProgressBar({required this.fmt});

  @override
  Widget build(BuildContext context) {
    final mp = context.read<MusicProvider>();
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<PositionData>(
      stream: mp.positionDataStream,
      builder: (context, snap) {
        final pos =
            snap.data ??
            PositionData(Duration.zero, Duration.zero, Duration.zero);
        double value = (pos.duration.inMilliseconds > 0)
            ? pos.position.inMilliseconds / pos.duration.inMilliseconds
            : 0.0;

        return Row(
          children: [
            Text(
              fmt(pos.position),
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
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
                    Duration(
                      milliseconds: (pos.duration.inMilliseconds * v).toInt(),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              fmt(pos.duration),
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
            ),
          ],
        );
      },
    );
  }
}

/// 音量控制
class _VolumeControl extends StatelessWidget {
  const _VolumeControl();

  @override
  Widget build(BuildContext context) {
    final mp = context.read<MusicProvider>();
    final volume = context.select<MusicProvider, double>((p) => p.volume);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(
          width: 100, // 固定音量条宽度，防止挤压
          child: Slider(value: volume, onChanged: (v) => mp.setVolume(v)),
        ),
      ],
    );
  }
}

/// 统一的图标按钮，减少重复代码
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? color;

  const _IconButton(this.icon, this.onPressed, {this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: color),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// 抽离队列视图
class _QueueSheet extends StatelessWidget {
  final MusicProvider mp;
  const _QueueSheet({required this.mp});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mp.queue.length,
      itemBuilder: (context, index) {
        final m = mp.queue[index];
        final isCurrent = mp.currentMusic?.id == m.id;
        return ListTile(
          leading: isCurrent
              ? Lottie.asset(
                  MyAssets.equalizer,
                  width: 24,
                  animate: mp.player.playing,
                )
              : const Icon(Icons.music_note),
          title: Text(m.title),
          onTap: () => mp.playByIndex(index),
        );
      },
    );
  }
}
