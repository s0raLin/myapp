import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:provider/provider.dart';

class NowPlayingMiniFab extends StatelessWidget {
  const NowPlayingMiniFab({super.key});

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MusicProvider>();
    final cs = Theme.of(context).colorScheme;
    final music = context.select<MusicProvider, MusicInfo?>(
      (p) => p.currentMusic,
    );
    final isPlaying = context.select<MusicProvider, bool>(
      (p) => p.player.playing,
    );
    if (music == null) {
      return SizedBox.shrink();
    }
    return GestureDetector(
      // 1. 长按：恢复成 Bar 模式
      onLongPress: () {
        mp.setMiniMode(false);
        Feedback.forLongPress(context);
      },
      // 2. 双击：跳转到详情页 (或者你可以把单击设为跳转，长按设为模式切换)
      onDoubleTap: () {
        context.push('/music-detail', extra: music);
      },
      child: FloatingActionButton(
        onPressed: () {
          // 2. 短击：播放暂停
          mp.togglePlay();
        },
        backgroundColor: cs.primaryContainer,
        elevation: 6,
        shape: const CircleBorder(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _MiniCircularProgress(),
            Icon(
              isPlaying
                  ? Icons.music_note_rounded
                  : Icons.play_arrow_rounded,
              color: cs.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCircularProgress extends StatelessWidget {
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
        final value = pos.duration.inMilliseconds > 0
            ? (pos.position.inMilliseconds / pos.duration.inMilliseconds).clamp(
                0.0,
                1.0,
              )
            : 0.0;

        return SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 2,
            color: cs.primary,
            backgroundColor: cs.primary.withOpacity(0.1),
          ),
        );
      },
    );
  }
}
