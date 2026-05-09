import 'package:flutter/material.dart';
import 'package:myapp/model/Music/index.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:myapp/views/MusicDetail/widgets/narrow_layout.dart';
import 'package:myapp/views/MusicDetail/widgets/wide_layout.dart';
import 'package:provider/provider.dart';

// ─── 主页面 ───────────────────────────────────────────────────────────────────

class MusicDetailPage extends StatefulWidget {
  const MusicDetailPage({super.key});

  @override
  State<MusicDetailPage> createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage> {
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

    return isWide
        ? WideLayout(music: music, isLiked: isLiked)
        : NarrowLayout(music: music, isLiked: isLiked);
  }
}
