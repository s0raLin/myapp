//宽屏布局
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/views/MusicDetail/widgets/cover_tab_content.dart';
import 'package:myapp/views/MusicDetail/widgets/lyrics_section.dart';

class WideLayout extends StatelessWidget {
  final MusicInfo music;
  final bool isLiked;
  const WideLayout({super.key, required this.music, required this.isLiked});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '正在播放',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            Text(
              music.title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: CoverTabContent(music: music, isLiked: isLiked),
            ),
          ),
          const VerticalDivider(width: 40, color: Colors.transparent),
          const Expanded(flex: 4, child: LyricsSection()),
        ],
      ),
    );
  }
}
